package edu.sm.controller;

import edu.sm.app.service.OperationMetricService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 *   RapidAPI 기반 실시간 주가 조회 컨트롤러
 * Yahoo Finance (공식 RapidAPI) 사용
 * - 429 차단 없음
 * - 안정적 응답
 * - 한국 종목은 .KS 자동 추가
 */
@RestController
@RequestMapping("/api/stocks")
@RequiredArgsConstructor
@Slf4j
public class ChartRestController {

    //  RapidAPI 키 (개인 키 사용 중)
    private static final String API_KEY = "a3258fbaa5msh4aa92df73eafc25p1235e9jsne271b2011ad9";
    private static final String API_HOST = "apidojo-yahoo-finance-v1.p.rapidapi.com";
    private static final String BASE_URL = "https://" + API_HOST + "/market/v2/get-quotes";

    private final OperationMetricService operationMetricService;

    @GetMapping("/{symbol}")
    public Map<String, Object> getStock(@PathVariable String symbol) {
        String normalizedSymbol = symbol == null ? "" : symbol.trim().toUpperCase();
        if (normalizedSymbol.isEmpty()) {
            normalizedSymbol = "005930"; // 기본값: 삼성전자
        }

        String url = BASE_URL + "?region=KR&symbols=" + normalizedSymbol + ".KS";

        HttpHeaders headers = new HttpHeaders();
        headers.set("X-RapidAPI-Key", API_KEY);
        headers.set("X-RapidAPI-Host", API_HOST);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();

        try {
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
            Map body = response.getBody();
            if (body == null || !body.containsKey("quoteResponse")) {
                operationMetricService.recordChartRequest(normalizedSymbol, null, false, null, null, null, null);
                log.warn("잘못된 응답 구조: symbol={} body={}", normalizedSymbol, body);
                return Map.of("error", "Invalid API response structure");
            }

            Map quoteResponse = (Map) body.get("quoteResponse");
            List<Map> results = (List<Map>) quoteResponse.get("result");

            if (results == null || results.isEmpty()) {
                operationMetricService.recordChartRequest(normalizedSymbol, null, false, null, null, null, null);
                return Map.of("error", "No data found for symbol: " + normalizedSymbol);
            }

            Map<String, Object> result = results.get(0);
            String name = Objects.toString(result.getOrDefault("longName", normalizedSymbol), normalizedSymbol);
            Double price = toDouble(result.get("regularMarketPrice"));
            Double changePercent = toDouble(result.get("regularMarketChangePercent"));
            Long volume = toLong(result.get("regularMarketVolume"));
            Double marketCap = toDouble(result.get("marketCap"));

            double safePrice = price != null ? price : 0.0;
            double safeChange = changePercent != null ? changePercent : 0.0;
            long safeVolume = volume != null ? volume : 0L;
            double safeMarketCap = marketCap != null ? marketCap : 0.0;

            operationMetricService.recordChartRequest(normalizedSymbol, name, true, price, changePercent, volume, marketCap);

            return Map.of(
                    "symbol", result.getOrDefault("symbol", normalizedSymbol),
                    "longName", name,
                    "regularMarketPrice", safePrice,
                    "regularMarketChangePercent", safeChange,
                    "regularMarketVolume", safeVolume,
                    "marketCap", safeMarketCap,
                    "fiftyTwoWeekRange", result.getOrDefault("fiftyTwoWeekRange", "-")
            );

        } catch (Exception e) {
            log.error("주가 API 호출 실패 - symbol={}", normalizedSymbol, e);
            operationMetricService.recordChartRequest(normalizedSymbol, null, false, null, null, null, null);
            return Map.of("error", "API 요청 실패: " + e.getMessage());
        }
    }

    @GetMapping("/")
    public Map<String, Object> defaultStock() {
        return getStock("005930");
    }

    private Double toDouble(Object value) {
        if (value instanceof Number number) {
            return number.doubleValue();
        }
        if (value instanceof String str && !str.isBlank()) {
            try {
                return Double.parseDouble(str.replaceAll(",", ""));
            } catch (NumberFormatException ignored) {
            }
        }
        return null;
    }

    private Long toLong(Object value) {
        if (value instanceof Number number) {
            return number.longValue();
        }
        if (value instanceof String str && !str.isBlank()) {
            try {
                return Long.parseLong(str.replaceAll(",", ""));
            } catch (NumberFormatException ignored) {
            }
        }
        return null;
    }
}
