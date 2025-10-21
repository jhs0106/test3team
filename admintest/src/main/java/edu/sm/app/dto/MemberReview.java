package edu.sm.app.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.time.LocalDateTime;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class MemberReview {
    private Long reviewId;
    private Long memberNo;
    private String memberName;
    private String review;
    private LocalDateTime createdAt;
}