package edu.sm.controller;

import edu.sm.sse.SseEmitters2;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@CrossOrigin(origins = {"https://localhost:8443", "https://127.0.0.1:8443"})
@RestController
@RequiredArgsConstructor
public class SseController {

    private final SseEmitters2 sseEmitters2; // ✅ 핵심: 2번 클래스 주입

    @GetMapping(value = "/sse2/connect/{id}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public ResponseEntity<SseEmitter> connect(@PathVariable("id") String clientId) {
        SseEmitter emitter = new SseEmitter(0L); // 무제한 유지
        sseEmitters2.add(clientId, emitter);

        try {
            emitter.send(SseEmitter.event()
                    .name("connect")
                    .data("connected to sse2: " + clientId));
        } catch (Exception e) {
            emitter.completeWithError(e);
        }

        return ResponseEntity.ok(emitter);
    }
}
