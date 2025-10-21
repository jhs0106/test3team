package edu.sm.app.dto;

import lombok.Data;

@Data
public class TryOnRequest {
    private String garmentId;
    private String colorHex;
    private Double brightness; // -1.0 ~ 1.0
    private Double saturation; // -1.0 ~ 1.0
}

