package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class MenuOrder {
    private String status;
    private String message;
    private OrderData orderData;
    private List<String> unavailableItems;
    private List<String> clarificationQuestions;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class OrderData {
        private List<OrderItem> orderItems;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class OrderItem {
        private String menuName;
        private Integer quantity;
        private Integer price;
        private String imageName;
        private String categoryName; // 메뉴판 표시를 위해 카테고리 이름 필드 추가
    }
}
