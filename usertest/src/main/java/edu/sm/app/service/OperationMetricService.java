package edu.sm.app.service;

import edu.sm.app.dto.OperationAlert;
import edu.sm.app.dto.OperationMetricSnapshot;
import edu.sm.sse.SseEmitters;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Deque;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

@Service
@Slf4j
@RequiredArgsConstructor
public class OperationMetricService {

    private static final String GROUP_KEY = "operation";
    private static final int MAX_TREND_SIZE = 12;
    private static final DateTimeFormatter TIME_FORMATTER =
            DateTimeFormatter.ofPattern("HH:mm:ss").withZone(ZoneId.systemDefault());

    private final SseEmitters sseEmitters;

    private final AtomicInteger totalLogins = new AtomicInteger();
    private final AtomicInteger stockRequests = new AtomicInteger();
    private final AtomicInteger stockFailures = new AtomicInteger();
    private final AtomicInteger chatMessages = new AtomicInteger();

    private final Map<String, Instant> activeUsers = new ConcurrentHashMap<>();
    private final Map<String, AtomicInteger> stockBySymbol = new ConcurrentHashMap<>();
    private final Map<String, AtomicInteger> chatByRoom = new ConcurrentHashMap<>();

    private final Deque<TrendEntry> loginTrend = new ArrayDeque<>();
    private final Deque<TrendEntry> stockTrend = new ArrayDeque<>();
    private final Deque<TrendEntry> chatTrend = new ArrayDeque<>();

    public SseEmitter connect(String clientId) {
        SseEmitter emitter = new SseEmitter(0L);
        String key = buildKey(clientId);
        sseEmitters.add(key, emitter);
        try {
            emitter.send(SseEmitter.event().name("connect").data("connected"));
            emitter.send(SseEmitter.event().name("metrics").data(snapshot()));
        } catch (IOException e) {
            log.error("SSE 초기 전송 실패", e);
            emitter.completeWithError(e);
        }
        return emitter;
    }

    public void recordLogin(String userId) {
        if (userId == null || userId.isBlank()) {
            return;
        }
        totalLogins.incrementAndGet();
        activeUsers.put(userId, Instant.now());
        appendTrend(loginTrend, activeUsers.size());
        broadcast();
    }

    public void recordLogout(String userId) {
        if (userId == null || userId.isBlank()) {
            return;
        }
        activeUsers.remove(userId);
        appendTrend(loginTrend, activeUsers.size());
        broadcast();
    }

    public void recordStockRequest(String symbol, boolean success) {
        stockRequests.incrementAndGet();
        if (!success) {
            stockFailures.incrementAndGet();
        }
        if (symbol != null && !symbol.isBlank()) {
            stockBySymbol.computeIfAbsent(symbol.toUpperCase(), k -> new AtomicInteger()).incrementAndGet();
        }
        appendTrend(stockTrend, stockRequests.get());
        broadcast();
    }

    public void recordChatMessage(String roomId) {
        chatMessages.incrementAndGet();
        if (roomId != null && !roomId.isBlank()) {
            chatByRoom.computeIfAbsent(roomId, k -> new AtomicInteger()).incrementAndGet();
        }
        appendTrend(chatTrend, chatMessages.get());
        broadcast();
    }

    public void broadcast() {
        OperationMetricSnapshot snapshot = snapshot();
        sseEmitters.sendToGroup(GROUP_KEY, "metrics", snapshot);
    }

    public OperationMetricSnapshot snapshot() {
        purgeInactiveUsers();
        List<String> activeIds = activeUsers.keySet().stream()
                .sorted()
                .limit(10)
                .toList();

        List<OperationMetricSnapshot.SeriesPoint> overview = List.of(
                OperationMetricSnapshot.SeriesPoint.builder()
                        .name("실시간 접속자")
                        .y(activeUsers.size())
                        .drilldown("logins")
                        .build(),
                OperationMetricSnapshot.SeriesPoint.builder()
                        .name("주가 조회")
                        .y(stockRequests.get())
                        .drilldown("stocks")
                        .build(),
                OperationMetricSnapshot.SeriesPoint.builder()
                        .name("채팅 메시지")
                        .y(chatMessages.get())
                        .drilldown("chats")
                        .build()
        );

        List<OperationMetricSnapshot.DrilldownSeries> drilldownSeries = List.of(
                OperationMetricSnapshot.DrilldownSeries.builder()
                        .id("logins")
                        .name("시간대별 접속자")
                        .data(toDataPoints(loginTrend))
                        .build(),
                OperationMetricSnapshot.DrilldownSeries.builder()
                        .id("stocks")
                        .name("종목별 조회")
                        .data(toSymbolDataPoints())
                        .build(),
                OperationMetricSnapshot.DrilldownSeries.builder()
                        .id("chats")
                        .name("채팅방별 메시지")
                        .data(toRoomDataPoints())
                        .build()
        );

        List<OperationAlert> alerts = evaluateAlerts();

        return OperationMetricSnapshot.builder()
                .timestamp(Instant.now())
                .totalLogins(totalLogins.get())
                .activeUsers(activeUsers.size())
                .stockRequests(stockRequests.get())
                .stockFailures(stockFailures.get())
                .chatMessages(chatMessages.get())
                .activeUserIds(activeIds)
                .overview(overview)
                .drilldown(drilldownSeries)
                .alerts(alerts)
                .build();
    }

