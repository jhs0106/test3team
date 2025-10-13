package edu.sm.controller; // 이전 단계에서 수정된 패키지 경로

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/map")
public class MapController {

    private final String dir = "map/";

    @RequestMapping({"", "/map"})
    public String main(Model model) {
        model.addAttribute("center", dir + "map");
        model.addAttribute("left",   dir + "left");
        return "index";
    }

    @RequestMapping({"/map2"})
    public String map2(Model model) {
        model.addAttribute("center", dir + "map2");
        model.addAttribute("left",   dir + "left");
        return "index";
    }
}