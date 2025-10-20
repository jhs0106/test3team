package edu.sm.app.springai.service2;

import edu.sm.app.dto.ReviewClassification;
import edu.sm.app.service.ReviewClassificationClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class AiServiceSystemMessage implements ReviewClassificationClient {
  // ##### 필드 #####
  private ChatClient chatClient;

  // ##### 생성자 #####
  public AiServiceSystemMessage(ChatClient.Builder chatClientBuilder) {
    chatClient = chatClientBuilder.build();
  }

  // ##### 메소드 #####
  @Override
  public ReviewClassification classifyReview(String review) {
    ReviewClassification reviewClassification = chatClient.prompt()
            .system("""
            당신은 결혼 정보사 '결정사'의 리뷰 분석가입니다.
            고객 후기를 [POSITIVE, NEUTRAL, NEGATIVE] 중 하나로 분류하고,
            분류 결과와 원문 리뷰를 포함한 유효한 JSON을 반환하세요.
         """)
            .user("%s".formatted(review))
            .options(ChatOptions.builder().build())
            .call()
            .entity(ReviewClassification.class);
    return reviewClassification;
  }
}