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
import java.util.*;
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
    private final AtomicInteger chartRequests = new AtomicInteger();
    private final AtomicInteger chartFailures = new AtomicInteger();
    private final AtomicInteger chatMessages = new AtomicInteger();

    private final Map<String, Instant> activeUsers = new ConcurrentHashMap<>();
    private final Map<String, ChartSymbolStat> chartBySymbol = new ConcurrentHashMap<>();
    private final Map<String, AtomicInteger> chatByRoom = new ConcurrentHashMap<>();

    private final Deque<TrendEntry> loginTrend = new ArrayDeque<>();
    private final Deque<TrendEntry> chartTrend = new ArrayDeque<>();
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

    public void recordChartRequest(String symbol, String displayName, boolean success,
                                   Double price, Double changePercent, Long volume, Double marketCap) {
        chartRequests.incrementAndGet();
        if (!success) {
            chartFailures.incrementAndGet();
        }
        if (symbol != null && !symbol.isBlank()) {
            String normalized = symbol.toUpperCase();
            chartBySymbol.computeIfAbsent(normalized, ChartSymbolStat::new)
                    .update(displayName, success, price, changePercent, volume, marketCap);
        }
        appendTrend(chartTrend, chartRequests.get());
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
                        .name("차트 조회")
                        .y(chartRequests.get())
                        .drilldown("charts")
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
                        .id("charts")
                        .name("종목별 조회")
                        .data(toChartDataPoints())
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
                .chartRequests(chartRequests.get())
                .chartFailures(chartFailures.get())
                .chatMessages(chatMessages.get())
                .activeUserIds(activeIds)
                .overview(overview)
                .drilldown(drilldownSeries)
                .alerts(alerts)
                .chartHighlights(buildChartHighlights())
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

    private List<OperationMetricSnapshot.DataPoint> toChartDataPoints() {
        return chartBySymbol.values().stream()
                .sorted(chartComparator())
                .limit(12)
                .map(stat -> OperationMetricSnapshot.DataPoint.builder()
                        .name(stat.symbol())
                        .y(stat.requestCount())
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

    private Comparator<ChartSymbolStat> chartComparator() {
        return Comparator.comparingInt(ChartSymbolStat::requestCount)
                .reversed()
                .thenComparing(ChartSymbolStat::symbol);
    }

    private List<OperationMetricSnapshot.ChartHighlight> buildChartHighlights() {
        return chartBySymbol.values().stream()
                .sorted(chartComparator())
                .limit(5)
                .map(stat -> OperationMetricSnapshot.ChartHighlight.builder()
                        .symbol(stat.symbol())
                        .name(stat.displayName())
                        .requestCount(stat.requestCount())
                        .lastPrice(stat.lastPrice())
                        .changePercent(stat.changePercent())
                        .volume(stat.volume())
                        .marketCap(stat.marketCap())
                        .trend(stat.trend())
                        .updatedAt(stat.updatedAt())
                        .build())
                .toList();
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
        double failureRate = chartRequests.get() == 0 ? 0.0 : (double) chartFailures.get() / chartRequests.get();
        if (failureRate > 0.3) {
            alerts.add(OperationAlert.builder()
                    .level("danger")
                    .message(String.format("차트 조회 실패율 %.0f%% - API 점검 필요", failureRate * 100))
                    .timestamp(Instant.now())
                    .build());
        } else if (failureRate > 0.15) {
            alerts.add(OperationAlert.builder()
                    .level("warning")
                    .message(String.format("차트 조회 실패율 %.0f%% - 추적 권장", failureRate * 100))
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

    private static class ChartSymbolStat {
        private final String symbol;
        private final AtomicInteger requestCount = new AtomicInteger();
        private volatile String displayName;
        private volatile double lastPrice;
        private volatile double changePercent;
        private volatile long volume;
        private volatile double marketCap;
        private volatile String trend = "flat";
        private volatile Instant updatedAt;

        private ChartSymbolStat(String symbol) {
            this.symbol = symbol;
        }

        private void update(String name, boolean success, Double price, Double changePercent,
                            Long volume, Double marketCap) {
            requestCount.incrementAndGet();
            if (!success) {
                return;
            }
            if (name != null && !name.isBlank()) {
                this.displayName = name;
            }
            if (price != null) {
                this.lastPrice = price;
            }
            if (changePercent != null) {
                this.changePercent = changePercent;
                this.trend = changePercent > 0 ? "up" : changePercent < 0 ? "down" : "flat";
            }
            if (volume != null) {
                this.volume = volume;
            }
            if (marketCap != null) {
                this.marketCap = marketCap;
            }
            this.updatedAt = Instant.now();
        }

        private String symbol() {
            return symbol;
        }

        private int requestCount() {
            return requestCount.get();
        }

        private String displayName() {
            return displayName != null && !displayName.isBlank() ? displayName : symbol;
        }

        private double lastPrice() {
            return lastPrice;
        }

        private double changePercent() {
            return changePercent;
        }

        private long volume() {
            return volume;
        }

        private double marketCap() {
            return marketCap;
        }

        private String trend() {
            return trend;
        }

        private Instant updatedAt() {
            return updatedAt;
        }
    }

    private record TrendEntry(Instant timestamp, double value) { }
}
