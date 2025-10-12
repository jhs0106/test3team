package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessageDto {
    private Integer roomId;
    private String senderId;  // cust_id 또는 admin_id
    private String senderType; // "CUSTOMER" 또는 "ADMIN"
    private String message;
    private LocalDateTime timestamp;
    private String messageType; // "CHAT", "JOIN", "LEAVE", "SYSTEM"
}