package edu.sm.app.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import edu.sm.app.dto.CustomerCarePlan;
import edu.sm.app.dto.Member;
import edu.sm.app.dto.MemberReview;
import edu.sm.app.dto.ReviewClassification;
import edu.sm.app.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final CustomerCareService customerCareService;
    private final ReviewRepository reviewRepository;

    @Transactional
    public CustomerCarePlan saveMemberReview(Member member, String reviewText) {
        if (member == null) {
            throw new IllegalArgumentException("로그인이 필요합니다.");
        }
        if (member.getMemberNo() == null) {
            throw new IllegalArgumentException("회원 정보가 올바르지 않습니다.");
        }
        if (reviewText == null || reviewText.isBlank()) {
            throw new IllegalArgumentException("후기를 입력해주세요.");
        }
        String feedback = reviewText.trim();
        if (feedback.isEmpty()) {
            throw new IllegalArgumentException("후기를 입력해주세요.");
        }
        CustomerCarePlan plan = customerCareService.handleFeedback(feedback);
        ReviewClassification.Sentiment sentiment = plan.getSentiment();
        MemberReview review = MemberReview.builder()
                .memberNo(member.getMemberNo())
                .memberName(member.getName())
                .review(plan.getReview())
                .sentiment(sentiment)
                .createdAt(LocalDateTime.now())
                .build();
        reviewRepository.insertReview(review);
        return plan;
    }

    public List<MemberReview> getRecentReviews(int limit) {
        int adjustedLimit = limit <= 0 ? 10 : limit;
        return reviewRepository.findRecentReviews(adjustedLimit);
    }

}