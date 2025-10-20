package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
@RequestMapping("/appearance")
public class AiAppearanceController {

    String dir = "appearance/";

    @RequestMapping("")
    public String aimain(Model model) {
        model.addAttribute("center", dir+"center");
        model.addAttribute("left", dir+"left");
        return "index";
    }
    @RequestMapping("/face")
    public String face(Model model) {
        model.addAttribute("center", dir+"face");
        model.addAttribute("left", dir+"left");
        return "index";
    }
    @RequestMapping("/clothes")
    public String clothes(Model model) {
        model.addAttribute("center", dir+"clothes");
        model.addAttribute("left", dir+"left");
        return "index";
    }
}