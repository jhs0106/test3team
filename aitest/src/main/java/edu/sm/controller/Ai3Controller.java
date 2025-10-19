package edu.sm.controller;



import edu.sm.app.springai.service3.AiImageService;
import edu.sm.app.springai.service3.AiSttService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/ai3")
@Slf4j
@RequiredArgsConstructor
public class Ai3Controller {

  final private AiSttService aisttService;
  final private AiImageService aiImageService;

  @RequestMapping(value = "/stt")
  public String stt(@RequestParam("speech") MultipartFile speech) throws IOException {
    String text = aisttService.stt(speech);
    return text;
  }
  @RequestMapping(value = "/stt2")
  public String stt2(@RequestParam("speech") MultipartFile speech) throws IOException {
    String text = aisttService.stt(speech);
    Map<String, String> views = new ConcurrentHashMap<>();
    log.info("인식결과 : "+text);

    views.put("로그인", "/login");
    views.put("회원가입", "/register");
    views.put("회원 가입", "/register");
    views.put("홈", "/");

    String result = views.get(text.trim());
    return result;
  }


  @RequestMapping(value = "/tts")
  public byte[] tts(@RequestParam("text") String text) {
    byte[] bytes = aisttService.tts(text);
    return bytes;
  }

  @RequestMapping(value = "/tts2")
  public Map<String, String> tts2(@RequestParam("text") String text) {
    Map<String, String> response = aisttService.tts2(text);
    return response;
  }


  @RequestMapping(value = "/chat-text")
  public Map<String, String> chatText(@RequestParam("question") String question) {
    Map<String, String> response = aisttService.chatText(question);
    return response;
  }


  @RequestMapping(value = "/image-analysis")
  public Flux<String> imageAnalysis(
          @RequestParam("question") String question,
          @RequestParam(value="attach", required = false) MultipartFile attach) throws IOException {
    // 이미지가 업로드 되지 않았을 경우
    if (attach == null || !attach.getContentType().contains("image/")) {
      Flux<String> response = Flux.just("이미지를 올려주세요.");
      return response;
    }

    Flux<String> flux = aiImageService.imageAnalysis(question, attach.getContentType(), attach.getBytes());
    return flux;
  }

  @RequestMapping(value = "/image-analysis2")
  public Map<String,String> imageAnalysis2(
          @RequestParam("question") String question,
          @RequestParam(value="attach", required = false) MultipartFile attach) throws IOException {

    String result = aiImageService.imageAnalysis2(question, attach.getContentType(), attach.getBytes());
    byte[] audio = aisttService.tts(result);
    String base64Audio = Base64.getEncoder().encodeToString(audio);

    // 텍스트 답변과 음성 답변을 Map에 저장
    Map<String, String> response = new HashMap<>();
    response.put("text", result);
    response.put("audio", base64Audio);

    return response;
  }


  @RequestMapping( value = "/image-generate" )
  public String imageGenerate(@RequestParam("question") String question) {
    log.info("start imageGenerate-------------");
    try {
      String b64Json = aiImageService.generateImage(question);
      return b64Json;
    } catch(Exception e) {
      e.printStackTrace();
      return "Error: " + e.getMessage();
    }
  }
}