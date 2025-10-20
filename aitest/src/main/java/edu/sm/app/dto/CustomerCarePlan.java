package edu.sm.app.dto;



import java.util.List;

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
public class CustomerCarePlan {
    private String review;
    private ReviewClassification.Sentiment sentiment;
    private String priority;
    private String owner;
    private String automationTrigger;

    private String conciergeNote;
    private List<String> followUpActions;
}