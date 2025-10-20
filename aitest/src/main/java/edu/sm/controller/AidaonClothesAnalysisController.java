package edu.sm.controller;

import edu.sm.app.springai.service1.AiServiceByChatClient;
import edu.sm.app.springai.service3.AiImageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/aidaon/clothes")
@RequiredArgsConstructor
@Slf4j
public class AidaonClothesAnalysisController {

    private final AiImageService aiImageService;
    private final AiServiceByChatClient aiServiceByChatClient;

    private static final Map<String, String> ANGLE_LABELS = Map.of(
            "front", "정면",
            "left", "좌측",
            "right", "우측"
    );

    @PostMapping(value = "/analyze", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> analyzeClothes(
            @RequestParam("front") MultipartFile front,
            @RequestParam("left") MultipartFile left,
            @RequestParam("right") MultipartFile right
    ) {
        Map<String, MultipartFile> uploads = new LinkedHashMap<>();
        uploads.put("front", front);
        uploads.put("left", left);
        uploads.put("right", right);

        try {
            validateUploads(uploads);
            Map<String, String> angleResults = analyzeAngles(uploads);
            String summary = buildOverallSummary(angleResults);

            Map<String, Object> response = new LinkedHashMap<>();
            response.put("angles", angleResults);
            response.put("summary", summary);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            log.warn("잘못된 요청: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of(
                    "error", e.getMessage()
            ));
        } catch (IOException e) {
            log.error("파일 처리 중 오류", e);
            return ResponseEntity.internalServerError().body(Map.of(
                    "error", "이미지 파일을 처리하는 중 문제가 발생했습니다."
            ));
        } catch (Exception e) {
            log.error("분석 요청 실패", e);
            return ResponseEntity.internalServerError().body(Map.of(
                    "error", "의상 분석에 실패했습니다. 잠시 후 다시 시도해주세요."
            ));
        }
    }

    private void validateUploads(Map<String, MultipartFile> uploads) {
        for (Map.Entry<String, MultipartFile> entry : uploads.entrySet()) {
            MultipartFile file = entry.getValue();
            if (file == null || file.isEmpty()) {
                throw new IllegalArgumentException(ANGLE_LABELS.get(entry.getKey()) + " 사진을 다시 촬영해주세요.");
            }
            String contentType = file.getContentType();
            if (!StringUtils.hasText(contentType) || !contentType.startsWith("image/")) {
                throw new IllegalArgumentException(ANGLE_LABELS.get(entry.getKey()) + " 파일이 이미지 형식이 아닙니다.");
            }
        }
    }

    private Map<String, String> analyzeAngles(Map<String, MultipartFile> uploads) throws IOException {
        Map<String, String> results = new LinkedHashMap<>();
        for (Map.Entry<String, MultipartFile> entry : uploads.entrySet()) {
            String angleKey = entry.getKey();
            MultipartFile file = entry.getValue();
            String label = ANGLE_LABELS.getOrDefault(angleKey, angleKey);

            String prompt = buildAnglePrompt(label);
            String contentType = file.getContentType();
            if (!StringUtils.hasText(contentType)) {
                contentType = "image/png";
            }

            String analysis = aiImageService.imageAnalysis2(prompt, contentType, file.getBytes());
            results.put(angleKey, analysis);
        }
        return results;
    }

    private String buildAnglePrompt(String angleLabel) {
        return """
                당신은 하이엔드 패션 하우스의 전문 스타일리스트입니다. 제공된 사진에 나타난 인물의 의상과 체형을 분석해 맞춤형 피드백을 작성하세요.

                **필수 지침**
                1. 사진에 나타난 실제 요소만 바탕으로 객관적인 관찰 결과를 작성합니다.
                2. 출력은 아래 4개의 섹션으로만 구성하며, 각 항목은 불릿 대신 문장형으로 상세하게 작성합니다.
                3. 체형, 소재, 컬러, 아이템 구성을 모두 고려해 실질적인 개선 방안을 제시합니다.

                현재 사진은 사용자의 %s 각도에서 촬영되었습니다.

                1) 체형과 사이즈 적합성 평가: 핏, 길이, 여유분 등을 세밀하게 분석하고 필요한 수정이나 추천 사이즈를 제안하세요.
                2) 컬러와 질감 조화 분석: 피부 톤과 배경을 고려해 색상 조합의 장단점을 설명하고 보완 아이템을 추천하세요.
                3) 스타일링 포인트 및 개선 제안: 실루엣을 돋보이게 할 수 있는 구체적인 연출 팁을 제안하세요.
                4) 추천 아이템 및 액세서리: 현재 룩과 조화를 이루는 추가 아이템을 2가지 이상 추천하고 이유를 설명하세요.
                """.formatted(angleLabel);
    }

    private String buildOverallSummary(Map<String, String> angleResults) {
        StringBuilder builder = new StringBuilder();
        builder.append("당신은 프리미엄 퍼스널 쇼퍼입니다.\n");
        builder.append("각 각도별 분석을 종합해 일관된 스타일 전략을 bullet 5개 이내로 정리하고, 상황별(출근, 일상, 특별한 날 등) 추천 코디 아이디어도 포함하세요.\n\n");
        angleResults.forEach((angleKey, analysis) -> {
            String label = ANGLE_LABELS.getOrDefault(angleKey, angleKey);
            builder.append(label).append(" 분석 내용:\n");
            builder.append(analysis).append("\n\n");
        });
        return aiServiceByChatClient.generateText(builder.toString());
    }
}