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
            String gender = (req.getGender() == null) ? "남성" : req.getGender().trim();
            String genderDesc;
            String stylingFocus;
            String pronoun;
            String fashionType;

            if (gender.equalsIgnoreCase("여성") || gender.equalsIgnoreCase("female")) {
                genderDesc = """
                        A realistic Asian woman model, feminine and elegant.
                        Medium to long hair, gentle natural makeup, soft facial expression.
                        Wearing the described outfit naturally, standing pose.
                        """;
                stylingFocus = "female outfit styling, women’s fashion trend visualization";
                pronoun = "her";
                fashionType = "women's fashion";
            } else {
                genderDesc = """
                        A realistic Asian man model, masculine and neat.
                        Short hair, natural facial expression, confident standing pose.
                        Wearing the described outfit naturally.
                        """;
                stylingFocus = "male outfit styling, men’s fashion trend visualization";
                pronoun = "his";
                fashionType = "men's fashion";
            }

            String cat = (req.getCategory() == null) ? "tops" : req.getCategory().toLowerCase();

            String focusDesc = switch (cat) {
                case "bottoms" -> """
                        Full-body photo showing pants and shoes completely.
                        Focus clearly on lower-body outfit fit and proportion.
                        """;
                case "onepiece" -> """
                        Full-body portrait showing complete dress silhouette.
                        Capture posture and fabric flow naturally.
                        """;
                case "outer" -> """
                        Half-body image emphasizing the coat or jacket layering.
                        """;
                default -> """
                        Upper-body shot showing neckline, shoulders, and fit of top wear.
                        """;
            };

            // ✅ 프롬프트를 더 강력하게 수정
            String desc = """
                    %s — AI virtual try-on rendering.
                    Depict %s being worn by a %s model.
                    %s
                    Garment: %s (%s), color tone %s.
                    %s
                    Ensure that %s body proportion is natural and realistic.
                    Studio lighting, plain background, high detail clothing texture.
                    """.formatted(
                    stylingFocus,
                    fashionType,
                    gender.equalsIgnoreCase("여성") ? "female" : "male",
                    genderDesc,
                    req.getGarmentId(),
                    fashionType,
                    req.getColorHex(),
                    focusDesc,
                    pronoun
            );

            log.info("[TRYON PROMPT]\n{}", desc);

            ImageMessage msg = new ImageMessage(desc);

            OpenAiImageOptions.Builder builder = OpenAiImageOptions.builder()
                    .model("dall-e-3")
                    .responseFormat("b64_json")
                    .N(1);

            if ("bottoms".equals(cat) || "onepiece".equals(cat)) {
                builder.width(1024).height(1792);
            } else {
                builder.width(1024).height(1024);
            }

            OpenAiImageOptions opt = builder.build();
            ImagePrompt prompt = new ImagePrompt(List.of(msg), opt);
            ImageResponse res = imageModel.call(prompt);

            String b64 = res.getResult().getOutput().getB64Json();
            out.setStatus("done");
            out.setImageB64("data:image/png;base64," + b64);

            log.info("[TRYON OK] gender={}, category={}, size={}x{}", gender, cat, opt.getWidth(), opt.getHeight());

            return out;

        } catch (Exception e) {
            log.error("tryOn failed", e);
            out.setStatus("failed");
            out.setMessage(e.getMessage());
            return out;
        }
    }
}
