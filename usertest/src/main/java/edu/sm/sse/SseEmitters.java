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
        emitter.onCompletion(() -> this.emitters.remove(clientId));
        emitter.onTimeout(() -> this.emitters.remove(clientId));
        emitter.onError((e) -> this.emitters.remove(clientId));
        return emitter;
    }

    public void sendToGroup(String group, String eventName, Object data) {
        emitters.forEach((key, emitter) -> {
            if (key.startsWith(group)) {
                try {
                    emitter.send(SseEmitter.event().name(eventName).data(data));
                } catch (IOException e) {
                    log.error("데이터 전송 오류 clientId: {}, error: {}", key, e.getMessage());
                }
            }
        });
    }
}