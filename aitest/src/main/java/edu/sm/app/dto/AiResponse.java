// src/main/java/edu/sm/app/aichat/dto/AiResponse.java
package edu.sm.app.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class AiResponse {
    private String status;          // SUCCESS | ANSWER | CLARIFY | ESCALATE | FAILED ...
    private String topic;           // LOVE | MATCHING | COACHING | SCHEDULE | CUSTOMER_CARE | PROJECT_HELP | GENERAL
    private String message;         // 사용자에게 보여줄 본문
    private List<String> followups; // 후속 질문
    private String action;          // NONE | CALL_AGENT | OPEN_PAGE ...
    private Double confidence;      // 0~1
    private Meta meta;              // 라우팅 부가 정보

    @Data @Builder
    public static class Meta {
        private String target;      // 예) "/websocket/inquiry"
        private String note;        // 내부 비고
    }
}
