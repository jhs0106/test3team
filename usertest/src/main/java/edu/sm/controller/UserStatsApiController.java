package edu.sm.controller;

import edu.sm.app.dto.UserStatsDto;
import edu.sm.app.service.UserStatsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * 고객 사용량 통계 API
 */
@RestController
@RequestMapping("/api/stats")
@RequiredArgsConstructor
@Slf4j
public class UserStatsApiController {

    private final UserStatsService userStatsService;

    /**
     * 특정 고객의 최근 N일 통계 조회
     * GET /api/stats/customer/{custId}?days=30
     */
    @GetMapping("/customer/{custId}")
    public ResponseEntity<List<UserStatsDto>> getCustomerStats(
            @PathVariable String custId,
            @RequestParam(defaultValue = "30") int days) {
        log.info("===== API: 고객 통계 조회, custId={}, days={} =====", custId, days);
        List<UserStatsDto> stats = userStatsService.getStatsByCustId(custId, days);
        return ResponseEntity.ok(stats);
    }

    /**
     * 특정 고객의 특정 기간 통계 조회
     * GET /api/stats/customer/{custId}/range?startDate=2025-01-01&endDate=2025-01-31
     */
    @GetMapping("/customer/{custId}/range")
    public ResponseEntity<List<UserStatsDto>> getCustomerStatsByRange(
            @PathVariable String custId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        log.info("===== API: 고객 통계 조회(기간), custId={}, {} ~ {} =====", custId, startDate, endDate);
        List<UserStatsDto> stats = userStatsService.getStatsByDateRange(custId, startDate, endDate);
        return ResponseEntity.ok(stats);
    }

    /**
     * 전체 일별 통계 조회
     * GET /api/stats/daily?days=30
     */
    @GetMapping("/daily")
    public ResponseEntity<List<Map<String, Object>>> getDailyStats(
            @RequestParam(defaultValue = "30") int days) {
        log.info("===== API: 전체 일별 통계 조회, days={} =====", days);
        List<Map<String, Object>> stats = userStatsService.getDailyStats(days);
        return ResponseEntity.ok(stats);
    }

    /**
     * 고객별 통계 요약 조회
     * GET /api/stats/summary?days=30
     */
    @GetMapping("/summary")
    public ResponseEntity<List<Map<String, Object>>> getCustomerSummary(
            @RequestParam(defaultValue = "30") int days) {
        log.info("===== API: 고객별 통계 요약 조회, days={} =====", days);
        List<Map<String, Object>> summary = userStatsService.getCustomerSummary(days);
        return ResponseEntity.ok(summary);
    }

    /**
     * 통계 데이터 생성 (테스트용)
     * POST /api/stats
     */
    @PostMapping
    public ResponseEntity<String> createStats(@RequestBody UserStatsDto stats) {
        log.info("===== API: 통계 데이터 생성 =====");
        userStatsService.insertStats(stats);
        return ResponseEntity.ok("통계 데이터가 생성되었습니다.");
    }
}