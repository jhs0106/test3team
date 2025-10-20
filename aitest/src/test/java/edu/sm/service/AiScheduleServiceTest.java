package edu.sm.service;

import edu.sm.app.dto.Schedule;
import edu.sm.app.springai.schedule.AiScheduleService;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@Slf4j
class AiScheduleServiceTest {

    @Autowired
    AiScheduleService aiScheduleService;

    @Test
    void processScheduleRequest1() throws Exception {
        String input = "내일 오후 2시에 강남에서 프로젝트 회의";
        Schedule response = aiScheduleService.processScheduleRequest(input);
        log.info("AI 응답: {}", response);
    }

    @Test
    void processScheduleRequest2() throws Exception {
        String input = "다음주 월요일 오전 10시 치과 예약";
        Schedule response = aiScheduleService.processScheduleRequest(input);
        log.info("AI 응답: {}", response);
    }

    @Test
    void processScheduleRequest3() throws Exception {
        String input = "12월 25일 저녁 7시 크리스마스 파티";
        Schedule response = aiScheduleService.processScheduleRequest(input);
        log.info("AI 응답: {}", response);
    }

    @Test
    void processScheduleRequestUnclear() throws Exception {
        String input = "다음주에 회의 있어";
        Schedule response = aiScheduleService.processScheduleRequest(input);
        log.info("AI 응답: {}", response);
        log.info("추가 질문: {}", response.getClarificationQuestions());
    }
}