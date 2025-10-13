package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
public class ChartController {

    @RequestMapping("/chart")
    public String chart(Model model) {
        // center.jsp 대신 stock.jsp를 index.jsp에 포함
        model.addAttribute("center", "chart/center");
        model.addAttribute("left", "chart/left");
        return "index";
    }
    @RequestMapping("/chart1")
    public String chart1(Model model) {
        // center.jsp 대신 stock.jsp를 index.jsp에 포함
        model.addAttribute("center", "chart/chart1");
        model.addAttribute("left", "chart/left");
        return "index";
    }
   
}