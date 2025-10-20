package edu.sm.app.service;

import edu.sm.app.dto.CustomerCarePlan;
import edu.sm.app.dto.ReviewClassification;
import edu.sm.app.springai.service2.AiServiceSystemMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CustomerCareService {

    private final AiServiceSystemMessage aiServiceSystemMessage;

    public CustomerCarePlan handleFeedback(String feedback) {
        ReviewClassification classification = aiServiceSystemMessage.classifyReview(feedback);
        if (classification == null) {
            classification = new ReviewClassification();
        }

        ReviewClassification.Sentiment sentiment = Optional
                .ofNullable(classification.getClassification())
                .orElse(ReviewClassification.Sentiment.NEUTRAL);

        String normalizedReview = Optional
                .ofNullable(classification.getReview())
                .filter(review -> !review.isBlank())
                .orElse(feedback);

        return buildPlan(normalizedReview, sentiment);
    }

    private CustomerCarePlan buildPlan(String review, ReviewClassification.Sentiment sentiment) {
        String priority;
        String owner;
        String automationTrigger;
        List<String> followUpActions;

        switch (sentiment) {
            case POSITIVE -> {
                priority = "LOW";
                owner = "Community Team";
                automationTrigger = "send-appreciation-workflow";
                followUpActions = List.of(
                        "Send a personalized thank-you message",
                        "Log the feedback in the success stories dashboard",
                        "Share highlights with the marketing team"
                );
            }
            case NEGATIVE -> {
                priority = "HIGH";
                owner = "Support Escalation";
                automationTrigger = "open-urgent-ticket";
                followUpActions = List.of(
                        "Create an escalation ticket with full context",
                        "Notify the on-call quality lead",
                        "Prepare a proactive outreach script with compensation options"
                );
            }
            case NEUTRAL -> {
                priority = "MEDIUM";
                owner = "Customer Success";
                automationTrigger = "schedule-follow-up-checkin";
                followUpActions = List.of(
                        "Send a follow-up asking for additional detail",
                        "Monitor the account for further activity",
                        "Route feedback to the product insights board"
                );
            }
            default -> throw new IllegalStateException("Unexpected sentiment: " + sentiment);
        }

        return CustomerCarePlan.builder()
                .review(review)
                .sentiment(sentiment)
                .priority(priority)
                .owner(owner)
                .automationTrigger(automationTrigger)
                .followUpActions(followUpActions)
                .build();
    }
}