package edu.sm.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.json.JSONObject;
import org.json.JSONArray;

import java.util.Map;

@RestController
@RequestMapping("/api/stocks")
public class StockRestController {

    @GetMapping("/{symbol}")
    public Map<String, Object> getStockData(@PathVariable String symbol) {
        try {
            String url = "https://query1.finance.yahoo.com/v7/finance/quote?symbols=" + symbol + ".KS";

            // ✅ 1. JSON 문자열로 응답 받기
            RestTemplate restTemplate = new RestTemplate();
            String response = restTemplate.getForObject(url, String.class);

            // ✅ 2. 문자열을 JSONObject로 파싱
            JSONObject json = new JSONObject(response);

            // ✅ 3. 내부 구조 탐색
            JSONObject quoteResponse = json.getJSONObject("quoteResponse");
            JSONArray resultArray = quoteResponse.getJSONArray("result");

            // ✅ 4. result[0]만 꺼내기
            if (resultArray.length() == 0) {
                return Map.of("error", "결과 데이터가 없습니다.");
            }

            JSONObject result = resultArray.getJSONObject(0);

            // ✅ 5. 필요한 데이터 추출
            return Map.of(
                    "symbol", result.optString("symbol", "-"),
                    "longName", result.optString("longName", "-"),
                    "regularMarketPrice", result.optDouble("regularMarketPrice", 0),
                    "regularMarketChangePercent", result.optDouble("regularMarketChangePercent", 0),
                    "regularMarketVolume", result.optLong("regularMarketVolume", 0),
                    "marketCap", result.optLong("marketCap", 0),
                    "fiftyTwoWeekRange", result.optString("fiftyTwoWeekRange", "-")
            );

        } catch (Exception e) {
            e.printStackTrace();
            return Map.of("error", "API 요청 실패: " + e.getMessage());
        }
    }
}
