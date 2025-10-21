package edu.sm.app.service;

import edu.sm.app.dto.MemberReview;
import edu.sm.app.dto.ReviewCareInsight;
import edu.sm.app.repository.ReviewRepository;
import jakarta.annotation.PostConstruct;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewInsightService {

    private final ReviewRepository reviewRepository;
    private final ChatClient.Builder chatClientBuilder;

    private ChatClient chatClient;

    private static final DateTimeFormatter DATE_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm", Locale.KOREA);

    @PostConstruct
    void setUp() {
        this.chatClient = chatClientBuilder.build();
    }

    /**
     * 최근 리뷰를 분석해 케어 인사이트를 생성합니다.
     * - limit가 비정상 값이면 10으로 보정 (최소 1, 최대 100 권장)
     * - LLM 실패 시에도 빈 Insight를 생성해 null 반환을 막음
     */
    public ReviewCareInsight generateCareInsight(int limit) {
        // 1) limit 보정
        int safeLimit = limit <= 0 ? 10 : Math.min(limit, 100);

        // 2) 최근 리뷰 가져오기
        List<MemberReview> reviews = fetchRecentReviews(safeLimit);

        // 3) 리뷰가 전혀 없으면 기본 안내 반환 (LLM 호출 생략)
        if (reviews.isEmpty()) {
            ReviewCareInsight empty = new ReviewCareInsight();
            empty.setSummary("최근 리뷰가 없어 분석할 데이터가 없습니다.");
            empty.setCareFocus("리뷰 수집 경로(앱/웹/콜센터) 동작 여부를 점검하세요.");
            empty.setEncouragement("데이터가 쌓이면 더 정교한 인사이트를 제공할 수 있어요.");
            applyReviewContext(empty, reviews);
            return empty;
        }

        // 4) 프롬프트 구성
        String prompt = buildPrompt(reviews);

        // 5) LLM 호출 (예외 안전)
        ReviewCareInsight insight;
        try {
            ChatOptions options = ChatOptions.builder()
                    .temperature(0.2)
                    .maxTokens(800)
                    .build();

            insight = chatClient
                    .prompt()
                    .user(prompt)
                    .options(options)
                    .call()
                    .entity(ReviewCareInsight.class);

            if (insight == null) {
                insight = new ReviewCareInsight();
                insight.setSummary("AI 응답을 파싱하지 못했습니다.");
                insight.setCareFocus("프롬프트/스키마를 점검하세요.");
                insight.setEncouragement("임시로 내부 회의로 우선순위를 도출하세요.");
            }
        } catch (Exception ex) {
            log.warn("Failed to analyse reviews with LLM", ex);
            insight = new ReviewCareInsight();
            insight.setSummary("AI 분석 중 문제가 발생했습니다.");
            insight.setCareFocus("시스템 상태를 점검한 뒤 다시 시도해 주세요.");
            insight.setEncouragement("임시로 케어팀 내부 회의를 통해 우선순위를 정해 주세요.");
        }

        // 6) 통계/최근리뷰 등 컨텍스트 병합
        applyReviewContext(insight, reviews);
        return insight;
    }

    /** 최근 리뷰 조회 – 예외 발생 시 빈 리스트 */
    private List<MemberReview> fetchRecentReviews(int limit) {
        try {
            return reviewRepository.findRecentReviews(limit);
        } catch (Exception ex) {
            log.warn("Failed to fetch reviews from database", ex);
            return List.of();
        }
    }

    /** LLM 결과에 통계/최근 리뷰(파생 감정 포함)를 채워 넣기 */
    private void applyReviewContext(ReviewCareInsight insight, List<MemberReview> reviews) {
        if (insight == null) return;

        insight.setReviewCount(reviews.size());
        insight.setAverageRating(calculateAverageRating(reviews));
        insight.setPositiveCount(countSentiment(reviews, "POSITIVE"));
        insight.setNeutralCount(countSentiment(reviews, "NEUTRAL"));
        insight.setNegativeCount(countSentiment(reviews, "NEGATIVE"));

        insight.ensureCollections(); // 내부 리스트/컬렉션 null 방지

        // 최근 5건을 최신순으로 정렬해 내려주고, 표시용 파생 감정을 채워줌
        List<MemberReview> recent = reviews.stream()
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(
                        MemberReview::getCreatedAt,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(5)
                .map(this::enrichWithDerivedSentiment)
                .collect(Collectors.toList());

        insight.setRecentReviews(recent);
    }

    /** LLM에 던질 프롬프트 구성 */
    private String buildPrompt(List<MemberReview> reviews) {
        String header = "회원 리뷰 데이터:";
        String body = reviews.stream()
                .sorted(Comparator.comparing(
                        MemberReview::getCreatedAt,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .map(review -> {
                    String when = review.getCreatedAt() != null
                            ? DATE_FORMATTER.format(review.getCreatedAt())
                            : "작성일 미상";
                    String sentiment = resolveSentiment(review);
                    String careResponse = defaultString(review.getCareResponse(), "케어 응답 없음");
                    int rating = review.getRating() == null ? 0 : review.getRating();
                    return "- %s (%s, 별점 %d점, 감정: %s)\n  리뷰: %s\n  케어 응답: %s"
                            .formatted(
                                    defaultString(review.getMemberName(), "익명 회원"),
                                    when,
                                    rating,
                                    sentiment,
                                    defaultString(review.getReview(), ""),
                                    careResponse
                            );
                })
                .collect(Collectors.joining("\n"));

        return header + "\n" + body + "\n\n"
                + "목표: 별점과 케어 응답 기록을 분석해 사람다움 케어 전략을 제안하세요. "
                + "출력은 ReviewCareInsight 스키마에 맞춰 요약(summary), 케어 포커스(careFocus), 응원(encouragement), "
                + "실행 과제(actionItems 3~5개), 핵심 키워드(keywords 5~10개)를 한국어로 제공하세요.";
    }

    private String defaultString(String value, String defaultValue) {
        return (value == null || value.isBlank()) ? defaultValue : value;
    }

    /** 표시용 감정을 파생 세팅 */
    private MemberReview enrichWithDerivedSentiment(MemberReview review) {
        if (review == null) return null;
        review.setSentiment(resolveSentiment(review));
        return review;
    }

    private double calculateAverageRating(List<MemberReview> reviews) {
        return reviews.stream()
                .map(MemberReview::getRating)
                .filter(Objects::nonNull)
                .mapToInt(Integer::intValue)
                .average()
                .orElse(0.0);
    }

    private int countSentiment(List<MemberReview> reviews, String expected) {
        return (int) reviews.stream()
                .filter(Objects::nonNull)
                .map(this::resolveSentiment)
                .filter(s -> s.equalsIgnoreCase(expected))
                .count();
    }

    /**
     * 감정 결정 로직:
     * - 리뷰 객체에 sentiment가 있으면 이를 우선 사용
     * - 없으면 rating 기준으로 유추 (>=4: POSITIVE, 3: NEUTRAL, 1~2: NEGATIVE)
     * - rating이 없으면 UNKNOWN
     */
    private String resolveSentiment(MemberReview review) {
        if (review == null) return "UNKNOWN";

        String sentiment = review.getSentiment();
        if (sentiment != null && !sentiment.isBlank()) {
            return sentiment.trim().toUpperCase(Locale.ROOT);
        }

        Integer rating = review.getRating();
        if (rating == null) return "UNKNOWN";

        if (rating >= 4) return "POSITIVE";
        if (rating == 3) return "NEUTRAL";
        if (rating >= 1) return "NEGATIVE";

        return "UNKNOWN";
    }
}
