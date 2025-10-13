package edu.sm.app.repository;

import edu.sm.app.dto.UserStatsDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * 고객 사용량 통계 Repository
 */
@Mapper
public interface UserStatsRepository {

    /**
     * 특정 고객의 최근 N일 통계 조회
     */
    List<UserStatsDto> getStatsByCustId(@Param("custId") String custId, @Param("days") int days);

    /**
     * 특정 고객의 특정 기간 통계 조회
     */
    List<UserStatsDto> getStatsByDateRange(
            @Param("custId") String custId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    /**
     * 모든 고객의 일별 통계 합계 조회 (최근 N일)
     */
    List<Map<String, Object>> getDailyStats(@Param("days") int days);

    /**
     * 통계 데이터 삽입/업데이트
     */
    void insertStats(UserStatsDto stats);

    /**
     * 고객별 통계 요약 조회
     */
    List<Map<String, Object>> getCustomerSummary(@Param("days") int days);
}