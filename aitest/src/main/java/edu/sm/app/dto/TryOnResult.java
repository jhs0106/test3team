// src/main/java/edu/sm/app/springai/dto4/TryOnResult.java
package edu.sm.app.dto;

import lombok.Data;

@Data
public class TryOnResult {
    private String status;   // queued | running | done | failed
    private String imageB64; // data:image/png;base64,....
    private String message;  // 실패 메시지 등
}
