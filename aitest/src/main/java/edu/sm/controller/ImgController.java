package edu.sm.controller;

import edu.sm.app.dto.Member;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("createimg")
public class ImgController {
    private static final String dir = "createimg/";

    @GetMapping("")
    public String view(Model model){
        model.addAttribute("center", dir + "center");
        model.addAttribute("left", dir + "left");
        return "index";
    }
    @GetMapping("/createimg1")
    public String createimg1(Model model){
        model.addAttribute("center", dir + "createimg1");
        model.addAttribute("left", dir + "left");
        return "index";
    }
    @GetMapping("/createimg2")
    public String createimg2(Model model){
        model.addAttribute("center", dir + "createimg2");
        model.addAttribute("left", dir + "left");
        return "index";
    }
}