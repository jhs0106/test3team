package edu.sm.controller;

import edu.sm.app.service.HabitCoachService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/habit/coach")
@Slf4j
@RequiredArgsConstructor
public class HabitCoachController {

    private final HabitCoachService habitCoachService;

    /**
     * 주간 리포트 생성
     */
    @GetMapping("/weekly-report")
    public ResponseEntity<Map<String, Object>> getWeeklyReport() {
        try {
            log.info("주간 리포트 요청");
            Map<String, Object> report = habitCoachService.generateWeeklyReport();
            return ResponseEntity.ok(report);
        } catch (Exception e) {
            log.error("주간 리포트 생성 실패", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("status", "ERROR", "message", "리포트 생성 실패"));
        }
    }

    /**
     * 개별 습관 조언
     */
    @GetMapping("/advice/{habitId}")
    public ResponseEntity<Map<String, Object>> getHabitAdvice(@PathVariable Integer habitId) {
        try {
            log.info("습관 조언 요청: habitId={}", habitId);
            Map<String, Object> advice = habitCoachService.getHabitAdvice(habitId);
            return ResponseEntity.ok(advice);
        } catch (Exception e) {
            log.error("습관 조언 생성 실패: habitId={}", habitId, e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("status", "ERROR", "message", "조언 생성 실패"));
        }
    }

    /**
     * 포기 위험 습관 감지
     */
    @GetMapping("/at-risk")
    public ResponseEntity<Map<String, Object>> getAtRiskHabits() {
        try {
            log.info("포기 위험 습관 조회");
            Map<String, Object> result = habitCoachService.detectAtRiskHabits();
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("포기 위험 습관 조회 실패", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("status", "ERROR", "message", "조회 실패"));
        }
    }
}