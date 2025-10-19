package edu.sm.app.springai.service1;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.chat.prompt.SystemPromptTemplate;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.util.Map;

@Service
@Slf4j
public class AiServicePromptTemplate {
    // ##### 필드 #####
    private ChatClient chatClient;

    private PromptTemplate systemTemplate = SystemPromptTemplate.builder()
            .template("""
          답변을 생성할 때 HTML와 CSS를 사용해서 파란 글자로 출력하세요.
          <span> 태그 안에 들어갈 내용만 출력하세요.
          """)
            .build();

    private PromptTemplate userTemplate = PromptTemplate.builder()
            .template("다음 한국어 문장을 {language}로 번역해주세요.\n 문장: {statement}")
            .build();

    // ##### 생성자 #####
    public AiServicePromptTemplate(ChatClient.Builder chatClientBuilder) {
        chatClient = chatClientBuilder.build();
    }

    // ##### 메소드 #####
    public Flux<String> promptTemplate1(String statement, String language) {
        Prompt prompt = userTemplate.create(
                Map.of("statement", statement, "language", language));

        Flux<String> response = chatClient.prompt(prompt)
                .stream()
                .content();
        return response;
    }

    public Flux<String> promptTemplate2(String statement, String language) {
        Flux<String> response = chatClient.prompt()
                .messages(
                        systemTemplate.createMessage(),
                        userTemplate.createMessage(Map.of("statement", statement, "language", language)))
                .stream()
                .content();
        return response;
    }

    public Flux<String> promptTemplate3(String statement, String language) {
        Flux<String> response = chatClient.prompt()
                .system(systemTemplate.render())
                .user(userTemplate.render(Map.of("statement", statement, "language", language)))
                .stream()
                .content();
        return response;
    }

    public Flux<String> promptTemplate4(String statement, String language) {
        String systemText = """
        답변을 생성할 때 HTML와 CSS를 사용해서 파란 글자로 출력하세요.
        <span> 태그 안에 들어갈 내용만 출력하세요.
        """;
        String userText = """
        다음 한국어 문장을 %s로 번역해주세요.\n 문장: %s
        """.formatted(language, statement);

        Flux<String> response = chatClient.prompt()
                .system(systemText)
                .user(userText)
                .stream()
                .content();
        return response;
    }

    public Flux<String> roleAssignment(String requirements) {
        Flux<String> travelSuggestions = chatClient.prompt()
                // 시스템 메시지 추가
                .system("""
            당신이 여행 가이드 역할을 해 주었으면 좋겠습니다.
            아래 요청사항에서 위치를 알려주면, 근처에 있는 3곳을 제안해 주고,
            이유를 달아주세요. 경우에 따라서 방문하고 싶은 장소 유형을 
            제공할 수도 있습니다.
            출력 형식은 <ul> 태그이고, 장소는 굵게 표시해 주세요.
            """)
                // 사용자 메시지 추가
                .user("요청사항: %s".formatted(requirements))
                // 대화 옵션 설정
                .options(ChatOptions.builder()
                        .build())
                // LLM으로 요청하고 응답 얻기
                .stream()
                .content();
        return travelSuggestions;
    }


}