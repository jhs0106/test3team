package edu.sm.app.service;

import edu.sm.app.dto.CustomerCarePlan;
import edu.sm.app.dto.ReviewClassification;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CustomerCareService {

    private final ReviewClassificationClient reviewClassificationClient;

    public CustomerCarePlan handleFeedback(String feedback) {
        ReviewClassification classification = reviewClassificationClient.classifyReview(feedback);
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
                priority = "낮음";
                owner = "커뮤니티 팀";
                automationTrigger = "감사 메시지 자동 발송";
                followUpActions = List.of(
                        "개인화된 감사 메시지를 전송합니다.",
                        "성공 사례 대시보드에 피드백을 기록합니다.",
                        "주요 내용을 마케팅 팀과 공유합니다."
                );
            }
            case NEGATIVE -> {
                priority = "높음";
                owner = "지원 에스컬레이션 팀";
                automationTrigger = "긴급 티켓 생성";
                followUpActions = List.of(
                        "세부 내용을 포함한 에스컬레이션 티켓을 생성합니다.",
                        "당직 품질 책임자에게 즉시 알립니다.",
                        "보상 옵션이 포함된 선제 대응 스크립트를 준비합니다."
                );
            }
            case NEUTRAL -> {
                priority = "보통";
                owner = "고객 성공 팀";
                automationTrigger = "후속 확인 일정 예약";
                followUpActions = List.of(
                        "추가 정보를 요청하는 후속 연락을 보냅니다.",
                        "추가 활동이 있는지 계정을 모니터링합니다.",
                        "피드백을 제품 인사이트 보드로 전달합니다."
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