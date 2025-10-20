package edu.sm.service;

import edu.sm.app.dto.Schedule;
import edu.sm.app.service.ScheduleService;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;

@SpringBootTest
@Slf4j
class ScheduleServiceTest {

    @Autowired
    ScheduleService scheduleService;

    @Test
    void register() throws Exception {
        Schedule schedule = Schedule.builder()
                .title("테스트 회의")
                .description("일정 등록 테스트")
                .startDatetime(LocalDateTime.of(2025, 10, 21, 14, 0))
                .endDatetime(LocalDateTime.of(2025, 10, 21, 15, 0))
                .location("강남")
                .category("회의")
                .build();

        scheduleService.register(schedule);
        log.info("일정 등록 성공");
    }

    @Test
    void get() throws Exception {
        var schedules = scheduleService.get();
        log.info("전체 일정 조회: {}", schedules);
    }

    @Test
    void getByDateRange() throws Exception {
        LocalDateTime start = LocalDateTime.of(2025, 10, 1, 0, 0);
        LocalDateTime end = LocalDateTime.of(2025, 10, 31, 23, 59);

        var schedules = scheduleService.getSchedulesByDateRange(start, end);
        log.info("기간별 일정 조회: {}", schedules);
    }

    @Test
    void remove() throws Exception {
        scheduleService.remove(1);
        log.info("일정 삭제 성공");
    }
}