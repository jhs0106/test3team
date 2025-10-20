package edu.sm.app.dto;

import edu.sm.app.dto.ReviewClassification;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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
    private List<String> followUpActions;
}