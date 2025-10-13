package edu.sm.controller;

import edu.sm.app.service.OperationMetricService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
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
 * - 안정적 응답
 * - 한국 종목은 .KS 자동 추가
 * - 500건 제한
 */
@RestController
@RequestMapping("/api/stocks")
@RequiredArgsConstructor
@Slf4j
public class ChartRestController {

    @Value("${app.yahoo.key}")
    private String API_KEY;     //API KEY : Yahoo Finance에 접근할 수 있도록 RapidAPI가 대신 인증

    private static final String API_HOST = "apidojo-yahoo-finance-v1.p.rapidapi.com";   //RapidAPI가 제공하는 Yahoo Finance의 주소
    private static final String BASE_URL = "https://" + API_HOST + "/market/v2/get-quotes"; //주식 정보를 조회할 때 사용하는 기본 URL

    private final OperationMetricService operationMetricService;    //요청 성능 기록용 서비스

    @GetMapping("/{symbol}")    // 사용자가 요청한 종목 코드 (삼성전자면 005930임)
    public Map<String, Object> getStock(@PathVariable String symbol) {
        String normalizedSymbol = symbol == null ? "" : symbol.trim().toUpperCase();
        if (normalizedSymbol.isEmpty()) {
            normalizedSymbol = "005930"; // 기본값: 삼성전자
        }
//      실제 서버가 요청하느 주소 형태 : https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/v2/get-quotes?region=KR&symbols=005930.KS
        String url = BASE_URL + "?region=KR&symbols=" + normalizedSymbol +
                (normalizedSymbol.matches("\\d+") ? ".KS" : "");//      RapidAPI에서 승인된 사용자로 인식하기 위한 두개의 헤더 값
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-RapidAPI-Key", API_KEY);
        headers.set("X-RapidAPI-Host", API_HOST);
//      요청 보내기
        HttpEntity<String> entity = new HttpEntity<>(headers);  // 헤더 + 요청정보를 한 덩어리로 만듦
        RestTemplate restTemplate = new RestTemplate();     // RestTemplate : 스프링이 제공하는 외부 API 요청 도구

        try {
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);   // exchange -> get요청 보냄
            Map body = response.getBody();  // 결과(json)를 Map 형태로 반환해서 받음
            if (body == null || !body.containsKey("quoteResponse")) {
                operationMetricService.recordChartRequest(normalizedSymbol, null, false, null, null, null, null);
                log.warn("잘못된 응답 구조: symbol={} body={}", normalizedSymbol, body);
                return Map.of("error", "Invalid API response structure");
            }
    //      응답 확인 및 데이터 파싱 : 응답 json의 첫번째 종목 데이터 가져옴
            Map quoteResponse = (Map) body.get("quoteResponse");
            List<Map> results = (List<Map>) quoteResponse.get("result");

            if (results == null || results.isEmpty()) {
                operationMetricService.recordChartRequest(normalizedSymbol, null, false, null, null, null, null);
                return Map.of("error", "No data found for symbol: " + normalizedSymbol);
            }
//          종목이름, 현재가, 변동률, 거래량, 시가총액을 각 형태에 맞게 변환해 저장
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
            // 결과를 json으로 전달
            return Map.of(
                    "symbol", result.getOrDefault("symbol", normalizedSymbol),
                    "longName", name,
                    "regularMarketPrice", safePrice,
                    "regularMarketChangePercent", safeChange,
                    "regularMarketVolume", safeVolume,
                    "marketCap", safeMarketCap,
                    "fiftyTwoWeekRange", result.getOrDefault("fiftyTwoWeekRange", "-")
            );
        // 서버 죽거나 네트워크 끊기면 에러 반환
        } catch (Exception e) {
            log.error("주가 API 호출 실패 - symbol={}", normalizedSymbol, e);
            operationMetricService.recordChartRequest(normalizedSymbol, null, false, null, null, null, null);
            return Map.of("error", "API 요청 실패: " + e.getMessage());
        }
    }
    // 기본종목 정보 불러오는 기본 엔드포인트
    @GetMapping("/")
    public Map<String, Object> defaultStock() {
        return getStock("005930");
    }   // getstock함수 재활용

    private Double toDouble(Object value) {
        // 이미 숫자면 바로 double로 반환
        if (value instanceof Number number) {
            return number.doubleValue();
        }
//        문자열이면 쉼표 제거 후 double로 반환
        if (value instanceof String str && !str.isBlank()) {
            try {
                return Double.parseDouble(str.replaceAll(",", ""));
            } catch (NumberFormatException ignored) {
            }
        }
        return null;
    }

    // 숫자면 바로 long으로 변환, 문자열이면 쉼표 제거후 변환
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

    @GetMapping("/global")
    public ResponseEntity<String> getGlobalStocks() {
        try {
            // ✅ 1. 콤마로 여러 지수 요청 (한 번에 8개)
            String symbols = "^KS11,^N225,^DJI,^IXIC,^GSPC,^GDAXI,000001.SS,^BSESN";
            String url = BASE_URL + "?region=US&symbols=" + symbols;

            // ✅ 2. HTTP 헤더 설정 (RapidAPI 인증용)
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-RapidAPI-Key", API_KEY);
            headers.set("X-RapidAPI-Host", "apidojo-yahoo-finance-v1.p.rapidapi.com");

            HttpEntity<String> entity = new HttpEntity<>(headers);
            RestTemplate restTemplate = new RestTemplate();

            // ✅ 3. 실제 API 요청
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

            log.info("🌍 글로벌 주가지수 데이터 요청 성공");
            return ResponseEntity.ok(response.getBody());
        } catch (Exception e) {
            log.error("🌍 글로벌 지수 API 호출 실패", e);
            return ResponseEntity.status(500).body("{}");
        }
    }
}
