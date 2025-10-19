package edu.sm.app.springai.service2;

import edu.sm.app.dto.Menu;
import edu.sm.app.dto.MenuOrder;
import edu.sm.app.service.MenuService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class AiServiceShop {
    private final ChatClient.Builder chatClientBuilder;
    private final MenuService menuService;

    public MenuOrder processRequest(String userRequest) throws Exception {
        var outputConverter = new BeanOutputConverter<>(MenuOrder.class);
        String menuString = buildMenuString();

        String systemPromptTemplate = """
            당신은 고객의 요청을 분석하여 `MenuOrder` DTO 형식에 맞는 JSON 객체를 반환하는 전문 주문 처리 API입니다.
            아래 메뉴판 정보와 규칙을 참고하여 고객의 요청을 처리하세요.

            {menuString}

            --- 규칙 ---
            - 고객이 '메뉴판'을 요청하면, `status`를 "SHOW_MENU"로, `orderData.orderItems`에는 전체 메뉴 목록을 채워서 응답하세요.
            - 주문을 받으면, 유효한 항목은 `orderData.orderItems`에 추가하세요.
            - 없는 메뉴는 `unavailableItems`에, 사이즈 확인이 필요하면 `clarificationQuestions`에 담아주세요.
            - 모든 응답에는 자연스러운 `message`를 포함해야 합니다.

            {format}
            
            --- 응답 예시 ---
            [요청]: 돼지국밥 하나랑 수육 소짜 주세요
            [응답]:
            \\{
              "status": "SUCCESS",
              "message": "네, 돼지국밥 1개, 수육(소) 1개 주문 접수되었습니다.",
              "orderData": \\{
                "orderItems": [
                  \\{ "menuName": "돼지국밥", "quantity": 1, "price": 9000, "imageName": "k2.jpg", "categoryName": null \\},
                  \\{ "menuName": "수육(소)", "quantity": 1, "price": 15000, "imageName": "k12.jpg", "categoryName": null \\}
                ]
              \\},
              "unavailableItems": [],
              "clarificationQuestions": []
            \\}
            
            [요청]: 메뉴판 보여줘
            [응답]:
            \\{
              "status": "SHOW_MENU",
              "message": "네, 메뉴판을 보여드릴게요!",
              "orderData": \\{
                "orderItems": [
                  \\{ "menuName": "소머리국밥", "quantity": 0, "price": 11000, "imageName": "k1.jpg", "categoryName": "주메뉴" \\},
                  \\{ "menuName": "돼지국밥", "quantity": 0, "price": 9000, "imageName": "k2.jpg", "categoryName": "주메뉴" \\}
                ]
              \\},
              "unavailableItems": [],
              "clarificationQuestions": []
            \\}
            """;

        PromptTemplate promptTemplate = new PromptTemplate(systemPromptTemplate);

        Map<String, Object> systemParams = Map.of(
                "menuString", menuString,
                "format", outputConverter.getFormat()
        );
        SystemMessage systemMessage = new SystemMessage(promptTemplate.render(systemParams));

        UserMessage userMessage = new UserMessage(userRequest);
        Prompt prompt = new Prompt(List.of(systemMessage, userMessage));

        ChatClient chatClient = chatClientBuilder.build();
        MenuOrder response;
        try {
            response = chatClient.prompt(prompt)
                    .call()
                    .entity(outputConverter);
        } catch(Exception e) {
            throw new RuntimeException();
        }
        return response;
    }

    private String buildMenuString() throws Exception {
        List<Menu> menuList = menuService.getAllWithCategory();
        Map<String, List<Menu>> menuByCategory = menuList.stream()
                .collect(Collectors.groupingBy(Menu::getCategoryName));

        StringBuilder sb = new StringBuilder();
        sb.append("--- 메뉴판 ---\n");
        menuByCategory.forEach((categoryName, menus) -> {
            sb.append("[").append(categoryName).append("]\n");
            menus.forEach(menu -> {
                sb.append(String.format("- %s / 가격: %d원 / 이미지: %s\n",
                        menu.getMenuName(), menu.getMenuPrice(), menu.getMenuImage()));
            });
            sb.append("\n");
        });
        sb.append("--- 메뉴판 끝 ---\n");
        return sb.toString();
    }
}

