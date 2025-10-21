package edu.sm.app.springai.service3;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.util.Random;

@Service
@Slf4j
public class AiQuoteService {
    private ChatClient chatClient;
    private Random random = new Random();

    public AiQuoteService(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder.build();
    }

    // 명언 생성 메서드 (Flux 사용)
    public Flux<String> generateDailyQuote() {
        // 매번 다른 명언을 위한 랜덤 주제 추가
        String[] themes = {
                "인생의 방향과 목표",
                "사람 간의 관계와 배려",
                "어려움 속에서의 인내",
                "겸손함과 성장",
                "지혜로운 판단",
                "노력과 성취",
                "진실과 정직",
                "감사와 만족",
                "용기와 도전",
                "평화로운 마음"
        };

        String randomTheme = themes[random.nextInt(themes.length)];
        String[] formats = {"사자성어", "명언", "속담"};
        String randomFormat = formats[random.nextInt(formats.length)];


        String systemMessage = """
        당신은 삶의 지혜를 전하는 명언 전문가입니다.
        사람이 사람답게 살기 위한 지혜를 전해주세요.
        
        다음 세 가지 형식 중 하나를 랜덤하게 선택하여 제시해주세요:
        
        1. 사자성어 형식:
           사자성어: [정확히 4글자 한자]
           뜻: [한글 뜻풀이]
           의미: [삶에 적용할 수 있는 의미 설명]
           
           ※ 매우 중요: 사자성어는 반드시 정확히 4글자 한자여야 합니다. 
           4글자가 아니면 절대 안됩니다.
           좋은 예시) 일석이조(一石二鳥), 백전백승(百戰百勝), 온고지신(溫故知新), 역지사지(易地思之)
           나쁜 예시) 삼세번(3글자), 오리무중(한국식 표현일 경우)
        
        2. 명언 형식:
           명언: [명언 내용]
           출처: [누가 한 말인지]
           의미: [명언에 담긴 교훈]
        
        3. 속담 형식:
           속담: [속담 내용]
           뜻: [속담의 의미]
           교훈: [삶에 적용할 수 있는 교훈]
        
        매번 다른 내용을 제시해주세요.
        특히 사자성어를 선택한 경우, 응답하기 전에 반드시 한자 글자수를 세어서 정확히 4글자인지 확인하세요.
        """;

        Flux<String> fluxString = chatClient.prompt()
                .system(systemMessage)
                .user("'" + randomTheme + "'에 관련된 " + randomFormat + " 형식으로 하나 알려주세요.")
                .options(ChatOptions.builder()
                        .temperature(0.9)  // 랜덤성 증가 (0.0~2.0, 높을수록 다양함)
                        .build())
                .stream()
                .content();

        return fluxString;
    }
}
