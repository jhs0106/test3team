package edu.sm.controller;

import edu.sm.app.dto.BookRecommendationRequest;
import edu.sm.app.springai.service1.AiServiceByChatClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/book")
public class AiBookController {

    private final AiServiceByChatClient aiServiceByChatClient;
    String dir = "book/";

    @RequestMapping("")
    public String aimain(Model model) {
        model.addAttribute("center", dir + "center");
        model.addAttribute("left", dir + "left");
        return "index";
    }

    @RequestMapping("/book")
    public String book(Model model) {
        model.addAttribute("center", dir + "book");
        model.addAttribute("left", dir + "left");
        return "index";
    }

    @PostMapping("/recommend")
    @ResponseBody
    public ResponseEntity<Map<String, String>> recommend(@RequestBody BookRecommendationRequest request) {
        try {
            String mood = valueOrFallback(request.getMood(), "정보 없음");
            String reason = valueOrFallback(request.getReason(), "정보 없음");
            String readingTime = valueOrFallback(request.getReadingTime(), "정보 없음");
            String concern = valueOrFallback(request.getConcern(), "정보 없음");

            StringBuilder promptBuilder = new StringBuilder();
            promptBuilder.append("너는 독자에게 맞춤형 책을 추천하는 전문 북 큐레이터야. ");
            promptBuilder.append("사용자가 작성한 설문을 기반으로 오늘 읽기에 적합한 책을 제안해 줘.\n\n");
            promptBuilder.append("[사용자 정보]\n");
            promptBuilder.append("- 오늘의 기분: ").append(mood).append("\n");
            promptBuilder.append("- 기분을 느낀 이유: ").append(reason).append("\n");
            promptBuilder.append("- 오늘 독서에 투자할 수 있는 시간: ").append(readingTime).append("\n");
            promptBuilder.append("- 요즘 고민거리: ").append(concern).append("\n\n");
            promptBuilder.append("[요청 사항]\n");
            promptBuilder.append("1. 위 정보를 토대로 오늘 읽으면 좋을 책 3권을 추천해 줘.\n");
            promptBuilder.append("2. 각 책마다 추천 이유와 책의 핵심 메시지를 간단히 정리해 줘.\n");
            promptBuilder.append("3. 독서 시간을 고려하여 어떤 방식으로 읽으면 좋을지도 함께 안내해 줘.\n");
            promptBuilder.append("4. 한국어로만 답변해 줘.\n");

            String recommendation = aiServiceByChatClient.generateText(promptBuilder.toString());
            return ResponseEntity.ok(Map.of("recommendation", recommendation.trim()));
        } catch (Exception e) {
            log.error("Failed to generate book recommendation", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "책 추천을 생성하는 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요."));
        }
    }

    private String valueOrFallback(String value, String fallback) {
        if (value == null) {
            return fallback;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? fallback : trimmed;
    }
}
