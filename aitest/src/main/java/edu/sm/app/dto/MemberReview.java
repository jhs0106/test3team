package edu.sm.app.dto;

import java.time.LocalDateTime;

import edu.sm.app.dto.ReviewClassification.Sentiment;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.ibatis.annotations.Mapper;

@Mapper
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MemberReview {
    private Long reviewId;
    private Long memberNo;
    private String memberName;
    private String review;
    private Sentiment sentiment;
    private LocalDateTime createdAt;
}