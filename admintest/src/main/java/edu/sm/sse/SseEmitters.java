package edu.sm.sse;

import edu.sm.app.dto.AdminMsg;
import edu.sm.app.dto.DashboardMetrics;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class SseEmitters {
    private final Map<String, SseEmitter> emitters = new ConcurrentHashMap<>();

    public void sendData(AdminMsg adminMsg) {
        sendEvent("adminmsg", adminMsg);
    }

    public void count(int num) {
        sendEvent("count", num);
    }

    public void sendDashboard(DashboardMetrics metrics) {
        sendEvent("dashboard", metrics);
    }

    private void sendEvent(String eventName, Object payload) {
        emitters.forEach((clientId, emitter) -> {
            try {
                emitter.send(SseEmitter.event()
                        .name(eventName)
                        .data(payload));
            } catch (IOException e) {
                log.warn("SSE 전송 실패 - clientId: {}, event: {}, message: {}", clientId, eventName, e.getMessage());
                emitters.remove(clientId);
                cleanupEmitter(emitter);
            }
        });
    }
    public SseEmitter add(String clientId, SseEmitter emitter) {
        this.emitters.put(clientId,emitter);
        log.info("new emitter added: {}", emitter);
        log.info("emitter list size: {}", emitters.size());

        // 연결 완료, 오류, 타임아웃 이벤트 핸들러 등록
        emitter.onCompletion(() -> {
            emitters.remove(clientId);
            cleanupEmitter(emitter);
        });
        emitter.onError((ex) -> {
            emitters.remove(clientId);
            cleanupEmitter(emitter);
        });
        emitter.onTimeout(() -> {
            emitters.remove(clientId);
            cleanupEmitter(emitter);
        });
        return emitter;
    }
    private void cleanupEmitter(SseEmitter emitter) {
        try {
            emitter.complete();
        } catch (Exception e) {
            // 예외 처리
        }
    }
}