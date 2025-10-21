
package edu.sm.service;

import static org.assertj.core.api.Assertions.assertThat;

import edu.sm.app.dto.CustomerCarePlan;
import edu.sm.app.service.CustomerCareService;
import org.junit.jupiter.api.Test;

class CustomerCareServiceTest {

    private final CustomerCareService customerCareService = new CustomerCareService();

    @Test
    void handleFeedbackShouldCreateGratitudePlanForHighRating() {
        CustomerCarePlan plan = customerCareService.handleFeedback("정말 만족스러웠어요", 5);

        assertThat(plan.getRating()).isEqualTo(5);
        assertThat(plan.getCareTone()).isEqualTo("감사 케어");
        assertThat(plan.getResponseMessage()).contains("감사");
        assertThat(plan.getFollowUpSuggestions()).isNotEmpty();
    }

    @Test
    void handleFeedbackShouldCreateSupportPlanForMidRating() {
        CustomerCarePlan plan = customerCareService.handleFeedback("나쁘진 않은데 조금 아쉬웠어요", 3);

        assertThat(plan.getRating()).isEqualTo(3);
        assertThat(plan.getCareTone()).isEqualTo("성장 지원 케어");
        assertThat(plan.getFollowUpSuggestions()).contains("불편했던 상황을 자세히 남겨 주시면 개선에 큰 도움이 됩니다.");
    }

    @Test
    void handleFeedbackShouldCreateRecoveryPlanForLowRatingAndFillEmptyReview() {
        CustomerCarePlan plan = customerCareService.handleFeedback("   ", 1);

        assertThat(plan.getRating()).isEqualTo(1);
        assertThat(plan.getReview()).isEqualTo("후기 내용이 입력되지 않았습니다.");
        assertThat(plan.getCareTone()).isEqualTo("회복 케어");
        assertThat(plan.getResponseMessage()).contains("사과");
    }

    @Test
    void handleFeedbackShouldClampRatingIntoAllowedRange() {
        CustomerCarePlan plan = customerCareService.handleFeedback("보통이었어요", 8);

        assertThat(plan.getRating()).isEqualTo(5);
        assertThat(plan.getCareTone()).isEqualTo("감사 케어");
    }
}
//package edu.sm.service;
//
//import edu.sm.app.dto.CustomerCarePlan;
//import edu.sm.app.dto.ReviewClassification;
//import edu.sm.app.service.CustomerCareService;
//import edu.sm.app.service.ReviewClassificationClient;
//import org.junit.jupiter.api.Test;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//
//import static org.assertj.core.api.Assertions.assertThat;
//
//class CustomerCareServiceTest {
//
//    private static final Logger log = LoggerFactory.getLogger(CustomerCareServiceTest.class);
//
//    @Test
//    void handleFeedbackShouldMapPositiveSentimentIntoLowPriorityPlan() {
//        ReviewClassificationClient classifier = review -> {
//            ReviewClassification classification = new ReviewClassification();
//            classification.setReview(review);
//            classification.setClassification(ReviewClassification.Sentiment.POSITIVE);
//            return classification;
//        };
//
//        CustomerCareService customerCareService = new CustomerCareService(classifier);
//
//        CustomerCarePlan plan = customerCareService.handleFeedback("Fantastic!");
//
//        assertThat(plan.getSentiment()).isEqualTo(ReviewClassification.Sentiment.POSITIVE);
//        assertThat(plan.getPriority()).isEqualTo("LOW");
//        assertThat(plan.getOwner()).isEqualTo("Community Team");
//        assertThat(plan.getAutomationTrigger()).isEqualTo("send-appreciation-workflow");
//        assertThat(plan.getFollowUpActions()).containsExactly(
//                "Send a personalized thank-you message",
//                "Log the feedback in the success stories dashboard",
//                "Share highlights with the marketing team"
//        );
//    }
//
//    @Test
//    void handleFeedbackShouldDefaultToNeutralWhenClassificationMissing() {
//        CustomerCareService customerCareService = new CustomerCareService(review -> null);
//
//        CustomerCarePlan plan = customerCareService.handleFeedback("uncertain feedback");
//
//        assertThat(plan.getSentiment()).isEqualTo(ReviewClassification.Sentiment.NEUTRAL);
//        assertThat(plan.getReview()).isEqualTo("uncertain feedback");
//        assertThat(plan.getPriority()).isEqualTo("MEDIUM");
//        assertThat(plan.getOwner()).isEqualTo("Customer Success");
//        assertThat(plan.getAutomationTrigger()).isEqualTo("schedule-follow-up-checkin");
//    }
//
//    @Test
//    void handleFeedbackShouldFavorClassificationReviewWhenProvided() {
//        ReviewClassificationClient classifier = review -> {
//            ReviewClassification classification = new ReviewClassification();
//            classification.setReview("Provided from AI");
//            return classification;
//        };
//
//        CustomerCareService customerCareService = new CustomerCareService(classifier);
//
//        CustomerCarePlan plan = customerCareService.handleFeedback("original input");
//
//        assertThat(plan.getReview()).isEqualTo("Provided from AI");
//        assertThat(plan.getSentiment()).isEqualTo(ReviewClassification.Sentiment.NEUTRAL);
//        assertThat(plan.getFollowUpActions()).contains("Route feedback to the product insights board");
//    }
//
//    @Test
//    void handleFeedbackShouldLogPlanForKoreanFeedback() {
//        String feedback = "배송이 너무 늦었어요. 다시는 이용하고 싶지 않아요.";
//        ReviewClassificationClient classifier = review -> {
//            ReviewClassification classification = new ReviewClassification();
//            classification.setReview(review);
//            classification.setClassification(ReviewClassification.Sentiment.NEGATIVE);
//            return classification;
//        };
//
//        CustomerCareService customerCareService = new CustomerCareService(classifier);
//
//        CustomerCarePlan plan = customerCareService.handleFeedback(feedback);
//        log.info("고객 케어 플랜 샘플: {}", plan);
//
//        assertThat(plan.getReview()).isEqualTo(feedback);
//        assertThat(plan.getSentiment()).isEqualTo(ReviewClassification.Sentiment.NEGATIVE);
//        assertThat(plan.getPriority()).isEqualTo("HIGH");
//        assertThat(plan.getOwner()).isEqualTo("Support Escalation");
//    }
//}
