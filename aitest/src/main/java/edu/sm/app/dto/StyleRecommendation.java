// src/main/java/edu/sm/app/springai/dto4/StyleRecommendation.java
package edu.sm.app.dto;

import lombok.Data;
import java.util.List;

@Data
public class StyleRecommendation {
    private List<String> rules;
    private List<GarmentItem> tops;
    private List<GarmentItem> bottoms;
    private List<GarmentItem> outer;
    private List<GarmentItem> onepiece;

    @Data
    public static class GarmentItem {
        private String id;       // "T101"
        private String name;     // "soft boatneck tee"
        private String category; // "top"
        private String hex;      // "#E6EEF7"
        private String fit;      // "relaxed"
        private String neck;     // "boatneck"
        private String reason;   // 추천 이유
    }
}
