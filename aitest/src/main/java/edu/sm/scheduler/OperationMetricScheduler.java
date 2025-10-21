package edu.sm.scheduler;

import edu.sm.app.service.OperationMetricService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class OperationMetricScheduler {

    private final OperationMetricService operationMetricService;

    @Scheduled(fixedRate = 5000)
    public void pushHeartbeat() {
        operationMetricService.broadcast();
    }
}