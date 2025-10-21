package edu.sm.app.dto;

import lombok.Data;

@Data
public class TryOnRequest {
    private String garmentId;   // 기존 필드
    private String colorHex;    // 기존 필드

    // 🔹 새로 추가
    private String gender;      // "male" or "female"
    private String category;    // "tops", "bottoms", "outer", "onepiece"

    // (선택) 밝기, 채도 조정용
    private double brightness;
    private double saturation;
}