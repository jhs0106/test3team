package edu.sm.controller;

import edu.sm.app.dto.DiaryEntry;
import edu.sm.app.service.DiaryAiService;
import edu.sm.app.service.DiaryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.List;

@Controller
@Slf4j
@RequestMapping("/diary")
@RequiredArgsConstructor
public class AiDiaryController {

    private final DiaryService diaryService;
    private final DiaryAiService diaryAiService;

    private final String dir = "diary/";

    @RequestMapping("")
    public String aimain(Model model) {
        model.addAttribute("center", dir + "center");
        model.addAttribute("left", dir + "left");
        return "index";
    }

    @GetMapping("diary")
    public String diary(Model model) {
        if (!model.containsAttribute("diaryForm")) {
            model.addAttribute("diaryForm", new DiaryEntry());
        }
        model.addAttribute("today", LocalDate.now());
        model.addAttribute("center", dir + "diary");
        model.addAttribute("left", dir + "left");
        return "index";
    }

    @PostMapping("/save")
    public String saveDiary(@ModelAttribute("diaryForm") DiaryEntry diaryEntry,
                            RedirectAttributes redirectAttributes,
                            Model model) {
        if (!StringUtils.hasText(diaryEntry.getTitle()) || !StringUtils.hasText(diaryEntry.getContent())) {
            model.addAttribute("errorMessage", "제목과 내용을 모두 입력해주세요.");
            model.addAttribute("today", LocalDate.now());
            model.addAttribute("center", dir + "diary");
            model.addAttribute("left", dir + "left");
            return "index";
        }
        try {
            diaryEntry.setEntryDate(LocalDate.now());
            String feedback = diaryAiService.generateFeedback(diaryEntry.getContent());
            diaryEntry.setAiFeedback(feedback);
            diaryService.register(diaryEntry);
            redirectAttributes.addFlashAttribute("successMessage", "일기가 저장되었습니다.");
            return "redirect:/diary/view/" + diaryEntry.getDiaryId();
        } catch (Exception e) {
            log.error("Failed to save diary", e);
            model.addAttribute("errorMessage", "일기를 저장하는 중 오류가 발생했습니다.");
            model.addAttribute("today", LocalDate.now());
            model.addAttribute("center", dir + "diary");
            model.addAttribute("left", dir + "left");
            return "index";
        }
    }

    @GetMapping("/diarylist")
    public String diaryList(Model model) {
        try {
            List<DiaryEntry> entries = diaryService.get();
            model.addAttribute("entries", entries);
        } catch (Exception e) {
            log.error("Failed to load diary list", e);
            model.addAttribute("errorMessage", "일기 목록을 불러오는 중 오류가 발생했습니다.");
        }
        model.addAttribute("center", dir + "diarylist");
        model.addAttribute("left", dir + "left");
        return "index";
    }

    @GetMapping("/view/{diaryId}")
    public String viewDiary(@PathVariable Long diaryId, Model model, RedirectAttributes redirectAttributes) {
        try {
            DiaryEntry entry = diaryService.get(diaryId);
            if (entry == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "해당 일기를 찾을 수 없습니다.");
                return "redirect:/diary/diarylist";
            }
            model.addAttribute("entry", entry);
        } catch (Exception e) {
            log.error("Failed to load diary detail", e);
            redirectAttributes.addFlashAttribute("errorMessage", "일기를 불러오는 중 오류가 발생했습니다.");
            return "redirect:/diary/diarylist";
        }
        model.addAttribute("center", dir + "view");
        model.addAttribute("left", dir + "left");
        return "index";
    }
}
