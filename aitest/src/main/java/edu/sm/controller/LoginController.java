package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;


@Controller
@Slf4j

public class LoginController {

    @RequestMapping("/login")
    public String login(Model model) {
        model.addAttribute("center","login");
        model.addAttribute("left","left");
        return "index";
    }

    @RequestMapping("/register")
    public String register(Model model) {
        model.addAttribute("center","register");
        model.addAttribute("left","left");
        return "index";
    }


}