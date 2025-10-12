package edu.sm.controller;

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
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping(path = "/api/sse", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
@RequiredArgsConstructor
@Slf4j
public class AdminSseController {

    private final SseEmitters sseEmitters;

    @Value("${app.sse.timeout:600000}")
    private long defaultTimeout;

    @CrossOrigin(origins = "*")
    @GetMapping("/dashboard")
    public SseEmitter subscribe(@RequestParam(value = "clientId", required = false) String clientId) {
        String resolvedClientId = resolveClientId(clientId);
        SseEmitter emitter = new SseEmitter(defaultTimeout);
        sseEmitters.add(resolvedClientId, emitter);
        sendConnectionAck(resolvedClientId, emitter);
        return emitter;
    }

    private String resolveClientId(String clientId) {
        if (StringUtils.hasText(clientId)) {
            return clientId;
        }
        return "admin-dashboard-" + UUID.randomUUID();
    }

    private void sendConnectionAck(String clientId, SseEmitter emitter) {
        try {
            emitter.send(SseEmitter.event()
                    .name("connected")
                    .data(Map.of(
                            "clientId", clientId,
                            "timestamp", Instant.now().toString()
                    )));
        } catch (IOException e) {
            log.warn("SSE 초기화 메시지 전송 실패 - clientId: {}, message: {}", clientId, e.getMessage());
        }
    }
}