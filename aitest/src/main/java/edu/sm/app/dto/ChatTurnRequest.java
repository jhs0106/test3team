// src/main/java/edu/sm/app/aichat/dto/ChatTurnRequest.java
package edu.sm.app.dto;

import lombok.Data;

@Data
public class ChatTurnRequest {
    private String message;     // 사용자가 보낸 텍스트
    private String topicHint;   // 선택 chips(LOVE/MATCHING/COACHING/PROJECT_HELP 등) 선택 시 힌트
}
