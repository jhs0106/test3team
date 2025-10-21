package edu.sm.app.dto;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class DiaryEntry {
    private Long diaryId;
    private String title;
    private String content;
    private String aiFeedback;
    private LocalDate entryDate;
    private LocalDateTime createdAt;
}