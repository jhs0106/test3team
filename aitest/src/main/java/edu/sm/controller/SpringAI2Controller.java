package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
@RequestMapping("/springai2")
public class SpringAI2Controller {

    String dir = "springai2/";
    @RequestMapping("")
    public String aimain(Model model) {
        model.addAttribute("center", dir+"center");
        model.addAttribute("left", dir+"left");
        return "index";
    }

    @RequestMapping("/ai1")
    public String ai1(Model model) {
       model.addAttribute("center", dir+"ai1");
       model.addAttribute("left", dir+"left");
       return "index";
    }
    @RequestMapping("/ai2")
    public String ai2(Model model) {
        model.addAttribute("center", dir+"ai2");
        model.addAttribute("left", dir+"left");
        return "index";
    }
    @RequestMapping("/ai3")
    public String ai3(Model model) {
        model.addAttribute("center", dir+"ai3");
        model.addAttribute("left", dir+"left");
        return "index";
    }
    @RequestMapping("/ai4")
    public String ai4(Model model) {
        model.addAttribute("center", dir+"ai4");
        model.addAttribute("left", dir+"left");
        return "index";
    }
    @RequestMapping("/ai5")
    public String ai5(Model model) {
        model.addAttribute("center", dir+"ai5");
        model.addAttribute("left", dir+"left");
        return "index";
    }
    @RequestMapping("/ai6")
    public String ai6(Model model) {
        model.addAttribute("center", dir+"ai6");
        model.addAttribute("left", dir+"left");
        return "index";
    }


}