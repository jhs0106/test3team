package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

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

    @Value("${app.url.operationbase}")
    String operationBaseUrl;

    private void prepareCommon(Model model) {
        model.addAttribute("sseUrl", sseUrl);
        model.addAttribute("operationBaseUrl", operationBaseUrl);
    }

    @RequestMapping("/")
    public String main(Model model) {
        prepareCommon(model);
        return "index";
    }

    @RequestMapping("/chart")
    public String chart(Model model) {
        prepareCommon(model);
        model.addAttribute("mainsseUrl",mainsseUrl);
        model.addAttribute("center", "chart");
        return "index";
    }

    @RequestMapping("/chat")
    public String chat(Model model) {
        prepareCommon(model);
        model.addAttribute("wsurl",wsurl);
        model.addAttribute("center", "chat");
        return "index";
    }

    @RequestMapping("/websocket")
    public String websocket(Model model) {
        prepareCommon(model);
        model.addAttribute("websocketurl",websocketurl);
        model.addAttribute("center", "websocket");
        return "index";
    }

    @RequestMapping("/chatroom")
    public String chatroom(Model model) {
        model.addAttribute("center", "chatroom");
        return "index";
    }

    @RequestMapping("/chatroom/detail")
    public String chatroomDetail(@RequestParam("roomId") Long roomId,
                                 @RequestParam("custId") String custId,
                                 Model model) {
        prepareCommon(model);
        model.addAttribute("wsurl", wsurl);
        model.addAttribute("roomId", roomId);
        model.addAttribute("custId", custId);
        model.addAttribute("center", "chatroom-detail");
        return "index";
    }

    @RequestMapping("/operation")
    public String operation(Model model) {
        prepareCommon(model);
        model.addAttribute("center", "operation");
        return "index";
    }


}