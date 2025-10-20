package edu.sm.app.springai.service3;

import edu.sm.app.springai.service3.AiSttService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
public class AiVoiceProfileService {

    private final AiSttService aiSttService;
    private ChatClient chatClient;

    // ##### 생성자 #####
    public AiVoiceProfileService(AiSttService aiSttService, ChatClient.Builder chatClientBuilder) {
        this.aiSttService = aiSttService;
        this.chatClient = chatClientBuilder.build();
    }

    /**
     * 음성 자기소개를 텍스트로 변환
     */
    public String transcribeVoiceIntro(MultipartFile voiceFile) throws IOException {
        log.info("음성 자기소개 변환 시작");
        String transcription = aiSttService.stt(voiceFile);
        log.info("변환된 텍스트: {}", transcription);
        return transcription;
    }

    /**
     * AI가 자기소개를 결혼정보회사 프로필 형식으로 요약
     */
    public String summarizeProfile(String rawIntroduction) {
        log.info("프로필 요약 시작");

        String summary = chatClient.prompt()
                .system("""
                당신은 결혼정보회사의 전문 프로필 작성 컨설턴트입니다.
                고객이 음성으로 녹음한 자기소개를 듣기 좋고 매력적인 프로필로 정리해주세요.
                
                **요구사항:**
                - 3-5문장으로 간결하게 요약
                - 나이, 직업, 성격, 취미, 이상형 등의 핵심 정보를 포함
                - 긍정적이고 따뜻한 톤으로 작성
                - 존댓말 사용
                - 과도한 수식어 제거
                
                **나쁜 예시:** "저는 평범한 사람이고요, 뭐 특별한 건 없는데..."
                **좋은 예시:** "30대 초반 IT 기업에 재직 중이시며, 주말에는 등산과 요리를 즐기시는 분입니다."
                """)
                .user("""
                다음 자기소개를 결혼정보회사 프로필 형식으로 요약해주세요:
                
                %s
                """.formatted(rawIntroduction))
                .call()
                .content();

        log.info("요약된 프로필: {}", summary);
        return summary;
    }

    /**
     * 요약된 프로필을 음성으로 변환
     */
    public byte[] generateVoiceProfile(String summary) {
        log.info("음성 프로필 생성 시작");
        byte[] audioBytes = aiSttService.tts(summary);
        log.info("음성 생성 완료: {} bytes", audioBytes.length);
        return audioBytes;
    }

    /**
     * 전체 프로세스 실행: 음성 녹음 → 텍스트 변환 → AI 요약 → 음성 생성
     */
    public Map<String, Object> processVoiceProfile(MultipartFile voiceFile) throws IOException {
        // 1. 음성 → 텍스트
        String transcription = transcribeVoiceIntro(voiceFile);

        // 2. AI 요약
        String summary = summarizeProfile(transcription);

        // 3. 요약 → 음성
        byte[] voiceProfileBytes = generateVoiceProfile(summary);
        String base64Audio = Base64.getEncoder().encodeToString(voiceProfileBytes);

        // 결과 반환
        Map<String, Object> result = new HashMap<>();
        result.put("originalText", transcription);      // 원본 텍스트
        result.put("summary", summary);                 // AI 요약
        result.put("voiceProfile", base64Audio);        // 음성 프로필 (Base64)

        return result;
    }

    /**
     * 다른 회원의 프로필을 음성으로 듣기
     */
    public Map<String, String> readProfileAloud(String profileText) {
        log.info("프로필 음성 변환: {}", profileText);

        Map<String, String> response = aiSttService.tts2(profileText);
        return response;
    }
}