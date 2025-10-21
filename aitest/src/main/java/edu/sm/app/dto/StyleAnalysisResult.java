package edu.sm.app.dto;

import lombok.Data;
import java.util.List;

@Data
public class StyleAnalysisResult {
    private String tone;          // ex) summer-light
    private String contrast;      // low / medium / high
    private String faceShape;     // oval / square / heart ...
    private String mood;          // soft-cool 등
    private List<String> palette; // HEX list
    private Quality quality;      // 노출/화이트밸런스 등

    @Data
    public static class Quality {
        private double exposure;
        private double whiteBalance;
        private boolean needsRetake;
    }
}

