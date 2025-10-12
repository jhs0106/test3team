package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

//
@Controller
@Slf4j
public class MainController {

    @Value("${app.url.sse}")
    String sseUrl;
    @Value("${app.url.mainsse}")
    String mainsseUrl;

    @Value("${app.url.wsurl}")
    String wsurl;

    @Value("${app.url.websocketurl}")
    String websocketurl;

    @RequestMapping("/")
    public String main(Model model) {
        model.addAttribute("sseUrl",sseUrl);
        return "index";
    }

    @RequestMapping("/chart")
    public String chart(Model model) {
        model.addAttribute("mainsseUrl",mainsseUrl);
        model.addAttribute("center", "chart");
        return "index";
    }

    @RequestMapping("/chat")
    public String chat(Model model) {
        model.addAttribute("wsurl",wsurl);
        model.addAttribute("center", "chat");
        return "index";
    }

    @RequestMapping("/websocket")
    public String websocket(Model model) {
        model.addAttribute("websocketurl",websocketurl);
        model.addAttribute("center", "websocket");
        return "index";
    }

    @RequestMapping("/chatroom")
    public String chatroom(Model model) {
        model.addAttribute("center", "chatroom");
        return "index";
    }
}