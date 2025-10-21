package edu.sm.app.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ReviewCareInsight {
    private String summary;
    private String careFocus;
    private List<String> actionItems;
    private String encouragement;
    private int reviewCount;
    private List<MemberReview> recentReviews;

    public void ensureCollections() {
        if (actionItems == null) {
            actionItems = new ArrayList<>();
        }
        if (recentReviews == null) {
            recentReviews = new ArrayList<>();
        }
    }

    public List<String> safeActionItems() {
        return actionItems == null ? Collections.emptyList() : actionItems;
    }
}