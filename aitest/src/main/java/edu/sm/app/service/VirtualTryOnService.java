package edu.sm.app.service;

import edu.sm.app.dto.TryOnRequest;
import edu.sm.app.dto.TryOnResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.image.ImageMessage;
import org.springframework.ai.image.ImageModel;
import org.springframework.ai.image.ImagePrompt;
import org.springframework.ai.image.ImageResponse;
import org.springframework.ai.openai.OpenAiImageOptions;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class VirtualTryOnService {

    private final ImageModel imageModel;

    public TryOnResult tryOn(MultipartFile selfie, TryOnRequest req) {
        TryOnResult out = new TryOnResult();

        try {
            // ========= 0) 요청 로그 =========
            log.info("[TRYON][REQ] garmentId={}, colorHex={}, brightness={}, saturation={}, category={}",
                    req.getGarmentId(), req.getColorHex(), req.getBrightness(), req.getSaturation(), req.getCategory());

            // ========= 1) 성별/인물 베이스 =========
            String genderDesc = """
                    Male model, masculine features, short hair, natural expression.
                    Realistic skin tone, Asian male appearance preferred.
                    """;

            // ========= 2) 카테고리별 촬영 구도 =========
            String cat = (req.getCategory() == null) ? "tops" : req.getCategory().toLowerCase();

            String focusDesc = switch (cat) {
                case "bottoms" -> """
                        Full-body shot, head-to-toe framing.
                        Standing pose, legs and shoes fully visible.
                        Focus on pants and lower outfit; do not crop the lower body.
                        """;
                case "onepiece" -> """
                        Full-body portrait, full figure in frame, natural standing pose.
                        """;
                case "outer" -> """
                        Half-body shot highlighting the jacket/coat layered over outfit.
                        """;
                default -> """
                        Upper-body portrait focusing on top garment fit.
                        """;
            };

            // ========= 3) 최종 프롬프트 =========
            String desc = """
                    Fashion look visualization for male styling.
                    %s
                    Outfit: %s, color %s.
                    %s
                    Composition: keep the required body framing; avoid unwanted cropping.
                    Lighting soft and natural; plain studio background.
                    Maintain real proportion and realistic fabric texture.
                    """.formatted(genderDesc, req.getGarmentId(), req.getColorHex(), focusDesc);

            ImageMessage msg = new ImageMessage(desc);

            // ========= 4) 이미지 옵션: 카테고리별 사이즈 =========
            // DALL·E 3는 세로 비율에서 전신샷 유지 확률↑
            OpenAiImageOptions.Builder builder = OpenAiImageOptions.builder()
                    .model("dall-e-3")
                    .responseFormat("b64_json")
                    .N(1);

            if ("bottoms".equals(cat) || "onepiece".equals(cat)) {
                // 세로형(전신)
                builder.width(1024).height(1792);
            } else {
                // 정사각(반신/상반신)
                builder.width(1024).height(1024);
            }

            OpenAiImageOptions opt = builder.build();

            // ========= 5) 호출 =========
            ImagePrompt prompt = new ImagePrompt(List.of(msg), opt);
            ImageResponse res = imageModel.call(prompt);

            // ========= 6) 결과 =========
            String b64 = res.getResult().getOutput().getB64Json();
            out.setStatus("done");
            out.setImageB64("data:image/png;base64," + b64);

            log.info("[TRYON][OK] category={}, size={}x{}",
                    cat, opt.getWidth(), opt.getHeight());

            return out;

        } catch (Exception e) {
            log.error("tryOn failed", e);
            out.setStatus("failed");
            out.setMessage(e.getMessage());
            return out;
        }
    }
}
