package edu.sm.app.service;

import edu.sm.app.dto.AlertMessage;
import edu.sm.app.dto.DashboardMetrics;
import edu.sm.app.dto.FacilitySnapshot;
import edu.sm.app.dto.LineSnapshot;
import edu.sm.app.dto.ProductionSummary;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@Service
@Slf4j
public class DashboardMetricsGenerator {

    private static final List<String> FACILITY_NAMES = List.of("Alpha Cell", "Beta Cell", "Gamma Line");
    private static final List<String> LINE_SUFFIX = List.of("Robot #1", "Robot #2", "Inspection", "Packaging", "Assembly");

    public DashboardMetrics generateSnapshot() {
        ThreadLocalRandom random = ThreadLocalRandom.current();

        List<FacilitySnapshot> facilities = FACILITY_NAMES.stream()
                .map(name -> buildFacilitySnapshot(name, random))
                .collect(Collectors.toList());

        ProductionSummary summary = buildSummary(facilities, random);
        List<AlertMessage> alerts = buildAlerts(facilities, summary);

        return DashboardMetrics.builder()
                .timestamp(Instant.now())
                .facilities(facilities)
                .summary(summary)
                .alerts(alerts)
                .build();
    }

    private FacilitySnapshot buildFacilitySnapshot(String name, ThreadLocalRandom random) {
        int lineCount = random.nextInt(3, 5);
        List<LineSnapshot> lines = new ArrayList<>();
        for (int i = 0; i < lineCount; i++) {
            String lineName = name + " " + LINE_SUFFIX.get(i % LINE_SUFFIX.size());
            lines.add(buildLineSnapshot(lineName, random));
        }

        double throughput = lines.stream().mapToDouble(LineSnapshot::getThroughput).sum();
        double availability = lines.stream().mapToDouble(LineSnapshot::getAvailability).average().orElse(0);
        double quality = lines.stream().mapToDouble(LineSnapshot::getQuality).average().orElse(0);
        double energyUsage = lines.stream().mapToDouble(LineSnapshot::getThroughput).sum() * random.nextDouble(0.8, 1.2);

        return FacilitySnapshot.builder()
                .name(name)
                .throughput(throughput)
                .availability(availability)
                .quality(quality)
                .energyUsage(energyUsage)
                .lines(lines)
                .build();
    }

    private LineSnapshot buildLineSnapshot(String name, ThreadLocalRandom random) {
        double availability = random.nextDouble(72, 99);
        double quality = random.nextDouble(88, 100);
        double throughput = random.nextDouble(45, 140);
        double temperature = random.nextDouble(35, 90);
        String status = resolveStatus(availability, quality, temperature);

        return LineSnapshot.builder()
                .name(name)
                .availability(availability)
                .quality(quality)
                .throughput(throughput)
                .temperature(temperature)
                .status(status)
                .build();
    }

    private String resolveStatus(double availability, double quality, double temperature) {
        if (quality < 90 || availability < 78 || temperature > 82) {
            return "CRITICAL";
        }
        if (quality < 94 || availability < 86 || temperature > 74) {
            return "WARNING";
        }
        return "NORMAL";
    }

    private ProductionSummary buildSummary(List<FacilitySnapshot> facilities, ThreadLocalRandom random) {
        double totalThroughput = facilities.stream().mapToDouble(FacilitySnapshot::getThroughput).sum();
        double avgAvailability = facilities.stream().mapToDouble(FacilitySnapshot::getAvailability).average().orElse(0);
        double avgQuality = facilities.stream().mapToDouble(FacilitySnapshot::getQuality).average().orElse(0);
        double energy = facilities.stream().mapToDouble(FacilitySnapshot::getEnergyUsage).sum();

        long warningCount = facilities.stream()
                .flatMap(facility -> facility.getLines().stream())
                .filter(line -> "WARNING".equals(line.getStatus()))
                .count();
        long criticalCount = facilities.stream()
                .flatMap(facility -> facility.getLines().stream())
                .filter(line -> "CRITICAL".equals(line.getStatus()))
                .count();

        double downtimeBase = criticalCount * random.nextDouble(8, 15) + warningCount * random.nextDouble(2, 5);
        double downtime = Math.min(120, downtimeBase);
        double defectRate = Math.max(0, 100 - avgQuality);

        return ProductionSummary.builder()
                .totalThroughput(totalThroughput)
                .averageAvailability(avgAvailability)
                .averageQuality(avgQuality)
                .energyConsumption(energy)
                .downtimeMinutes(downtime)
                .defectRate(defectRate)
                .warningCount(warningCount)
                .criticalCount(criticalCount)
                .build();
    }

    private List<AlertMessage> buildAlerts(List<FacilitySnapshot> facilities, ProductionSummary summary) {
        List<AlertMessage> alerts = facilities.stream()
                .flatMap(facility -> facility.getLines().stream()
                        .filter(line -> !"NORMAL".equals(line.getStatus()))
                        .map(line -> AlertMessage.builder()
                                .level("CRITICAL".equals(line.getStatus()) ? "CRITICAL" : "WARNING")
                                .source(facility.getName() + " - " + line.getName())
                                .message(buildLineAlertMessage(line))
                                .build()))
                .collect(Collectors.toCollection(ArrayList::new));

        if (summary.getDowntimeMinutes() > 45) {
            alerts.add(AlertMessage.builder()
                    .level("WARNING")
                    .source("Scheduler")
                    .message(String.format("누적 비가동 시간이 %.0f분으로 증가했습니다.", summary.getDowntimeMinutes()))
                    .build());
        }
        if (summary.getCriticalCount() > 0) {
            alerts.add(AlertMessage.builder()
                    .level("CRITICAL")
                    .source("Operations")
                    .message(String.format("중요 설비 경보 %d건이 감지되었습니다.", summary.getCriticalCount()))
                    .build());
        }
        if (alerts.isEmpty()) {
            alerts.add(AlertMessage.builder()
                    .level("INFO")
                    .source("System")
                    .message("현재 모든 설비가 정상적으로 동작 중입니다.")
                    .build());
        }
        return alerts;
    }

    private String buildLineAlertMessage(LineSnapshot line) {
        return String.format("%s - 가동률 %.1f%%, 품질 %.1f%%, 온도 %.1f°C", line.getStatus(), line.getAvailability(), line.getQuality(), line.getTemperature());
    }
}