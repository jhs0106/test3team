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
            // ===============================
            // ① 남성 중심 묘사 (명시적으로 남성으로 한정)
            // ===============================
            String genderDesc = """
                    Male model, masculine features, short hair, natural expression.
                    Realistic skin tone, Asian male appearance preferred.
                    """;

            // ===============================
            // ② 카테고리별 촬영 구도 설정
            // ===============================
            String focusDesc = switch (req.getCategory() == null ? "tops" : req.getCategory().toLowerCase()) {
                case "bottoms" -> "Full-body shot, focus on pants and lower outfit, standing pose, straight posture.";
                case "outer" -> "Half-body shot, showing jacket or coat clearly over outfit.";
                case "onepiece" -> "Full-body portrait, showing entire outfit naturally.";
                default -> "Upper-body portrait, focus on top outfit with realistic body fit.";
            };

            // ===============================
            // ③ 최종 프롬프트
            // ===============================
            String desc = """
                    Fashion look visualization for male styling.
                    %s
                    Outfit: %s, color %s.
                    %s
                    Lighting soft and natural, background plain studio.
                    Maintain real proportion and realistic clothes texture.
                    """.formatted(genderDesc, req.getGarmentId(), req.getColorHex(), focusDesc);

            // ===============================
            // ④ 이미지 생성 요청
            // ===============================
            ImageMessage msg = new ImageMessage(desc);

            OpenAiImageOptions opt = OpenAiImageOptions.builder()
                    .model("dall-e-3")
                    .responseFormat("b64_json")
                    .width(1024)
                    .height(1024)
                    .N(1)
                    .build();

            ImagePrompt prompt = new ImagePrompt(List.of(msg), opt);
            ImageResponse res = imageModel.call(prompt);

            // ===============================
            // ⑤ 결과 처리
            // ===============================
            String b64 = res.getResult().getOutput().getB64Json();
            out.setStatus("done");
            out.setImageB64("data:image/png;base64," + b64);
            return out;

        } catch (Exception e) {
            log.error("tryOn failed", e);
            out.setStatus("failed");
            out.setMessage(e.getMessage());
            return out;
        }
    }
}
