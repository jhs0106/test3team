package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomDto {
    private Integer roomId;
    private String custId;
    private String adminId;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime closedAt;

    // 8단계: 위치 정보 추가
    private Double latitude;
    private Double longitude;
    private LocalDateTime locationUpdateAt;
}