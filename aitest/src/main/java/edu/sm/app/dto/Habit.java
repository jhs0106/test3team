package edu.sm.app.dto;

import lombok.*;
import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class Habit {
    private Integer habitId;
    private String habitName;
    private String description;
    private String category;
    private String icon;
    private Integer targetFrequency;  // 주당 목표 횟수
    private LocalDateTime createdAt;

    // 통계용 필드 (조회 시 사용)
    private Integer currentStreak;    // 현재 연속 일수
    private Integer totalCheckins;    // 총 체크인 횟수
    private Integer weeklyCheckins;   // 이번 주 체크인 횟수
}