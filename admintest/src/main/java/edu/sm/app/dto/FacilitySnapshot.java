package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FacilitySnapshot {
    private String name;
    private double throughput;
    private double availability;
    private double quality;
    private double energyUsage;
    private List<LineSnapshot> lines;
}