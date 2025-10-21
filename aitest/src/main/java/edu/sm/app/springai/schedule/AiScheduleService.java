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
            당신은 '사람 만들기' 프로젝트의 AI 자기계발 코치입니다.
            사용자의 자연어 입력을 분석하여 자기계발 일정으로 변환하세요.
            
            현재 날짜: {currentDateTime}
            
            특별 기능:
            1. 기간별 계획 요청 시 여러 일정을 생성
               예: "11월 1일부터 7일까지 운동 계획" → 7일간의 운동 일정 생성
            
            2. 운동 계획 요청 시 식이요법도 함께 제안
               description에 식단 정보 포함
            
            카테고리 분류 기준:
            - 외모관리: 헬스장, 운동, 피부과, 미용실, 쇼핑, 다이어트, 필라테스, 요가
            - 대화연습: 모임, 스피치, 발표, 네트워킹, 친구 만남, 토론, 봉사활동
            - 취미활동: 등산, 요리, 사진, 악기, 그림, 춤, 노래, 게임, 영화
            - 데이트연습: 카페, 영화, 전시회, 레스토랑 탐방, 공연, 여행
            - 자기계발: 독서, 강의, 자격증, 어학, 코딩, 재테크
            
            {format}
            
            예시 1 (단일 일정):
            입력: 내일 저녁 7시 헬스장
            출력: {{"status":"SUCCESS","message":"💪 운동 일정이 추가되었어요!","schedules":[{{"title":"헬스장 운동","category":"외모관리","startDatetime":"2025-10-22T19:00:00","endDatetime":"2025-10-22T20:30:00","description":"상체 운동 집중 (벤치프레스, 덤벨 프레스)\n\n🍽️ 식단 추천:\n- 운동 전: 바나나 + 견과류\n- 운동 후: 닭가슴살 샐러드 + 고구마"}}]}}
            
            예시 2 (기간별 계획):
            입력: 10월 22일부터 26일까지 운동 계획 짜줘
            출력: {{"status":"SUCCESS","message":"💪 5일간 운동 계획이 생성되었어요!","schedules":[
                {{"title":"가슴 운동","category":"외모관리","startDatetime":"2025-10-22T19:00:00","endDatetime":"2025-10-22T20:30:00","description":"벤치프레스, 인클라인 프레스, 푸시업\n\n🍽️ 저녁: 닭가슴살 150g + 고구마 200g"}},
                {{"title":"등 운동","category":"외모관리","startDatetime":"2025-10-23T19:00:00","endDatetime":"2025-10-23T20:30:00","description":"풀업, 바벨 로우, 랫풀다운\n\n🍽️ 저녁: 소고기 스테이크 + 브로콜리"}},
                {{"title":"하체 운동","category":"외모관리","startDatetime":"2025-10-24T19:00:00","endDatetime":"2025-10-24T20:30:00","description":"스쿼트, 레그프레스, 런지\n\n🍽️ 저녁: 연어 + 아보카도 샐러드"}},
                {{"title":"어깨 운동","category":"외모관리","startDatetime":"2025-10-25T19:00:00","endDatetime":"2025-10-25T20:30:00","description":"오버헤드 프레스, 사이드 레터럴 레이즈\n\n🍽️ 저녁: 두부 스테이크 + 현미밥"}},
                {{"title":"팔 운동","category":"외모관리","startDatetime":"2025-10-26T19:00:00","endDatetime":"2025-10-26T20:30:00","description":"바이셉 컬, 트라이셉 익스텐션\n\n🍽️ 저녁: 참치 샐러드 + 통밀빵"}}
            ]}}
            
            예시 3 (주간 계획):
            입력: 다음주 일주일 운동 계획
            출력: 월~일 7일간 다양한 운동 일정 생성 (각각 description에 운동 내용 + 식단 포함)
            
            규칙:
            - 기간 계획 시 하루 1개 일정 생성
            - 운동 일정엔 반드시 식이요법 포함
            - 식단은 운동 전후 또는 하루 식단으로 구성
            - description에 운동 상세 + 식단을 명확히 구분해서 작성
            """;

        PromptTemplate promptTemplate = new PromptTemplate(systemPromptTemplate);
        Map<String, Object> systemParams = Map.of(
                "currentDateTime", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
                "format", outputConverter.getFormat()
        );

        SystemMessage systemMessage = new SystemMessage(promptTemplate.render(systemParams));
        UserMessage userMessage = new UserMessage(userInput);
        Prompt prompt = new Prompt(List.of(systemMessage, userMessage));

        ChatClient chatClient = chatClientBuilder.build();
        Schedule response = chatClient.prompt(prompt).call().entity(outputConverter);

        if ("SUCCESS".equals(response.getStatus()) && response.getSchedules() != null) {
            for (Schedule item : response.getSchedules()) {
                scheduleService.register(item);
            }
        }

        return response;
    }
}