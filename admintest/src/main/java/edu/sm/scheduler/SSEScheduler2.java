package edu.sm.scheduler;

import edu.sm.sse.SseEmitters2;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Component
@RequiredArgsConstructor
@Slf4j
public class SSEScheduler2 {

    private final SseEmitters2 sseEmitters2;
    private final Random random = new Random();


    // 5초마다 임의의 센서 데이터 전송
    @Scheduled(cron = "*/5 * * * * *")
    public void sendSensorData() {
        log.info("[SSE2] 스케줄러 실행됨"); // 확인용h

        Map<String, Object> data = new HashMap<>();
        data.put("temperature", 20 + random.nextInt(10));  // 20~29℃
        data.put("humidity", 40 + random.nextInt(30));     // 40~69%
        data.put("light", 100 + random.nextInt(400));      // 100~499 lux

        log.info("[SSE2] 전송 데이터: {}", data);
        sseEmitters2.broadcast("sensorData", data);
    }

}
