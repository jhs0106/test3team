package edu.sm.controller;

import edu.sm.app.dto.Member;
import edu.sm.app.service.MemberService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@Slf4j
@RequiredArgsConstructor
public class LoginController {

    private final MemberService memberService;

    @GetMapping("/login")
    public String loginForm(Model model) {
        model.addAttribute("loginMember", new Member());
        model.addAttribute("center", "login");
        model.addAttribute("left", "left");
        return "index";
    }

    @PostMapping("/login")
    public String login(@ModelAttribute("loginMember") Member loginMember,
                        BindingResult bindingResult,
                        HttpSession session,
                        RedirectAttributes redirectAttributes,
                        Model model) {
        try {
            Member member = memberService.login(loginMember.getLoginId(), loginMember.getPassword());
            session.setAttribute("loginMember", member);
            redirectAttributes.addFlashAttribute("loginMessage", member.getName() + "님 환영합니다.");
            return "redirect:/";
        } catch (IllegalArgumentException e) {
            bindingResult.reject("loginError", e.getMessage());
        }
        model.addAttribute("loginMember", loginMember);
        model.addAttribute("center", "login");
        model.addAttribute("left", "left");
        return "index";
    }

    @GetMapping("/register")
    public String registerForm(Model model) {
        Member member = new Member();
        member.setMembershipLevel("스탠다드");
        member.setGender("남성");
        model.addAttribute("registerMember", member);
        model.addAttribute("center", "register");
        model.addAttribute("left", "left");
        return "index";
    }

    @PostMapping("/register")
    public String register(@ModelAttribute("registerMember") Member member,
                           BindingResult bindingResult,
                           RedirectAttributes redirectAttributes,
                           Model model) {
        try {
            Member persisted = memberService.registerMember(member);
            String message = String.format("%s님의 계정이 생성되었습니다. 로그인해주세요.", persisted.getName());
            redirectAttributes.addFlashAttribute("registerMessage", message);
            return "redirect:/login";
        } catch (IllegalArgumentException e) {
            bindingResult.reject("registerError", e.getMessage());
        }
        model.addAttribute("registerMember", member);
        model.addAttribute("center", "register");
        model.addAttribute("left", "left");
        return "index";
    }

    @RequestMapping("/logout")
    public String logout(HttpSession session, SessionStatus status, RedirectAttributes redirectAttributes) {
        if (session != null) {
            session.removeAttribute("loginMember");
            session.invalidate();
        }
        status.setComplete();
        redirectAttributes.addFlashAttribute("loginMessage", "로그아웃되었습니다.");
        return "redirect:/login";
    }
}