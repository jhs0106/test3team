package edu.sm.app.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class Schedule {
    // DB 필드
    private Integer scheduleId;
    private String title;
    private String description;
    private LocalDateTime startDatetime;
    private LocalDateTime endDatetime;
    private String location;
    private String category;
    private LocalDateTime createdAt;

    // AI 응답용 필드
    private String status;
    private String message;
    private List<String> clarificationQuestions;
    private List<Schedule> schedules;
}