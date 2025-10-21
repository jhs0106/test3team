package edu.sm.app.dto;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.time.LocalDateTime;
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
    private Integer rating;
    private String review;
    private String careResponse;

    @JsonIgnore
    private String sentiment;

    private LocalDateTime createdAt;
}