package edu.sm.controller;

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
        model.addAttribute("center", dir + "map");   // => /views/map/map.jsp
        model.addAttribute("left",   dir + "left");  // => /views/map/left.jsp
        return "index";                               // => /views/index.jsp
    }
}
