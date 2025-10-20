package edu.sm.app.service;

import edu.sm.app.dto.ReviewClassification;

public interface ReviewClassificationClient {
    ReviewClassification classifyReview(String review);
}