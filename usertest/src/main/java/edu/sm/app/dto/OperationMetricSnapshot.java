package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.List;

@Getter
@Builder
@AllArgsConstructor
public class OperationMetricSnapshot {
    private final Instant timestamp;
    private final int totalLogins;
    private final int activeUsers;
    private final int chartRequests;
    private final int chartFailures;
    private final int chatMessages;
    private final List<String> activeUserIds;
    private final List<SeriesPoint> overview;
    private final List<DrilldownSeries> drilldown;
    private final List<OperationAlert> alerts;
    private final List<ChartHighlight> chartHighlights;

    @Getter
    @Builder
    @AllArgsConstructor
    public static class SeriesPoint {
        private final String name;
        private final double y;
        private final String drilldown;
    }

    @Getter
    @Builder
    @AllArgsConstructor
    public static class DrilldownSeries {
        private final String id;
        private final String name;
        private final List<DataPoint> data;
    }

    @Getter
    @Builder
    @AllArgsConstructor
    public static class DataPoint {
        private final String name;
        private final double y;
    }

    @Getter
    @Builder
    @AllArgsConstructor
    public static class ChartHighlight {
        private final String symbol;
        private final String name;
        private final long requestCount;
        private final double lastPrice;
        private final double changePercent;
        private final long volume;
        private final double marketCap;
        private final String trend;
        private final Instant updatedAt;
    }
}