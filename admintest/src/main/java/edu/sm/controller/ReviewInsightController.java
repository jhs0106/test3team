package edu.sm.controller;

import edu.sm.app.dto.ReviewCareInsight;
import edu.sm.app.service.ReviewInsightService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/care-insights")
@RequiredArgsConstructor
public class ReviewInsightController {

    private final ReviewInsightService reviewInsightService;

    @GetMapping
    public ResponseEntity<ReviewCareInsight> analyse(@RequestParam(value = "limit", defaultValue = "10") int limit) {
        ReviewCareInsight insight = reviewInsightService.generateCareInsight(limit);
        return ResponseEntity.ok(insight);
    }
}