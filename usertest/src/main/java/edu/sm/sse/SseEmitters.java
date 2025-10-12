package edu.sm.sse;

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

    public SseEmitter add(String clientId, SseEmitter emitter) {
        this.emitters.put(clientId, emitter);
        log.info("새로운 클라이언트 접속: {}", clientId);
        emitter.onCompletion(() -> removeEmitter(clientId));
        emitter.onTimeout(() -> removeEmitter(clientId));
        emitter.onError((e) -> removeEmitter(clientId));
        return emitter;
    }

    public void sendToGroup(String group, String eventName, Object data) {
        emitters.forEach((key, emitter) -> {
            if (key.startsWith(group)) {
                sendInternal(key, emitter, eventName, data);
            }
        });
    }

    public void broadcast(String eventName, Object data) {
        emitters.forEach((key, emitter) -> sendInternal(key, emitter, eventName, data));
    }

    private void sendInternal(String clientId, SseEmitter emitter, String eventName, Object data) {
        try {
            emitter.send(SseEmitter.event().name(eventName).data(data));
        } catch (IOException e) {
            log.warn("데이터 전송 실패 - clientId: {}, event: {}, message: {}", clientId, eventName, e.getMessage());
            removeEmitter(clientId);
        }
    }

    private void removeEmitter(String clientId) {
        SseEmitter emitter = emitters.remove(clientId);
        if (emitter != null) {
            try {
                emitter.complete();
            } catch (Exception ignored) {
            }
            log.info("클라이언트 연결 종료: {} (현재 {}명)", clientId, emitters.size());
        }
    }
}