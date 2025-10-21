// src/main/java/edu/sm/controller/AiChatController.java
package edu.sm.controller;

import edu.sm.app.dto.AiResponse;
import edu.sm.app.dto.ChatTurnRequest;
import edu.sm.app.service.AiChatService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/aichat-api")
@Slf4j
@RequiredArgsConstructor
public class AiChatController {

    private final AiChatService aiChatService;

    @PostMapping(value = "/message", consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public AiResponse message(@RequestBody ChatTurnRequest req, HttpSession session) {
        String loginId = null;
        try {
            Object loginMember = session.getAttribute("loginMember");
            if (loginMember instanceof String) {
                loginId = (String) loginMember;
            } else if (loginMember != null) {
                // loginMember.getLoginId() 식 리플렉션 방어적 처리
                try {
                    var m = loginMember.getClass().getMethod("getLoginId");
                    Object v = m.invoke(loginMember);
                    if (v != null) loginId = String.valueOf(v);
                } catch (Exception ignore) {}
            }
            if (loginId == null) {
                Object s = session.getAttribute("loginId");
                if (s != null) loginId = String.valueOf(s);
            }
        } catch (Exception ignore) {}

        return aiChatService.chat(req, loginId);
    }
}
