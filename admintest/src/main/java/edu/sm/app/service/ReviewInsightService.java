package edu.sm.app.service;

import edu.sm.app.dto.MemberReview;
import edu.sm.app.dto.ReviewCareInsight;
import jakarta.annotation.PostConstruct;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewInsightService {

    private final RestClient.Builder restClientBuilder;
    private final ChatClient.Builder chatClientBuilder;

    @Value("${app.url.reviews}")
    private String reviewServiceBaseUrl;

    private RestClient reviewClient;
    private ChatClient chatClient;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm", Locale.KOREA);

    @PostConstruct
    void setUp() {
        String baseUrl = (reviewServiceBaseUrl == null || reviewServiceBaseUrl.isBlank())
                ? "http://localhost:8445"
                : StringUtils.trimTrailingCharacter(reviewServiceBaseUrl, '/');
        this.reviewClient = restClientBuilder.baseUrl(baseUrl).build();
        this.chatClient = chatClientBuilder.build();
    }

    public ReviewCareInsight generateCareInsight(int limit) {
        List<MemberReview> reviews = fetchRecentReviews(limit);
        ReviewCareInsight insight;

        if (reviews.isEmpty()) {
            insight = new ReviewCareInsight();
            insight.setSummary("최근 리뷰 데이터를 찾을 수 없습니다.");
            insight.setCareFocus("회원들의 케어 경험을 먼저 수집해 주세요.");
            insight.setEncouragement("리뷰가 확보되면 사람다움 케어 전략을 다시 제안하겠습니다.");
            insight.ensureCollections();
            return insight;
        }

        String prompt = buildPrompt(reviews);

        try {
            insight = chatClient.prompt()
                    .system("""
                            당신은 '사람다움 케어' 서비스를 운영하는 총괄 케어 디렉터입니다.
                            회원 리뷰를 토대로 사람다움 회복을 돕는 전략을 제시하세요.
                            아래 JSON 형식으로만 응답합니다.
                            {
                              "summary": "전체 리뷰 분위기 요약",
                              "careFocus": "집중해야 할 케어 주제",
                              "actionItems": ["실행 과제 1", "실행 과제 2"],
                              "encouragement": "케어 팀에 전하는 응원 메시지"
                            }
                            모든 설명은 한국어로 작성합니다.
                            """)
                    .user(prompt)
                    .options(ChatOptions.builder().build())
                    .call()
                    .entity(ReviewCareInsight.class);
        } catch (Exception ex) {
            log.warn("Failed to analyse reviews with LLM", ex);
            insight = new ReviewCareInsight();
            insight.setSummary("AI 분석 중 문제가 발생했습니다.");
            insight.setCareFocus("시스템 상태를 점검한 뒤 다시 시도해 주세요.");
            insight.setEncouragement("임시로 케어팀 내부 회의를 통해 우선순위를 정해 주세요.");
        }

        applyReviewContext(insight, reviews);
        return insight;
    }

    private List<MemberReview> fetchRecentReviews(int limit) {
        try {
            return reviewClient.get()
                    .uri(builder -> builder.path("/reviews")
                            .queryParam("limit", limit)
                            .build())
                    .retrieve()
                    .body(new ParameterizedTypeReference<List<MemberReview>>() {});
        } catch (Exception ex) {
            log.warn("Failed to fetch reviews from review service", ex);
            return List.of();
        }
    }

    private void applyReviewContext(ReviewCareInsight insight, List<MemberReview> reviews) {
        insight.setReviewCount(reviews.size());
        insight.ensureCollections();
        insight.setRecentReviews(reviews.stream()
                .sorted(Comparator.comparing(MemberReview::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(5)
                .collect(Collectors.toList()));
    }

    private String buildPrompt(List<MemberReview> reviews) {
        String header = "회원 리뷰 데이터:";
        String body = reviews.stream()
                .sorted(Comparator.comparing(MemberReview::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())))
                .map(review -> {
                    String when = review.getCreatedAt() != null ? DATE_FORMATTER.format(review.getCreatedAt()) : "작성일 미상";
                    return "- %s (%s): %s".formatted(
                            defaultString(review.getMemberName(), "익명 회원"),
                            when,
                            defaultString(review.getReview(), ""));
                })
                .collect(Collectors.joining("\n"));

        return header + "\n" + body + "\n\n" +
                "목표: 리뷰 속 니즈와 위기 신호를 추려 사람다움 케어 전략을 제안하세요.";
    }

    private String defaultString(String value, String defaultValue) {
        return (value == null || value.isBlank()) ? defaultValue : value;
    }
}