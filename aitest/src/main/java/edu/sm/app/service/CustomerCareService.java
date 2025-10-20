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
        String conciergeNote;
        List<String> followUpActions;

        switch (sentiment) {
            case POSITIVE -> {
                priority = "관심 유지";
                owner = "시니어 매칭 매니저";
                automationTrigger = "감사 케어 메일 발송";
                conciergeNote = "긍정적인 경험을 다른 회원에게도 확산시킬 수 있도록 리퍼럴을 제안하세요.";
                followUpActions = List.of(
                        "개인화된 감사 메시지와 서비스 업그레이드 혜택을 안내합니다.",
                        "만족 포인트를 정리하여 마케팅용 성공 스토리로 공유합니다.",
                        "추천인 이벤트 및 프리미엄 클래스 참여를 제안합니다."
                );
            }
            case NEGATIVE -> {
                priority = "즉시 대응";
                owner = "헤드 컨설턴트";
                automationTrigger = "위기 케어 티켓 생성";
                conciergeNote = "불만 요인을 명확히 파악하고 맞춤형 보상과 재상담을 제안해야 합니다.";
                followUpActions = List.of(
                        "30분 내 담당 매니저가 직접 연락하여 상세 상황을 파악합니다.",
                        "불편 유형에 맞는 보상안과 맞춤 재매칭 플랜을 준비합니다.",
                        "서비스 개선위원회에 즉시 공유하여 재발 방지 액션을 설정합니다."
                );
            }
            case NEUTRAL -> {
                priority = "세심 모니터링";
                owner = "케어 코디네이터";
                automationTrigger = "맞춤 상담 일정 제안";
                conciergeNote = "보다 깊은 니즈를 탐색해 긍정 경험으로 전환할 기회를 만드세요.";
                followUpActions = List.of(
                        "관심사와 이상형 조건을 다시 확인하는 보완 상담을 제안합니다.",
                        "고민 중인 부분에 대한 리서치 콘텐츠나 웨비나 정보를 제공합니다.",
                        "후속 감정 변화를 추적하기 위해 1주 뒤 체크인을 예약합니다."
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
                .conciergeNote(conciergeNote)
                .followUpActions(followUpActions)
                .build();
    }
}