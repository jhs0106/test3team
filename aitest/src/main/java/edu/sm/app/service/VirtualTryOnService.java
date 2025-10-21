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
import java.util.Base64;

@Slf4j
@Service
@RequiredArgsConstructor
public class VirtualTryOnService {

    private final ImageModel imageModel;

    public TryOnResult tryOn(MultipartFile selfie, TryOnRequest req) {
        TryOnResult out = new TryOnResult();
        try {
            String desc = """
          Create a realistic portrait preview of a person wearing the selected outfit.
          The style should match: garmentId=%s, color=%s.
          Keep a soft, flattering lighting, fashion photo grade, upper-body framing.
          """.formatted(req.getGarmentId(), req.getColorHex());

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
