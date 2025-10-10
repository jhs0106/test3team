package edu.sm.controller;

// import edu.sm.app.dto.Admin; // DTO 임포트가 필요 없어집니다.
import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@Slf4j
public class LoginController {

    @RequestMapping("/login")
    public String login(HttpSession session, Model model) {
        model.addAttribute("center", "login");
        return "index";
    }

    @RequestMapping("/loginimpl")
    public String loginimpl(Model model, @RequestParam("id") String custId,
                            @RequestParam("pwd") String custPwd,
                            HttpSession httpSession) {

        if ("cust".equals(custId) && "111111".equals(custPwd)) {
            // Admin 객체 대신, 로그인 ID 문자열을 세션에 저장합니다.
            httpSession.setAttribute("cust", custId);
            return "redirect:/";
        }

        model.addAttribute("loginfail", "fail");
        model.addAttribute("msg", "로그인 실패!!!");
        return "index";
    }

    @RequestMapping("/logoutimpl")
    public String logoutimpl(HttpSession httpSession) {
        if (httpSession != null) {
            httpSession.invalidate();
        }
        return "redirect:/";
    }
}