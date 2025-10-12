package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductionSummary {
    private double totalThroughput;
    private double averageAvailability;
    private double averageQuality;
    private double energyConsumption;
    private double downtimeMinutes;
    private double defectRate;
    private long warningCount;
    private long criticalCount;
}