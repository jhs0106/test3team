package edu.sm.app.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import edu.sm.app.dto.DashboardMetrics;
import edu.sm.sse.SseEmitters;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.MediaType;
import org.springframework.http.codec.ServerSentEvent;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;
import reactor.core.Disposable;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

@Service
@Slf4j
@RequiredArgsConstructor
public class AdminDashboardSseBridge {

    private final WebClient adminSseWebClient;
    private final ObjectMapper objectMapper;
    private final SseEmitters sseEmitters;

    @Value("${app.url.adminUpstreamSse:https://localhost:8444/api/sse/dashboard}")
    private String adminSseUrl;

    @Value("${app.sse.retryDelaySeconds:5}")
    private long retryDelaySeconds;

    private final AtomicReference<DashboardMetrics> latestMetrics = new AtomicReference<>();
    private final AtomicReference<Instant> lastEventTimestamp = new AtomicReference<>();
    private final AtomicBoolean upstreamConnected = new AtomicBoolean(false);

    private final ScheduledExecutorService reconnectExecutor = Executors.newSingleThreadScheduledExecutor(r -> {
        Thread thread = new Thread(r, "admin-sse-bridge");
        thread.setDaemon(true);
        return thread;
    });

    private volatile Disposable subscription;

    @PostConstruct
    public void init() {
        reconnectExecutor.execute(this::connectToUpstream);
    }

    @PreDestroy
    public void shutdown() {
        if (subscription != null && !subscription.isDisposed()) {
            subscription.dispose();
        }
        reconnectExecutor.shutdownNow();
    }

    public Optional<DashboardMetrics> latestMetrics() {
        return Optional.ofNullable(latestMetrics.get());
    }

    public Optional<Instant> lastEventTimestamp() {
        return Optional.ofNullable(lastEventTimestamp.get());
    }

    public Map<String, Object> upstreamStatusSnapshot() {
        Map<String, Object> payload = new HashMap<>();
        payload.put("connected", upstreamConnected.get());
        payload.put("timestamp", Instant.now().toString());
        lastEventTimestamp().ifPresent(instant -> payload.put("lastEventTimestamp", instant.toString()));
        return payload;
    }

    private synchronized void connectToUpstream() {
        disposeSubscription();

        String clientId = "usertest-bridge-" + UUID.randomUUID();
        String targetUrl = UriComponentsBuilder.fromUriString(adminSseUrl)
                .queryParam("clientId", clientId)
                .build(true)
                .toUriString();

        updateUpstreamState(false);
        log.info("관리자 SSE 연결 시도: {}", targetUrl);

        var flux = adminSseWebClient.get()
                .uri(targetUrl)
                .accept(MediaType.TEXT_EVENT_STREAM)
                .retrieve()
                .bodyToFlux(new ParameterizedTypeReference<ServerSentEvent<String>>() {})
                .doOnSubscribe(sub -> log.info("관리자 SSE 스트림 구독 시작: {}", targetUrl));

        subscription = flux.subscribe(this::handleEvent, this::handleError, this::handleComplete);
    }

    private void disposeSubscription() {
        if (subscription != null && !subscription.isDisposed()) {
            subscription.dispose();
        }
        subscription = null;
    }

    private void handleEvent(ServerSentEvent<String> event) {
        if (event == null) {
            return;
        }
        String eventName = event.event();
        if (!StringUtils.hasText(eventName)) {
            eventName = "message";
        }
        switch (eventName) {
            case "dashboard" -> handleDashboardEvent(event.data());
            case "connected" -> {
                updateUpstreamState(true);
                log.info("관리자 SSE 연결 확인: {}", event.data());
            }
            default -> log.debug("관리자 SSE 이벤트 수신 - event: {}, data: {}", eventName, event.data());
        }
    }

    private void handleDashboardEvent(String data) {
        DashboardMetrics metrics = parseMetrics(data);
        if (metrics == null) {
            return;
        }
        latestMetrics.set(metrics);
        lastEventTimestamp.set(Optional.ofNullable(metrics.getTimestamp()).orElseGet(Instant::now));
        if (upstreamConnected.compareAndSet(false, true)) {
            broadcastUpstreamStatus();
        }
        sseEmitters.broadcast("dashboard", metrics);
    }

    private DashboardMetrics parseMetrics(String data) {
        if (!StringUtils.hasText(data)) {
            return null;
        }
        try {
            return objectMapper.readValue(data, DashboardMetrics.class);
        } catch (JsonProcessingException e) {
            log.warn("대시보드 메트릭 파싱 실패: {}", e.getMessage());
            return null;
        }
    }

    private void handleError(Throwable throwable) {
        log.warn("관리자 SSE 스트림 오류: {}", throwable.toString());
        updateUpstreamState(false);
        scheduleReconnect();
    }

    private void handleComplete() {
        log.info("관리자 SSE 스트림이 종료되었습니다. 재연결을 시도합니다.");
        updateUpstreamState(false);
        scheduleReconnect();
    }

    private void scheduleReconnect() {
        long delay = Math.max(1L, retryDelaySeconds);
        reconnectExecutor.schedule(this::connectToUpstream, delay, TimeUnit.SECONDS);
    }

    private void updateUpstreamState(boolean connected) {
        boolean previous = upstreamConnected.getAndSet(connected);
        if (previous != connected) {
            broadcastUpstreamStatus();
        } else if (!connected) {
            broadcastUpstreamStatus();
        }
    }

    private void broadcastUpstreamStatus() {
        sseEmitters.broadcast("upstream-status", upstreamStatusSnapshot());
    }
}