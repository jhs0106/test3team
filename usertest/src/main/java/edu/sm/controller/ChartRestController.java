package edu.sm.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.*;

/**
 *   RapidAPI 기반 실시간 주가 조회 컨트롤러
 * Yahoo Finance (공식 RapidAPI) 사용
 * - 429 차단 없음
 * - 안정적 응답
 * - 한국 종목은 .KS 자동 추가
 */
@RestController
@RequestMapping("/api/stocks")
public class ChartRestController {

    //  RapidAPI 키 (개인 키 사용 중)
    private static final String API_KEY = "e00490892cmsh481da93a287fe3ep113054jsnaa4e9b11fff6";
    private static final String API_HOST = "apidojo-yahoo-finance-v1.p.rapidapi.com";
    private static final String BASE_URL = "https://" + API_HOST + "/market/v2/get-quotes";

    @GetMapping("/{symbol}")
    public Map<String, Object> getStock(@PathVariable String symbol) {
        try {
            symbol = symbol.toUpperCase();

            // ✅ 요청 URL 구성
            String url = BASE_URL + "?region=KR&symbols=" + symbol + ".KS";

            // ✅ 헤더 세팅
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-RapidAPI-Key", API_KEY);
            headers.set("X-RapidAPI-Host", API_HOST);

            // ✅ 요청 엔터티 생성
            HttpEntity<String> entity = new HttpEntity<>(headers);
            RestTemplate restTemplate = new RestTemplate();

            // ✅ API 요청 및 응답 수신
            ResponseEntity<Map> response =
                    restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

            Map body = response.getBody();
            if (body == null || !body.containsKey("quoteResponse")) {
                return Map.of("error", "Invalid API response structure");
            }

            Map quoteResponse = (Map) body.get("quoteResponse");
            List<Map> results = (List<Map>) quoteResponse.get("result");

            if (results == null || results.isEmpty()) {
                return Map.of("error", "No data found for symbol: " + symbol);
            }

            Map<String, Object> result = results.get(0);

            // ✅ 필요한 데이터만 선택적으로 반환 (필요시 추가 가능)
            return Map.of(
                    "symbol", result.getOrDefault("symbol", "-"),
                    "longName", result.getOrDefault("longName", "-"),
                    "regularMarketPrice", result.getOrDefault("regularMarketPrice", 0),
                    "regularMarketChangePercent", result.getOrDefault("regularMarketChangePercent", 0),
                    "regularMarketVolume", result.getOrDefault("regularMarketVolume", 0),
                    "marketCap", result.getOrDefault("marketCap", 0),
                    "fiftyTwoWeekRange", result.getOrDefault("fiftyTwoWeekRange", "-")
            );

        } catch (Exception e) {
            e.printStackTrace();
            return Map.of("error", "API 요청 실패: " + e.getMessage());
        }
    }

    // ✅ 기본 종목(삼성전자) 요청 시: /api/stocks/
    @GetMapping("/")
    public Map<String, Object> defaultStock() {
        return getStock("005930");
    }
}

