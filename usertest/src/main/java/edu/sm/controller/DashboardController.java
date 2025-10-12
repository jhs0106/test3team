package edu.sm.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequiredArgsConstructor
@RequestMapping("/dashboard")
public class DashboardController {


    @Value("${app.url.adminsse:/api/sse/dashboard}")
    private String adminSseUrl;

    @RequestMapping ("")
    public String dashboard(Model model) {
        model.addAttribute("center", "dashboard");
        model.addAttribute("adminSseUrl", adminSseUrl);
        return "index";
    }
}