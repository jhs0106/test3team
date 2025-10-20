package edu.sm.controller;

import edu.sm.app.dto.Schedule;
import edu.sm.app.service.ScheduleService;
import edu.sm.app.springai.schedule.AiScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ui.Model;
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

    @PostMapping("/test")
    public Schedule test(@RequestParam("input") String input) throws Exception {
        log.info("입력: {}", input);
        Schedule response = aiScheduleService.processScheduleRequest(input);
        log.info("응답: {}", response);
        return response;
    }

    @GetMapping("/events")
    public List<Map<String, Object>> getEvents(
            @RequestParam(value = "start", required = false) String start,
            @RequestParam(value = "end", required = false) String end) throws Exception {

        log.info("일정 조회 요청 - start: {}, end: {}", start, end);

        LocalDateTime startDate;
        LocalDateTime endDate;

        if (start == null || start.trim().isEmpty()) {
            startDate = LocalDateTime.now().minusMonths(1);
        } else {
            // ISO 8601 형식 (밀리초, 타임존 포함) 파싱
            startDate = LocalDateTime.ofInstant(
                    Instant.parse(start),
                    ZoneId.systemDefault()
            );
        }

        if (end == null || end.trim().isEmpty()) {
            endDate = LocalDateTime.now().plusMonths(2);
        } else {
            // ISO 8601 형식 (밀리초, 타임존 포함) 파싱
            endDate = LocalDateTime.ofInstant(
                    Instant.parse(end),
                    ZoneId.systemDefault()
            );
        }

        List<Schedule> schedules = scheduleService.getSchedulesByDateRange(startDate, endDate);
        log.info("조회된 일정 개수: {}", schedules.size());

        return schedules.stream().map(s -> {
            Map<String, Object> event = new HashMap<>();
            event.put("id", s.getScheduleId());
            event.put("title", s.getTitle());
            event.put("start", s.getStartDatetime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            event.put("end", s.getEndDatetime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            event.put("description", s.getDescription());
            event.put("location", s.getLocation());
            event.put("category", s.getCategory());
            return event;
        }).collect(Collectors.toList());
    }

    @DeleteMapping("/{scheduleId}")
    public Map<String, String> deleteSchedule(@PathVariable Integer scheduleId) throws Exception {
        log.info("일정 삭제 요청 - scheduleId: {}", scheduleId);
        scheduleService.remove(scheduleId);
        return Map.of("status", "SUCCESS", "message", "삭제 완료");
    }
}