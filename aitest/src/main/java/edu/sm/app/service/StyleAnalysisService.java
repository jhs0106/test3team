package edu.sm.app.service;

import com.fasterxml.jackson.databind.JsonNode;
import edu.sm.app.dto.StyleAnalysisResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.content.Media;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.stereotype.Service;
import org.springframework.util.MimeType;
import org.springframework.web.multipart.MultipartFile;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.core.type.TypeReference;

import java.util.Arrays;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class StyleAnalysisService {

    private final ChatClient.Builder chatClientBuilder;
    private final ObjectMapper om = new ObjectMapper();



    public StyleAnalysisResult analyze(MultipartFile selfie) {
        try {
            var chat = chatClientBuilder.build();

            var system = SystemMessage.builder().text("""
              너는 퍼스널 컬러/패션 분석 전문가.
              아래 정확한 JSON만 반환해. 자연어/코드펜스/주석 금지.
              {
                "tone": "summer-light|winter-bright|autumn-muted|spring-light",
                "contrast": "low|medium|high",
                "faceShape": "oval|square|heart|round|oblong",
                "mood": "neutral|soft-cool|warm-bright|...",
                "palette": ["#RRGGBB", "#RRGGBB", "#RRGGBB", "#RRGGBB"],
                "quality": {"exposure": 0.0, "whiteBalance": 0.0, "needsRetake": false}
              }
            """).build();

            // [A] 업로드된 이미지 메타 로그 (여기!)
            log.info("[ANALYSIS][MEDIA] contentType={}, bytes={}", selfie.getContentType(), selfie.getSize());

            var media = Media.builder()
                    .mimeType(MimeType.valueOf(selfie.getContentType()))
                    .data(new ByteArrayResource(selfie.getBytes()))
                    .build();

            var user = UserMessage.builder()
                    .text("위 스키마 그대로 JSON만 반환.")
                    .media(media).build();

            var prompt = Prompt.builder().messages(system, user).build();
            var raw = chat.prompt(prompt).call().content();
            log.info("[ANALYSIS][RAW]\n{}", raw);


            // ```json ... ``` 제거
            String json = raw.replaceAll("^```json\\s*|\\s*```$", "").trim();

            // [C] 코드펜스 제거 후 JSON 문자열 로그 (여기!)
            log.info("[ANALYSIS][JSON]\n{}", json);

            // 안전 파싱
            JsonNode root = om.readTree(json);

            // [D] 루트/키/팔레트 노드 상태 로그 (여기!)
            log.info("[ANALYSIS][ROOT isObject={} keys={}]", root.isObject(), root.fieldNames().hasNext());
            JsonNode palNode = root.path("palette");
            log.info("[ANALYSIS][PALETTE nodeType={}, isArray={}, value={}]",
                    palNode.getNodeType(), palNode.isArray(), palNode.toString());
            if (palNode.isArray()) {
                log.info("[ANALYSIS][PALETTE size={}]", palNode.size());
            }

            StyleAnalysisResult r = new StyleAnalysisResult();
            r.setTone(optText(root,"tone","summer-light"));
            r.setContrast(optText(root,"contrast","low"));
            r.setFaceShape(optText(root,"faceShape","oval"));
            r.setMood(optText(root,"mood","neutral"));

            // palette
            if (root.has("palette") && root.get("palette").isArray()) {
                var list = om.convertValue(root.get("palette"), new TypeReference<java.util.List<String>>(){});
                r.setPalette(list);
            } else {
                r.setPalette(java.util.List.of("#cfe7f5","#e7dfff","#c7e9e3","#f7f1ea"));
            }

            // quality
            StyleAnalysisResult.Quality q = new StyleAnalysisResult.Quality();
            var qn = root.path("quality");
            q.setExposure(qn.path("exposure").asDouble(0.8));
            q.setWhiteBalance(qn.path("whiteBalance").asDouble(0.8));
            q.setNeedsRetake(qn.path("needsRetake").asBoolean(false));
            r.setQuality(q);

            return r;
        } catch (Exception e) {
            // 실패시 안전 기본값
            StyleAnalysisResult r = new StyleAnalysisResult();
            r.setTone("summer-light"); r.setContrast("low"); r.setFaceShape("oval"); r.setMood("neutral");
            r.setPalette(java.util.List.of("#cfe7f5","#e7dfff","#c7e9e3","#f7f1ea"));
            var q = new StyleAnalysisResult.Quality(); q.setExposure(0.8); q.setWhiteBalance(0.8); q.setNeedsRetake(false);
            r.setQuality(q);
            return r;
        }

    }

    private String optText(JsonNode n, String k, String def){
        return n.has(k) ? n.get(k).asText(def) : def;
    }

    private String extract(String text, String key, String def) {
        try {
            int i = text.toLowerCase().indexOf(key.toLowerCase());
            if (i < 0) return def;
            int start = text.indexOf(':', i) + 1;
            int end = text.indexOf('\n', start);
            if (end < 0) end = text.length();
            String raw = text.substring(start, end).trim();
            raw = raw.replaceAll("^[\"\\[]*", "").replaceAll("[\"\\]]*$", "");
            return raw;
        } catch (Exception e) {
            return def;
        }
    }

    private double parseDoubleSafe(String s, double def) {
        try { return Double.parseDouble(s.replaceAll("[^0-9\\.\\-]","")); }
        catch (Exception e) { return def; }
    }
}

