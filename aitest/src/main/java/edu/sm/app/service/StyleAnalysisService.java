package edu.sm.app.service;

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

import java.util.Arrays;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class StyleAnalysisService {

    private final ChatClient.Builder chatClientBuilder;

    public StyleAnalysisResult analyze(MultipartFile selfie) {
        try {
            ChatClient chat = chatClientBuilder.build();

            SystemMessage system = SystemMessage.builder()
                    .text("""
              당신은 퍼스널 컬러/패션 분석 전문가입니다.
              사용자 셀피를 보고 다음 JSON 키만 채워서 한국어로 간결하게 답하세요.
              tone(spring-light|summer-light|autumn-muted|winter-bright 등), 
              contrast(low|medium|high), faceShape, mood, palette(HEX 4~6개), 
              quality{exposure, whiteBalance, needsRetake(true/false)}.
              """)
                    .build();

            Media media = Media.builder()
                    .mimeType(MimeType.valueOf(selfie.getContentType()))
                    .data(new ByteArrayResource(selfie.getBytes()))
                    .build();

            UserMessage user = UserMessage.builder()
                    .text("셀피 기반 퍼스널 컬러/대비/얼굴형/팔레트/품질을 JSON으로만 반환해줘.")
                    .media(media)
                    .build();

            Prompt prompt = Prompt.builder().messages(system, user).build();
            String content = chat.prompt(prompt).call().content();

            // ⚠️ 간단 파서: 실제 운영 시 JSON Schema 기반 파싱/검증 권장
            StyleAnalysisResult r = new StyleAnalysisResult();
            // 기본값
            r.setTone(extract(content, "tone", "summer-light"));
            r.setContrast(extract(content, "contrast", "low"));
            r.setFaceShape(extract(content, "faceShape", "oval"));
            r.setMood(extract(content, "mood", "soft-cool"));

            List<String> palette = Arrays.asList(
                    "#cfe7f5","#e7dfff","#c7e9e3","#f7f1ea"
            );
            String pal = extract(content, "palette", null);
            if (pal != null && pal.contains("#")) {
                // 매우 간단 분리
                palette = Arrays.stream(pal.replace("[","").replace("]","")
                                .replace("\"","").split(","))
                        .map(String::trim).toList();
            }
            r.setPalette(palette);

            StyleAnalysisResult.Quality q = new StyleAnalysisResult.Quality();
            q.setExposure(parseDoubleSafe(extract(content,"exposure","0.8"), 0.8));
            q.setWhiteBalance(parseDoubleSafe(extract(content,"whiteBalance","0.8"), 0.8));
            q.setNeedsRetake(Boolean.parseBoolean(extract(content,"needsRetake","false")));
            r.setQuality(q);

            return r;
        } catch (Exception e) {
            log.error("analyze failed", e);
            // 실패 시 기본값
            StyleAnalysisResult r = new StyleAnalysisResult();
            r.setTone("summer-light");
            r.setContrast("low");
            r.setFaceShape("oval");
            r.setMood("soft-cool");
            r.setPalette(List.of("#cfe7f5","#e7dfff","#c7e9e3","#f7f1ea"));
            StyleAnalysisResult.Quality q = new StyleAnalysisResult.Quality();
            q.setExposure(0.8); q.setWhiteBalance(0.8); q.setNeedsRetake(false);
            r.setQuality(q);
            return r;
        }
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

