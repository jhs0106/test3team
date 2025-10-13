package edu.sm.sse;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class SseEmitters2 {

    private final Map<String, SseEmitter> emitters = new ConcurrentHashMap<>();

    public SseEmitter add(String clientId, SseEmitter emitter) {
        emitters.put(clientId, emitter);
        log.info("[SSE2] 새 연결 추가 : {}, 현재 연결 수: {}", clientId, emitters.size());

        emitter.onCompletion(() -> remove(clientId));
        emitter.onTimeout(() -> remove(clientId));
        emitter.onError((ex) -> remove(clientId));
        return emitter;
    }

    public void remove(String clientId) {
        emitters.remove(clientId);
        log.info("[SSE2] 연결 종료: {}, 남은 연결 수: {}", clientId, emitters.size());
    }

    public void broadcast(String eventName, Object data) {
        emitters.forEach((id, emitter) -> {
            try {
                emitter.send(SseEmitter.event()
                        .name(eventName)
                        .data(data));
            } catch (IOException e) {
                log.error("[SSE2] 전송 실패 → 연결 제거됨: {}", id);
                remove(id);
            }
        });
    }
}
