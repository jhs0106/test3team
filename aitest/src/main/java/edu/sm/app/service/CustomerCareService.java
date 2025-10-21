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
                priority = "성장 촉진 케어";
                owner = "사람다움 라이프 코치";
                automationTrigger = "감사 체크인 메시지";
                conciergeNote = "긍정 경험을 일상 변화와 연결해 사람다움을 확장하세요.";
                followUpActions = List.of(
                        "감사 음성과 함께 작은 실천 챌린지를 제안합니다.",
                        "회원이 발견한 사람다움 순간을 스토리 카드로 정리합니다.",
                        "다른 회원과의 연결 프로그램 또는 봉사 활동을 추천합니다."
                );
            }
            case NEGATIVE -> {
                priority = "즉각 회복 케어";
                owner = "사람다움 회복 코치";
                automationTrigger = "긴급 케어 핫라인 알림";
                conciergeNote = "상처받은 경험을 공감으로 감싸고 회복 루틴을 설계하세요.";
                followUpActions = List.of(
                        "15분 내 공감 전화로 감정과 사건을 안전하게 수집합니다.",
                        "불편을 해소할 수 있는 맞춤 회복 플랜과 자원(상담/휴식)을 제시합니다.",
                        "후속 케어 일지를 공유하며 48시간 내 재확인을 약속합니다."
                );
            }
            case NEUTRAL -> {
                priority = "깊이 탐색 케어";
                owner = "사람다움 성장 코디네이터";
                automationTrigger = "관찰 노트 및 체크인 예약";
                conciergeNote = "숨은 기대와 고민을 발견해 작은 변화를 돕는 여정을 설계하세요.";
                followUpActions = List.of(
                        "생활 리듬과 관계 점검을 위한 미니 코칭 세션을 제안합니다.",
                        "회원의 관심사에 맞춘 사람다움 실천 자료(에세이, 워크북)를 제공합니다.",
                        "1주 뒤 감정 변화를 확인하는 따뜻한 메시지를 예약합니다."
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