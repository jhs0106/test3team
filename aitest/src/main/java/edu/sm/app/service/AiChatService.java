// src/main/java/edu/sm/app/service/AiChatService.java
package edu.sm.app.service;

import edu.sm.app.dto.AiResponse;
import edu.sm.app.dto.ChatTurnRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@Slf4j
public class AiChatService {

    private final ChatClient chatClient;

    public AiChatService(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder.build();
    }

    // === 프로젝트 팩트 ===
    private static final String PROJECT_FACTS = """
        [PROJECT FACTS]
        - STOMP SockJS endpoints: /chat, /adminchat
        - WebSocket broker prefixes: /send, /adminsend
        - Native WebSocket chat endpoint: /ws/chat
        - WebRTC signaling endpoint: /signal
        - ChatRoom REST APIs:
          GET /api/chatroom/active/{custId}
          POST /api/chatroom/create
          POST /api/chatroom/{roomId}/assign?adminId=...
          POST /api/chatroom/{roomId}/close
          POST /api/chatroom/{roomId}/location
        - JSP 레이아웃: index.jsp에서 left/center include, jQuery/Bootstrap/FULLCALENDAR 사용
        - JSP-EL은 JS 템플릿 문자열 내 직접 사용하지 말고 data-* 속성으로 전달
        """;

    // === 시스템 프롬프트 ===
    private static final String SYSTEM_PROMPT = """
        당신은 '결정사'의 AI 상담사이자 프로젝트 헬퍼입니다.
        - 한국어로 공감/간결/정확하게 답하세요.
        - 연애/매칭/코칭/일정/고객케어/일반 대화 + PROJECT_HELP(개발 이슈)까지 대응합니다.
        - PROJECT_HELP 시: '원인 후보 → 점검 체크리스트 → 소규모 안전 수정 제안' 순으로 답하세요.
        - 위험/배포/보안/서버 설정 변경 등은 즉시 상담사 이관을 제안하세요.
        - 최종 출력은 아래 JSON 스키마만 반환하세요(다른 텍스트/코드펜스 금지):
          { "status": "...", "topic":"...", "message":"...", "followups":[], "action":"...", "confidence":0.0 }
        - 가능한 topic: LOVE|MATCHING|COACHING|SCHEDULE|CUSTOMER_CARE|PROJECT_HELP|GENERAL
        - 가능한 status: SUCCESS|ANSWER|CLARIFY|ESCALATE|FAILED
        - action: NONE|CALL_AGENT|OPEN_PAGE
        """ + PROJECT_FACTS;

    // 위험/개발 로그 패턴
    private static final Pattern RISKY_ERROR = Pattern.compile(
            "ReferenceError: SockJS is not defined|Cannot read property|TypeError|404|403|wss?://|stomp|websocket",
            Pattern.CASE_INSENSITIVE
    );

    public AiResponse chat(ChatTurnRequest req, String loginId) {
        final String user = req.getMessage() == null ? "" : req.getMessage().trim();
        final String hint = req.getTopicHint() == null ? "" : req.getTopicHint().trim();

        final boolean projectHelpLikely = RISKY_ERROR.matcher(user).find()
                || "PROJECT_HELP".equalsIgnoreCase(hint);

        final String userMsg = """
            [USER]
            loginId: %s
            message: %s
            topicHint: %s
            """.formatted(loginId == null ? "guest" : loginId, user, hint);

        // 1) LLM 호출 (문자열)
        String raw = chatClient.prompt()
                .system(SYSTEM_PROMPT)
                .user(userMsg)
                .options(ChatOptions.builder().build())
                .call()
                .content();

        // 2) 코드펜스/잡설 제거 + JSON 블록만 추출 후 파싱
        AiResponse parsed = parseAiResponse(raw);

        // 3) 파싱 실패 시에도 깨끗한 메시지로 만들어 반환
        if (parsed == null) {
            parsed = AiResponse.builder()
                    .status("ANSWER")
                    .topic(projectHelpLikely ? "PROJECT_HELP" : "GENERAL")
                    .message(safePlainMessage(raw))
                    .followups(new ArrayList<>())
                    .action("NONE")
                    .confidence(projectHelpLikely ? 0.6 : 0.5)
                    .build();
        }

        // 4) PROJECT_HELP 이고 신뢰도 낮으면 바로 이관
        if ("PROJECT_HELP".equalsIgnoreCase(parsed.getTopic())
                && (parsed.getConfidence() == null || parsed.getConfidence() < 0.55)) {
            parsed.setStatus("ESCALATE");
            parsed.setAction("CALL_AGENT");
            parsed.setMeta(AiResponse.Meta.builder()
                    .target("/websocket/inquiry")
                    .note("개발/인프라 변경 또는 위험도 판단")
                    .build());
        }

        return parsed;
    }

    // ===== 내부 유틸 =====

    private AiResponse parseAiResponse(String raw) {
        if (raw == null) return null;
        String s = raw
                .replaceAll("```(?:json)?", "")
                .replace("```", "")
                .trim();

        // 맨 처음/마지막 중괄호 블록만 추출
        int i = s.indexOf('{');
        int j = s.lastIndexOf('}');
        if (i >= 0 && j > i) s = s.substring(i, j + 1);

        try {
            com.fasterxml.jackson.databind.ObjectMapper om = new com.fasterxml.jackson.databind.ObjectMapper();
            return om.readValue(s, AiResponse.class);
        } catch (Exception e) {
            log.debug("AI JSON 파싱 실패: {}", e.getMessage());
            return null;
        }
    }

    private String safePlainMessage(String raw) {
        if (raw == null) return "답변을 만들 수 없었습니다.";
        // message":" … " 패턴만 뽑아보기
        Matcher m = Pattern.compile("\"message\"\\s*:\\s*\"([\\s\\S]*?)\"").matcher(raw);
        if (m.find()) {
            return m.group(1);
        }
        // 코드펜스 제거 후 남은 평문
        return raw.replaceAll("```(?:json)?", "").replace("```", "").trim();
    }
}
