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

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class VirtualTryOnService {

    private final ImageModel imageModel;

    /** 간단 HEX -> 컬러명 매핑 (원하는 색 추가 가능) */
    private static final Map<String, String> HEX_NAME = new LinkedHashMap<>() {{
        put("#000000", "pure black");
        put("#111111", "almost black");
        put("#1f2937", "charcoal gray");
        put("#374151", "slate gray");
        put("#6b7280", "cool gray");
        put("#808080", "gray");
        put("#9ca3af", "light gray");
        put("#cbd5e1", "pale gray");
        put("#ffffff", "pure white");
        put("#fffaf0", "ivory");
        put("#f7f3e6", "ivory beige");
        put("#f5e6f7", "light pink");
        put("#ffe4e1", "soft coral pink");
        put("#e6eef7", "soft pastel blue");
        put("#dbeafe", "light baby blue");
        put("#93c5fd", "sky blue");
        put("#60a5fa", "blue");
        put("#22c55e", "fresh green");
        put("#f59e0b", "amber");
        put("#ef4444", "red");
    }};

    private static String normalizeHex(String hex) {
        if (hex == null) return "";
        hex = hex.trim();
        if (hex.isEmpty()) return "";
        if (!hex.startsWith("#")) hex = "#" + hex;
        return hex.toLowerCase(Locale.ROOT);
    }

    private static boolean isGrayScale(String hex) {
        String h = normalizeHex(hex);
        if (HEX_NAME.containsKey(h) && HEX_NAME.get(h).contains("gray")) return true;
        if (h.length() == 7) {
            try {
                int r = Integer.parseInt(h.substring(1,3),16);
                int g = Integer.parseInt(h.substring(3,5),16);
                int b = Integer.parseInt(h.substring(5,7),16);
                return Math.abs(r-g) < 8 && Math.abs(g-b) < 8;
            } catch (Exception ignored) {}
        }
        return false;
    }

    private static String colorPromptFromHex(String hex) {
        String norm = normalizeHex(hex);
        String name = HEX_NAME.getOrDefault(norm, "");
        if (!name.isBlank()) {
            return name + " (" + norm + ")";
        }
        return "exact " + norm + " color";
    }

    public TryOnResult tryOn(MultipartFile selfie, TryOnRequest req) {
        TryOnResult out = new TryOnResult();

        try {
            // ---------- 0) 입력 정리 ----------
            final String genderIn = (req.getGender() == null) ? "" : req.getGender().trim();
            final String gender = genderIn.isBlank() ? "남성" : genderIn;
            final String cat = (req.getCategory() == null) ? "tops" : req.getCategory().toLowerCase(Locale.ROOT);
            final String hex = normalizeHex(req.getColorHex());
            final String colorPrompt = colorPromptFromHex(hex);
            final boolean grayish = isGrayScale(hex);

            // ---------- 1) 성별 프롬프트 ----------
            String genderDesc;
            String stylingFocus;
            String pronoun;
            String fashionType;

            if (gender.equalsIgnoreCase("여성") || gender.equalsIgnoreCase("female") || gender.equalsIgnoreCase("woman")) {
                genderDesc = """
                        A realistic Asian woman model (female). Feminine and elegant,
                        medium to long hair, gentle natural makeup, soft facial expression.
                        Wearing the described outfit naturally, standing pose.
                        """;
                stylingFocus = "female outfit styling, women’s fashion visualization";
                pronoun = "her";
                fashionType = "women's fashion";
            } else {
                genderDesc = """
                        A realistic Asian man model (male). Masculine and neat,
                        short hair, natural facial expression, confident standing pose.
                        Wearing the described outfit naturally.
                        """;
                stylingFocus = "male outfit styling, men’s fashion visualization";
                pronoun = "his";
                fashionType = "men's fashion";
            }

            // ---------- 2) 구도 프롬프트 ----------
            String focusDesc = switch (cat) {
                case "bottoms" -> """
                        Full-body photo, head-to-toe framing.
                        Pants and shoes must be completely visible, with clear focus on lower-body fit and proportion.
                        """;
                case "onepiece" -> """
                        Full-body portrait showing the entire dress silhouette and fabric drape naturally.
                        """;
                case "outer" -> """
                        Half-body image emphasizing the coat or jacket layering over the outfit.
                        """;
                default -> """
                        Upper-body shot clearly showing the neckline, shoulders, and fit of the top wear.
                        """;
            };

            // ---------- 3) 색상 강제 프롬프트 ----------
            // - 명령형 문장 + HEX 직접 언급 + 회피색(Net-negatives)
            String colorHardRule = """
                    The garment color MUST be %s. Use the color exactly and dominantly on the clothing.
                    Do not shift it to other hues. %s
                    """.formatted(
                    colorPrompt,
                    grayish
                            ? "" // 회색이면 무채색 허용
                            : "Avoid grayscale, black, or desaturated tones unless they match the specified color."
            );

            // ---------- 4) 최종 프롬프트 ----------
            String desc = """
                    %s — AI virtual try-on rendering.
                    Depict %s being worn by a %s model.
                    %s
                    Garment: %s (%s).
                    %s
                    %s
                    Ensure that %s body proportion is natural and realistic.
                    Studio lighting, plain background, high detail clothing texture.
                    """.formatted(
                    stylingFocus,
                    fashionType,
                    (gender.equalsIgnoreCase("여성") ? "female" : "male"),
                    genderDesc,
                    req.getGarmentId(),
                    fashionType,
                    focusDesc,
                    colorHardRule,
                    pronoun
            );

            log.info("[TRYON PROMPT]\n{}", desc);

            // ---------- 5) 이미지 옵션 ----------
            OpenAiImageOptions.Builder builder = OpenAiImageOptions.builder()
                    .model("dall-e-3")
                    .responseFormat("b64_json")
                    .N(1);

            if ("bottoms".equals(cat) || "onepiece".equals(cat)) {
                builder.width(1024).height(1792);  // 세로 비율: 전신
            } else {
                builder.width(1024).height(1024);  // 정사각: 상·반신
            }

            OpenAiImageOptions opt = builder.build();

            // ---------- 6) 호출 ----------
            ImagePrompt prompt = new ImagePrompt(List.of(new ImageMessage(desc)), opt);
            ImageResponse res = imageModel.call(prompt);

            // ---------- 7) 결과 ----------
            String b64 = res.getResult().getOutput().getB64Json();
            out.setStatus("done");
            out.setImageB64("data:image/png;base64," + b64);

            log.info("[TRYON OK] gender={}, category={}, colorHex={}, size={}x{}",
                    gender, cat, hex, opt.getWidth(), opt.getHeight());

            return out;

        } catch (Exception e) {
            log.error("tryOn failed", e);
            out.setStatus("failed");
            out.setMessage(e.getMessage());
            return out;
        }
    }
}
