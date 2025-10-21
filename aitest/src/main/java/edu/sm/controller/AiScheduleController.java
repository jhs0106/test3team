package edu.sm.controller;

import edu.sm.app.dto.Schedule;
import edu.sm.app.service.ScheduleService;
import edu.sm.app.springai.schedule.AiScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/schedule")
@Slf4j
@RequiredArgsConstructor
public class AiScheduleController {

    private final AiScheduleService aiScheduleService;
    private final ScheduleService scheduleService;

    /**
     * AI 자연어 일정 추가
     */
    @PostMapping("")
    public Schedule createSchedule(@RequestParam("input") String input) throws Exception {
        log.info("📝 일정 생성 요청: {}", input);
        Schedule response = aiScheduleService.processScheduleRequest(input);
        log.info("✅ 생성 완료: {}", response.getMessage());
        return response;
    }

    /**
     * 캘린더 일정 조회
     */
    @GetMapping("/events")
    public List<Map<String, Object>> getEvents(
            @RequestParam(value = "start", required = false) String start,
            @RequestParam(value = "end", required = false) String end) throws Exception {

        LocalDateTime startDate = parseDateTime(start, LocalDateTime.now().minusMonths(1));
        LocalDateTime endDate = parseDateTime(end, LocalDateTime.now().plusMonths(2));

        log.info("📅 일정 조회: {} ~ {}", startDate.toLocalDate(), endDate.toLocalDate());

        List<Schedule> schedules = scheduleService.getSchedulesByDateRange(startDate, endDate);
        log.info("✅ 조회 결과: {}개", schedules.size());

        return schedules.stream()
                .map(this::convertToCalendarEvent)
                .collect(Collectors.toList());
    }

    /**
     * 일정 삭제
     */
    @DeleteMapping("/{scheduleId}")
    public ResponseEntity<Map<String, String>> deleteSchedule(@PathVariable Integer scheduleId) {
        try {
            log.info("🗑️ 일정 삭제: ID={}", scheduleId);

            if (scheduleId == null) {
                return ResponseEntity.badRequest()
                        .body(Map.of("status", "ERROR", "message", "일정 ID가 없습니다"));
            }

            scheduleService.remove(scheduleId);
            log.info("✅ 삭제 완료");

            return ResponseEntity.ok(Map.of("status", "SUCCESS", "message", "삭제 완료"));

        } catch (Exception e) {
            log.error("❌ 삭제 실패: ID={}", scheduleId, e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("status", "ERROR", "message", "삭제 실패"));
        }
    }

    // ==================== Helper Methods ====================

    private LocalDateTime parseDateTime(String dateStr, LocalDateTime defaultValue) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return LocalDateTime.ofInstant(Instant.parse(dateStr), ZoneId.systemDefault());
        } catch (Exception e) {
            log.warn("⚠️ 날짜 파싱 실패: {} → 기본값 사용", dateStr);
            return defaultValue;
        }
    }

    private Map<String, Object> convertToCalendarEvent(Schedule schedule) {
        Map<String, Object> event = new HashMap<>();
        event.put("id", schedule.getScheduleId());
        event.put("scheduleId", schedule.getScheduleId());
        event.put("title", schedule.getTitle());
        event.put("start", formatDateTime(schedule.getStartDatetime()));
        event.put("end", formatDateTime(schedule.getEndDatetime()));
        event.put("description", schedule.getDescription());
        event.put("location", schedule.getLocation());
        event.put("category", schedule.getCategory());
        return event;
    }

    private String formatDateTime(LocalDateTime dateTime) {
        return dateTime != null ?
                dateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : null;
    }
}