    private List<OperationMetricSnapshot.DataPoint> toDataPoints(Deque<TrendEntry> trend) {
        return trend.stream()
                .map(entry -> OperationMetricSnapshot.DataPoint.builder()
                        .name(TIME_FORMATTER.format(entry.timestamp()))
                        .y(entry.value())
                        .build())
                .toList();
    }

    private List<OperationMetricSnapshot.DataPoint> toSymbolDataPoints() {
        return stockBySymbol.entrySet().stream()
                .sorted(symbolComparator())
                .limit(12)
                .map(entry -> OperationMetricSnapshot.DataPoint.builder()
                        .name(entry.getKey())
                        .y(entry.getValue().get())
                        .build())
                .toList();
    }

    private List<OperationMetricSnapshot.DataPoint> toRoomDataPoints() {
        return chatByRoom.entrySet().stream()
                .sorted(roomComparator())
                .limit(12)
                .map(entry -> OperationMetricSnapshot.DataPoint.builder()
                        .name(entry.getKey())
                        .y(entry.getValue().get())
                        .build())
                .toList();
    }

    private Comparator<Map.Entry<String, AtomicInteger>> symbolComparator() {
        return Comparator.<Map.Entry<String, AtomicInteger>>comparingInt(entry -> entry.getValue().get())
                .reversed()
                .thenComparing(Map.Entry::getKey);
    }

    private Comparator<Map.Entry<String, AtomicInteger>> roomComparator() {
        return Comparator.<Map.Entry<String, AtomicInteger>>comparingInt(entry -> entry.getValue().get())
                .reversed()
                .thenComparing(Map.Entry::getKey);
    }

    private void appendTrend(Deque<TrendEntry> trend, int value) {
        trend.addLast(new TrendEntry(Instant.now(), value));
        while (trend.size() > MAX_TREND_SIZE) {
            trend.removeFirst();
        }
    }

    private void purgeInactiveUsers() {
        Instant now = Instant.now();
        activeUsers.entrySet().removeIf(entry -> entry.getValue().isBefore(now.minusSeconds(900)));
    }

    private List<OperationAlert> evaluateAlerts() {
        List<OperationAlert> alerts = new ArrayList<>();
        double failureRate = stockRequests.get() == 0 ? 0.0 : (double) stockFailures.get() / stockRequests.get();
        if (failureRate > 0.3) {
            alerts.add(OperationAlert.builder()
                    .level("danger")
                    .message(String.format("주가 조회 실패율 %.0f%% - API 점검 필요", failureRate * 100))
                    .timestamp(Instant.now())
                    .build());
        } else if (failureRate > 0.15) {
            alerts.add(OperationAlert.builder()
                    .level("warning")
                    .message(String.format("주가 조회 실패율 %.0f%% - 추적 권장", failureRate * 100))
                    .timestamp(Instant.now())
                    .build());
        }

        if (activeUsers.size() > 20) {
            alerts.add(OperationAlert.builder()
                    .level("info")
                    .message(String.format("동시 접속자 %d명 - 서버 부하 모니터링", activeUsers.size()))
                    .timestamp(Instant.now())
                    .build());
        }

        if (chatMessages.get() > 0 && chatTrend.peekLast() != null && chatTrend.peekLast().value() > 200) {
            alerts.add(OperationAlert.builder()
                    .level("warning")
                    .message("채팅 메시지 폭주 감지 - 상담 인력 확인")
                    .timestamp(Instant.now())
                    .build());
        }
        return alerts;
    }

    private String buildKey(String clientId) {
        return GROUP_KEY + "-" + clientId;
    }

    private record TrendEntry(Instant timestamp, double value) { }
}