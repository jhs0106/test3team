package edu.sm.controller;

import edu.sm.app.dto.DashboardMetrics;
import edu.sm.app.service.AdminDashboardSseBridge;
import edu.sm.sse.SseEmitters;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping(path = "/api/sse", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
@RequiredArgsConstructor
@Slf4j
public class AdminSseProxyController {

    private final SseEmitters sseEmitters;
    private final AdminDashboardSseBridge dashboardSseBridge;

    @Value("${app.sse.timeout:600000}")
    private long defaultTimeout;

    @CrossOrigin(origins = "*")
    @GetMapping("/dashboard")
    public SseEmitter subscribe(@RequestParam(value = "clientId", required = false) String clientId) {
        String resolvedClientId = resolveClientId(clientId);
        SseEmitter emitter = new SseEmitter(defaultTimeout);
        sseEmitters.add(resolvedClientId, emitter);

        Map<String, Object> upstreamStatus = dashboardSseBridge.upstreamStatusSnapshot();
        sendConnectionAck(emitter, resolvedClientId, upstreamStatus);
        sendUpstreamStatus(emitter, upstreamStatus);
        sendLatestSnapshot(emitter);

        return emitter;
    }

    private String resolveClientId(String clientId) {
        if (StringUtils.hasText(clientId)) {
            return clientId;
        }
        return "dashboard-" + UUID.randomUUID();
    }

    private void sendConnectionAck(SseEmitter emitter, String clientId, Map<String, Object> upstreamStatus) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("clientId", clientId);
        payload.put("timestamp", Instant.now().toString());
        payload.put("upstreamConnected", upstreamStatus.get("connected"));
        try {
            emitter.send(SseEmitter.event()
                    .name("connected")
                    .data(payload));
        } catch (IOException e) {
            log.warn("SSE 연결 확인 이벤트 전송 실패 - clientId: {}, message: {}", clientId, e.getMessage());
        }
    }

    private void sendUpstreamStatus(SseEmitter emitter, Map<String, Object> upstreamStatus) {
        try {
            emitter.send(SseEmitter.event()
                    .name("upstream-status")
                    .data(upstreamStatus));
        } catch (IOException e) {
            log.warn("업스트림 상태 전달 실패: {}", e.getMessage());
        }
    }

    private void sendLatestSnapshot(SseEmitter emitter) {
        dashboardSseBridge.latestMetrics()
                .ifPresent(metrics -> sendDashboard(emitter, metrics));
    }

    private void sendDashboard(SseEmitter emitter, DashboardMetrics metrics) {
        try {
            emitter.send(SseEmitter.event()
                    .name("dashboard")
                    .data(metrics));
        } catch (IOException e) {
            log.warn("초기 대시보드 데이터 전송 실패: {}", e.getMessage());
        }
    }
}