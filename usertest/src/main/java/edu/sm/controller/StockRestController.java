package edu.sm.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.*;

/**
 * 주식 정보를 가져오는 REST 컨트롤러
 * RapidAPI - Yahoo Finance API를 호출하여
 * 특정 종목(symbol)의 실시간 시세 데이터를 반환함.
 */
@RestController
@RequestMapping("/api/stocks")
public class StockRestController {

    // ✅ 종목코드로 API 요청 (예: /api/stocks/005930)
    @GetMapping("/{symbol}")
    public Object getStock(@PathVariable String symbol) {

        // RapidAPI 무료 엔드포인트
        String url = "https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/v2/get-quotes"
                + "?region=KR&symbols=" + symbol + ".KS";

        HttpHeaders headers = new HttpHeaders();
        headers.set("X-RapidAPI-Key", "37331542c1msh425f23a2ce232d9p170023jsne16f0d955ee5");
        headers.set("X-RapidAPI-Host", "apidojo-yahoo-finance-v1.p.rapidapi.com");

        // 요청 엔터티 구성
        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();

        // API 요청
        ResponseEntity<Map> response =
                restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

        // 응답 구조: {quoteResponse={result=[{...}], error=null}}
        Map body = response.getBody();
        if (body == null || !body.containsKey("quoteResponse")) {
            return Map.of("error", "Invalid API response");
        }

        Map quoteResponse = (Map) body.get("quoteResponse");
        List<Map> resultList = (List<Map>) quoteResponse.get("result");

        if (resultList != null && !resultList.isEmpty()) {
            return resultList.get(0); // ✅ result[0]만 반환 (실제 주가 데이터)
        }

        return Map.of("error", "No data found for symbol: " + symbol);
    }

    // ✅ 기본 종목(삼성전자) 조회용 엔드포인트
    @GetMapping("/")
    public Object defaultStock() {
        return getStock("005930");
    }
}
