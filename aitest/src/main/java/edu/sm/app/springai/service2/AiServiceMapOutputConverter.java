package edu.sm.app.springai.service2;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.converter.MapOutputConverter;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@Slf4j
public class AiServiceMapOutputConverter {
  // ##### 필드 #####
  private ChatClient chatClient;

  // ##### 생성자 #####
  public AiServiceMapOutputConverter(ChatClient.Builder chatClientBuilder) {
    chatClient = chatClientBuilder.build();
  }

  // ##### 메소드 #####
  public Map<String, Object> mapOutputConverterLowLevel(String hotel) {
    // 구조화된 출력 변환기 생성
    MapOutputConverter mapOutputConverter = new MapOutputConverter();
    // 프롬프트 템플릿 생성
    PromptTemplate promptTemplate = new PromptTemplate(
        "호텔 {hotel}에 대해 정보를 알려주세요 {format}");
    // 프롬프트 생성
    Prompt prompt = promptTemplate.create(Map.of(
        "hotel", hotel,
        "format", mapOutputConverter.getFormat()));
    // LLM의 JSON 출력 얻기
    String json = chatClient.prompt(prompt)
        .call()
        .content();
    // List<String>으로 변환
    Map<String, Object> hotelInfo = mapOutputConverter.convert(json);
    return hotelInfo;
  }
  
  public Map<String, Object> mapOutputConverterHighLevel(String hotel) {
    Map<String, Object> hotelInfo = chatClient.prompt()
            .system("한글로 대답해주세요.")
        .user("호텔 %s에 대해 amenities, address, chekOutTime, checkInTime, contact, rating, description 정보를 알려주세요, 주소에는 경도와 위도도 알려줘".formatted(hotel))
        .call()
        .entity(new MapOutputConverter());
    return hotelInfo;
  }

}
