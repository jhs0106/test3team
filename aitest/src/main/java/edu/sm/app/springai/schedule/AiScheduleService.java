package edu.sm.app.springai.schedule;

import edu.sm.app.dto.Schedule;
import edu.sm.app.service.ScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class AiScheduleService {

    private final ChatClient.Builder chatClientBuilder;
    private final ScheduleService scheduleService;

    public Schedule processScheduleRequest(String userInput) throws Exception {
        var outputConverter = new BeanOutputConverter<>(Schedule.class);

        String systemPromptTemplate = """
            당신은 일정 관리 AI입니다.
            
            오늘 날짜: {currentDate}
            현재 시각: {currentTime}
            
            규칙:
            1. 최대 7개 일정만 생성
            2. "내일" = {currentDate}의 다음날
            3. "이번주" = 오늘부터 7일
            4. 운동 일정: description에 "운동내용 | 🍽️ 식단" 형식 (40자 이내)
            5. 시간 없으면 07:00 기본
            
            카테고리: 외모관리, 대화연습, 취미활동, 데이트연습, 자기계발
            
            {format}
            
            예시:
            입력: 내일 저녁 7시 헬스장
            출력: {{"status":"SUCCESS","message":"💪 일정 추가!","schedules":[{{"title":"헬스장","category":"외모관리","startDatetime":"2025-10-22T19:00:00","endDatetime":"2025-10-22T20:30:00","description":"상체 운동 | 🍽️ 닭가슴살"}}]}}
            """;

        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm:ss");

        PromptTemplate promptTemplate = new PromptTemplate(systemPromptTemplate);
        Map<String, Object> systemParams = Map.of(
                "currentDate", now.format(dateFormatter),
                "currentTime", now.format(timeFormatter),
                "format", outputConverter.getFormat()
        );

        log.info("🗓️ 날짜 정보: {}", systemParams.get("currentDate"));

        SystemMessage systemMessage = new SystemMessage(promptTemplate.render(systemParams));
        UserMessage userMessage = new UserMessage(userInput);
        Prompt prompt = new Prompt(List.of(systemMessage, userMessage));

        ChatClient chatClient = chatClientBuilder.build();

        try {
            Schedule response = chatClient.prompt(prompt).call().entity(outputConverter);

            log.info("🤖 AI 응답: status={}, schedules={}",
                    response.getStatus(),
                    response.getSchedules() != null ? response.getSchedules().size() : 0);

            if ("SUCCESS".equals(response.getStatus()) && response.getSchedules() != null) {
                int successCount = 0;

                for (Schedule item : response.getSchedules()) {
                    try {
                        if (item.getTitle() == null || item.getStartDatetime() == null) {
                            log.warn("⚠️ 필수 필드 누락");
                            continue;
                        }

                        if (item.getEndDatetime() == null) {
                            item.setEndDatetime(item.getStartDatetime().plusHours(1));
                        }

                        scheduleService.register(item);
                        successCount++;
                        log.info("✅ 등록: {}", item.getTitle());
                    } catch (Exception e) {
                        log.error("❌ 등록 실패: {}", e.getMessage());
                    }
                }

                log.info("📊 결과: {}개 등록", successCount);
            }

            return response;

        } catch (Exception e) {
            log.error("❌ 오류", e);

            Schedule errorResponse = new Schedule();
            errorResponse.setStatus("ERROR");
            errorResponse.setMessage("❌ 일정 분석 실패. 다시 시도해주세요.");
            return errorResponse;
        }
    }
}