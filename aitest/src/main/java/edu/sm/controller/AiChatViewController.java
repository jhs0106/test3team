package edu.sm.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@RequiredArgsConstructor
public class AiChatViewController {

    // 기존 프로젝트에서 쓰던 WebSocket 베이스 URL
    @Value("${app.websocket.url:${websocket.url:/}}")
    private String webSocketUrl;

    // 사람 상담 페이지 URL (서버사이드에서 생성해서 data-*로 내려준다)
    // JSP에서 <c:url> 쓰면 제일 정확하지만, 여기서는 컨트롤러에서도 한 번 전달.
    private static final String INQUIRY_PATH = "/websocket/inquiry";

    @GetMapping("/aichat")
    public String aichat(Model model) {
        model.addAttribute("websocketurl", webSocketUrl);
        model.addAttribute("inquiryUrl", INQUIRY_PATH); // JS에서 data-*로 읽어감
        model.addAttribute("center", "aichat");         // index.jsp include용
        model.addAttribute("left", "left");
        return "index";
    }
}
