package edu.sm.controller;

import edu.sm.app.dto.CustomerCarePlan;
import edu.sm.app.dto.Member;
import edu.sm.app.dto.MemberReview;
import edu.sm.app.service.CustomerCareService;
import edu.sm.app.service.ReviewService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final CustomerCareService customerCareService;
    private final ReviewService reviewService;

    @GetMapping("/action-plan")
    public CustomerCarePlan createActionPlan(@RequestParam("feedback") String feedback,
                                             @RequestParam(value = "rating", defaultValue = "5") int rating) {
        return customerCareService.handleFeedback(feedback, rating);
    }

    @PostMapping
    public ResponseEntity<CustomerCarePlan> submitReview(@RequestBody Map<String, String> payload,
                                                         HttpSession session) {
        Member member = (Member) session.getAttribute("loginMember");
        if (member == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            String review = payload != null ? payload.get("review") : null;
            Integer rating = null;
            if (payload != null) {
                String ratingValue = payload.get("rating");
                if (ratingValue != null && !ratingValue.isBlank()) {
                    rating = Integer.parseInt(ratingValue);
                }
            }
            CustomerCarePlan plan = reviewService.saveMemberReview(member, review, rating);
            return ResponseEntity.ok(plan);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping
    public List<MemberReview> recentReviews(@RequestParam(value = "limit", defaultValue = "10") int limit) {
        return reviewService.getRecentReviews(limit);
    }
}
