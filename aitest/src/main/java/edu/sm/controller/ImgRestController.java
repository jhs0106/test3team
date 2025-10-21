// src/main/java/edu/sm/controller/Ai4Controller.java
package edu.sm.controller;

import edu.sm.app.dto.StyleAnalysisResult;
import edu.sm.app.dto.StyleRecommendation;
import edu.sm.app.dto.TryOnRequest;
import edu.sm.app.dto.TryOnResult;
import edu.sm.app.service.StyleAnalysisService;
import edu.sm.app.service.StyleRecommendService;
import edu.sm.app.service.VirtualTryOnService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@RestController
@RequestMapping("/ai4")
@RequiredArgsConstructor
public class ImgRestController {

    private final StyleAnalysisService styleAnalysisService;
    private final StyleRecommendService styleRecommendService;
    private final VirtualTryOnService virtualTryOnService;

    @PostMapping(value = "/analyze", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public StyleAnalysisResult analyze(@RequestParam("selfie") MultipartFile selfie) {
        StyleAnalysisResult result = styleAnalysisService.analyze(selfie);

        // [E] 컨트롤러 응답 로그 (여기!)
        try {
            com.fasterxml.jackson.databind.ObjectMapper om = new com.fasterxml.jackson.databind.ObjectMapper();
            log.info("[ANALYSIS][RESPONSE] {}", om.writeValueAsString(result));
        } catch (Exception ignore) {}

        return result;
    }

    @PostMapping(value = "/recommend", consumes = MediaType.APPLICATION_JSON_VALUE)
    public StyleRecommendation recommend(@RequestBody StyleAnalysisResult analysis) {
        StyleRecommendation rec = styleRecommendService.recommend(analysis);

        // ★ 추가: 실제로 내려가는 JSON 구조 확인
        try {
            var om = new com.fasterxml.jackson.databind.ObjectMapper();
            log.info("[RECOMMEND][RESPONSE] {}", om.writeValueAsString(rec));
        } catch (Exception ignore) {}

        return rec;
    }

    @PostMapping(value = "/tryon", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public TryOnResult tryOn(
            @RequestPart("request") TryOnRequest request,
            @RequestPart("selfie") MultipartFile selfie) {
        return virtualTryOnService.tryOn(selfie, request);
    }
}
