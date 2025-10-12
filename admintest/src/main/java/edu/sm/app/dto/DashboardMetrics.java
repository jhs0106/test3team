package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardMetrics {
    private Instant timestamp;
    private List<FacilitySnapshot> facilities;
    private ProductionSummary summary;
    private List<AlertMessage> alerts;
}