package edu.sm.controller;

import edu.sm.app.springai.service3.AiVoiceProfileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

// ========================================
// 🎯 페이지 렌더링 컨트롤러 (View 반환)
// ========================================
@Controller
@Slf4j
@RequestMapping("/voice-profile")
public class VoiceProfileController {

    /**
     * 음성 프로필 생성 페이지 접속
     */
    @GetMapping("/create")
    public String voiceProfilePage(Model model) {
        model.addAttribute("center", "voice-profile");
        return "index";
    }
}

// ========================================
// 🔧 API 컨트롤러 (JSON 반환)
// ========================================
@RestController
@RequestMapping("/api/voice-profile")
@Slf4j
@RequiredArgsConstructor
class VoiceProfileApiController {

    private final AiVoiceProfileService voiceProfileService;

    /**
     * 음성 자기소개 업로드 및 AI 프로필 생성
     */
    @PostMapping("/create")
    public Map<String, Object> createVoiceProfile(
            @RequestParam("voiceFile") MultipartFile voiceFile) throws IOException {

        log.info("음성 프로필 생성 요청 - 파일: {}", voiceFile.getOriginalFilename());
        return voiceProfileService.processVoiceProfile(voiceFile);
    }

    /**
     * 음성 자기소개만 텍스트로 변환
     */
    @PostMapping("/transcribe")
    public Map<String, String> transcribeVoice(
            @RequestParam("voiceFile") MultipartFile voiceFile) throws IOException {

        String transcription = voiceProfileService.transcribeVoiceIntro(voiceFile);
        return Map.of("transcription", transcription);
    }

    /**
     * 텍스트 프로필을 AI로 요약
     */
    @PostMapping("/summarize")
    public Map<String, String> summarizeProfile(@RequestParam("text") String text) {

        String summary = voiceProfileService.summarizeProfile(text);
        return Map.of("summary", summary);
    }

    /**
     * 프로필 텍스트를 음성으로 듣기
     */
    @PostMapping("/read-aloud")
    public Map<String, String> readProfileAloud(@RequestParam("profileText") String profileText) {

        return voiceProfileService.readProfileAloud(profileText);
    }
}