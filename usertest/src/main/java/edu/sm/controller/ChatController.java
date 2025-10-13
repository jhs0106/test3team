package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@Slf4j
@RequestMapping("/websocket")
public class ChatController {
    @Value("${app.url.websocketurl}")
    String webSocketUrl;

    String dir = "websocket/";

    @RequestMapping("")
    public String Main(Model model) {
        model.addAttribute("websocketurl", webSocketUrl);
        model.addAttribute("center", dir+"center");
        model.addAttribute("left", dir+"left");
        return "index";
    }

    @RequestMapping("/video")
    public String video(Model model) {
        model.addAttribute("websocketurl", webSocketUrl);
        model.addAttribute("center", dir+"video");
        model.addAttribute("left", dir+"left");
        return "index";
    }

    @RequestMapping("/inquiry")
    public String inquiry(Model model) {
        model.addAttribute("websocketurl", webSocketUrl);
        model.addAttribute("center", dir+"inquiry");
        model.addAttribute("left", dir+"left");
        return "index";
    }

    @RequestMapping("/videocall")
    public String videocall(@RequestParam(required = false) String roomId,
                            @RequestParam(required = false) String custId,
                            Model model) {
        model.addAttribute("websocketurl", webSocketUrl);
        model.addAttribute("roomId", roomId);
        model.addAttribute("custId", custId);
        model.addAttribute("center", dir+"video");  // 기존 video.jsp 재사용
        model.addAttribute("left", dir+"left");
        return "index";
    }
}
