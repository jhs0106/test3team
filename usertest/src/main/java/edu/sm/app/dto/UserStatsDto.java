package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 고객 사용량 통계 DTO
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserStatsDto {
    private Integer statId;              // 통계 ID
    private String custId;               // 고객 ID
    private LocalDate statDate;          // 통계 날짜
    private Integer chatCount;           // 채팅 횟수
    private Integer totalDuration;       // 총 대화 시간(분)
    private Integer avgResponseTime;     // 평균 응답 시간(초)
    private Integer satisfactionScore;   // 만족도 점수 (1-5)
    private LocalDateTime createdAt;     // 생성일시
    private LocalDateTime updatedAt;     // 수정일시
}