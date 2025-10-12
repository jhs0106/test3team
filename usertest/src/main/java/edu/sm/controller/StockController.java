package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
public class StockController {

    @RequestMapping("/stock")
    public String stock(Model model) {
        // center.jsp 대신 stock.jsp를 index.jsp에 포함
        model.addAttribute("center", "stock");
        return "index";
    }
}