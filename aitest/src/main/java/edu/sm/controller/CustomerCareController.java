package edu.sm.controller;

import edu.sm.app.dto.CustomerCarePlan;
import edu.sm.app.service.CustomerCareService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/customer-care")
@RequiredArgsConstructor
public class CustomerCareController {

    private final CustomerCareService customerCareService;

    @RequestMapping("/action-plan")
    public CustomerCarePlan createActionPlan(@RequestParam("feedback") String feedback) {
        return customerCareService.handleFeedback(feedback);
    }
}