package edu.sm.app.dto;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class HabitCheckin {
    private Integer checkinId;
    private Integer habitId;
    private LocalDate checkinDate;
    private String memo;
    private LocalDateTime createdAt;

    // 조회 시 추가 정보
    private String habitName;
    private String icon;
}