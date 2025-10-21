package edu.sm.controller;

import edu.sm.app.dto.OperationMetricSnapshot;
import edu.sm.app.service.OperationMetricService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@RestController
@RequestMapping("/api/operations")
@RequiredArgsConstructor
public class OperationMetricController {

    private final OperationMetricService operationMetricService;

    @GetMapping("/metrics")
    public OperationMetricSnapshot metrics() {
        return operationMetricService.snapshot();
    }

    @GetMapping("/metrics/stream/{clientId}")
    public SseEmitter stream(@PathVariable String clientId) {
        return operationMetricService.connect(clientId);
    }
}