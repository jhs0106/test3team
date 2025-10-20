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
            당신은 사용자의 자연어 일정 입력을 분석하여 구조화된 일정 데이터로 변환하는 AI입니다.
            현재 날짜와 시간: {currentDateTime}
            
            규칙:
            - 제목(title), 시작시간(startDatetime: ISO 8601), 종료시간(endDatetime: ISO 8601), 장소(location), 카테고리(category: 회의/약속/개인/업무) 추출
            - 시간 없으면 09:00, 종료시간 없으면 +1시간
            - 불명확하면 clarificationQuestions에 질문 추가
            
            {format}
            
            예시:
            입력: 내일 오후 2시 강남 회의
            출력: {{"status":"SUCCESS","message":"1개 일정 추가","schedules":[{{"title":"회의","startDatetime":"2025-10-21T14:00:00","endDatetime":"2025-10-21T15:00:00","location":"강남","category":"회의"}}],"clarificationQuestions":[]}}
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