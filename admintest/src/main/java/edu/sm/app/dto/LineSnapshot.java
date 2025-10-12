package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LineSnapshot {
    private String name;
    private double throughput;
    private double availability;
    private double quality;
    private double temperature;
    private String status;
}