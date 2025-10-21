package edu.sm.app.service;

import edu.sm.app.dto.CustomerCarePlan;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class CustomerCareService {

    public CustomerCarePlan handleFeedback(String feedback, int rating) {
        String normalizedReview = feedback == null ? "" : feedback.trim();
        if (normalizedReview.isBlank()) {
            normalizedReview = "후기 내용이 입력되지 않았습니다.";
        }

        int safeRating = Math.max(1, Math.min(rating, 5));
        return buildPlan(normalizedReview, safeRating);
    }

    private CustomerCarePlan buildPlan(String review, int rating) {
        String careTone;
        String responseMessage;
        List<String> followUpSuggestions;

        if (rating >= 4) {
            careTone = "감사 케어";
            responseMessage = "정성스러운 후기를 남겨 주셔서 감사합니다. 회원님의 따뜻한 사람이미가 다른 분들께도 큰 힘이 됩니다.";
            followUpSuggestions = List.of(
                    "좋았던 순간을 커뮤니티에 공유해 주세요.",
                    "다음 방문 때 기대하는 점을 알려주시면 더 세심히 준비하겠습니다."
            );
        } else if (rating == 3) {
            careTone = "성장 지원 케어";
            responseMessage = "소중한 의견을 들려주셔서 감사합니다. 아쉬웠던 부분을 함께 점검하며 더 사람다운 경험을 준비하겠습니다.";
            followUpSuggestions = List.of(
                    "불편했던 상황을 자세히 남겨 주시면 개선에 큰 도움이 됩니다.",
                    "추가로 원하시는 케어가 있다면 코치에게 직접 알려주세요."
            );
        } else {
            careTone = "회복 케어";
            responseMessage = "이용 중 겪으신 어려움에 진심으로 사과드립니다. 곧 전담 코치가 연락드려 회복 플랜을 세우겠습니다.";
            followUpSuggestions = List.of(
                    "불편 사항을 빠르게 해결하기 위해 연락 가능한 시간을 알려주세요.",
                    "필요하다면 맞춤 휴식 프로그램과 상담을 즉시 연결해 드리겠습니다."
            );
        }

        return CustomerCarePlan.builder()
                .review(review)
                .rating(rating)
                .careTone(careTone)
                .responseMessage(responseMessage)
                .followUpSuggestions(followUpSuggestions)
                .build();
    }
}