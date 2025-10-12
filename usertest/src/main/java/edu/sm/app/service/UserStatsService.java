package edu.sm.app.service;

import edu.sm.app.dto.UserStatsDto;
import edu.sm.app.repository.UserStatsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * 고객 사용량 통계 Service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UserStatsService {

    private final UserStatsRepository userStatsRepository;

    /**
     * 특정 고객의 최근 N일 통계 조회
     */
    public List<UserStatsDto> getStatsByCustId(String custId, int days) {
        log.info("📊 고객 통계 조회: custId={}, days={}", custId, days);
        return userStatsRepository.getStatsByCustId(custId, days);
    }

    /**
     * 특정 고객의 특정 기간 통계 조회
     */
    public List<UserStatsDto> getStatsByDateRange(String custId, LocalDate startDate, LocalDate endDate) {
        log.info("📊 고객 통계 조회(기간): custId={}, {} ~ {}", custId, startDate, endDate);
        return userStatsRepository.getStatsByDateRange(custId, startDate, endDate);
    }

    /**
     * 모든 고객의 일별 통계 합계 조회
     */
    public List<Map<String, Object>> getDailyStats(int days) {
        log.info("📊 전체 일별 통계 조회: days={}", days);
        return userStatsRepository.getDailyStats(days);
    }

    /**
     * 통계 데이터 삽입
     */
    public void insertStats(UserStatsDto stats) {
        log.info("📊 통계 데이터 삽입: {}", stats);
        userStatsRepository.insertStats(stats);
    }

    /**
     * 고객별 통계 요약 조회
     */
    public List<Map<String, Object>> getCustomerSummary(int days) {
        log.info("📊 고객별 통계 요약 조회: days={}", days);
        return userStatsRepository.getCustomerSummary(days);
    }
}