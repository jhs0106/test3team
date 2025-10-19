package edu.sm.app.springai.service1;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class AiServiceFewShotPrompt2 {
    private final ChatClient chatClient;

    public AiServiceFewShotPrompt2(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder.build();
    }

    public String fewShotPrompt2(String order) {
        // 프롬프트 생성
        String strPrompt = """
        아래 규칙과 예시에 따라 순수한 JSON 객체를 생성하세요.
        절대 JSON 이외의 설명, 주석, 마크다운(` ``` `)을 포함해서는 안 됩니다.

        --- 응답 JSON 구조 ---
        {
          "status": "상태",
          "message": "고객에게 보여줄 친절한 응답 메시지",
          "orderData": { "order_items": [] },
          "unavailableItems": ["주문 불가 메뉴 이름"],
          "clarificationQuestions": ["고객에게 할 질문"]
        }

        --- 규칙 ---
        1.  상태(status)는 `SUCCESS`, `PARTIAL_SUCCESS`, `NEEDS_CLARIFICATION`, `SHOW_MENU`, `FAILED` 중 하나여야 합니다.
        2.  주문 처리 규칙:
            - `orderData`: 'SUCCESS' 또는 'PARTIAL_SUCCESS'일 때, 유효한 주문 항목만 JSON 객체 배열로 채웁니다. 각 객체는 `menu_name`, `quantity`, `price`, `image_name`을 포함해야 합니다.
            - `unavailableItems`: 고객이 주문했지만 메뉴판에 없는 항목이 있을 경우, 해당 메뉴 이름을 배열에 추가합니다.
            - `clarificationQuestions`: 고객이 '수육'처럼 사이즈 선택이 필요한 메뉴를 그냥 주문한 경우, "수육은 어떤 사이즈로 하시겠어요? (대, 중, 소)" 와 같이 되물을 질문을 배열에 추가합니다. 이때 '수육'은 `orderData`에 포함시키지 마세요.
        3.  `message` 필드에는 항상 고객에게 보여줄 자연스러운 메시지를 작성해야 합니다.
        4.  가장 중요한 규칙: 당신의 최종 출력물은 반드시 `{`로 시작하여 `}`로 끝나는, 검증 가능한(valid) 순수 JSON 문자열이어야 합니다.
        
                --- 메뉴판 ---
        [국밥]
        - 소머리국밥 / 가격: 11000 / 이미지: k1.jpg
        - 돼지국밥 / 가격: 9000 / 이미지: k2.jpg
        - 순대국밥 / 가격: 9000 / 이미지: k3.jpg
        - 내장국밥 / 가격: 10000 / 이미지: k4.jpg
        - 얼큰이국밥 / 가격: 9500 / 이미지: k5.jpg
        - 설렁탕국밥 / 가격: 10000 / 이미지: k6.jpg
        - 뼈해장국 / 가격: 10000 / 이미지: k7.jpg
        - 김치말이국밥 / 가격: 9000 / 이미지: k8.jpg

        [사이드]
        - 순대 / 가격: 12000 / 이미지: k9.jpg
        - 수육(대) / 가격: 20000 / 이미지: k10.jpg
        - 수육(중) / 가격: 18000 / 이미지: k11.jpg
        - 수육(소) / 가격: 15000 / 이미지: k12.jpg
        - 머리고기 / 가격: 22000 / 이미지: k13.jpg
        - 편육 / 가격: 10000 / 이미지: k14.jpg
        
        [음료]
        - 콜라 / 가격: 2000 / 이미지: k15.jpg
        - 사이다 / 가격: 2000 / 이미지: k16.jpg
        - 아이스티 / 가격: 3000 / 이미지: k17.jpg
        - 식혜 / 가격: 3000 / 이미지: k18.jpg
        - 수정과 / 가격: 3000 / 이미지: k19.jpg
        --- 메뉴판 끝 ---


        --- 올바른 응답 예시 ---
        [요청1]: 돼지국밥 2개랑 수육 소짜 하나 주세요.
        [응답1]:
        {
          "status": "SUCCESS",
          "message": "네, 돼지국밥 2개, 수육(소) 1개 주문이 정상적으로 접수되었습니다!",
          "orderData": { "order_items": [ { "menu_name": "돼지국밥", "quantity": 2, "price": 9000, "image_name": "k2.jpg" }, { "menu_name": "수육(소)", "quantity": 1, "price": 15000, "image_name": "k12.jpg" } ] },
          "unavailableItems": [],
          "clarificationQuestions": []
        }

        [요청2]: 수육이랑 콜라 하나 주세요.
        [응답2]:
        {
          "status": "NEEDS_CLARIFICATION",
          "message": "네, 콜라 1개는 주문에 추가했습니다. 수육은 사이즈를 선택해주세요.",
          "orderData": { "order_items": [ { "menu_name": "콜라", "quantity": 1, "price": 2000, "image_name": "k15.jpg" } ] },
          "unavailableItems": [],
          "clarificationQuestions": ["수육은 어떤 사이즈로 하시겠어요? (대, 중, 소)"]
        }

        [요청3]: 순대국밥이랑 짬뽕 하나 주세요.
        [응답3]:
        {
          "status": "PARTIAL_SUCCESS",
          "message": "순대국밥 1개 주문 접수되었습니다. 죄송하지만, 짬뽕은 저희 매장에서 판매하지 않는 메뉴입니다.",
          "orderData": { "order_items": [ { "menu_name": "순대국밥", "quantity": 1, "price": 9000, "image_name": "k3.jpg" } ] },
          "unavailableItems": ["짬뽕"],
          "clarificationQuestions": []
        }
        
        [요청4]: 메뉴판 좀 보여주세요.
        [응답4]:
        {
          "status": "SHOW_MENU",
          "message": "네, 메뉴판을 보여드릴게요!",
          "orderData": { "order_items": [] },
          "unavailableItems": [],
          "clarificationQuestions": []
        }
        --- 올바른 응답 예시 끝 ---
        
        --- **절대 해서는 안 되는 잘못된 응답 예시** ---
        [요청]: 메뉴판 좀 보여주세요.
        [잘못된 응답]:
        ```json
        {
          "status": "SHOW_MENU",
          "message": "네, 메뉴판을 보여드릴게요!",
          "orderData": { "order_items": [] },
          "unavailableItems": [],
          "clarificationQuestions": []
        }
        ```
        [올바른 응답]:
        {
          "status": "SHOW_MENU",
          "message": "네, 메뉴판을 보여드릴게요!",
          "orderData": { "order_items": [] },
          "unavailableItems": [],
          "clarificationQuestions": []
        }
        --- 예시 끝 ---

        이제 고객의 요청을 처리하세요. 다른 어떤 부가 설명도 없이, 오직 JSON 객체만을 생성해야 합니다.

        --- 고객의 현재 요청 ---
        %s
        """.formatted(order);

        Prompt prompt = new Prompt(strPrompt);

        // LLM으로 요청하고 응답을 받음
        return chatClient.prompt(prompt)
                .call()
                .content();
    }
}