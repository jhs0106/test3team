package edu.sm.controller;

import edu.sm.app.springai.service1.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RestController
@RequestMapping("/ai1")
@Slf4j
@RequiredArgsConstructor
public class Ai1Controller {
    final AiServiceByChatClient aiServiceByChatClient;
    final AiServiceChainOfThoughtPrompt aiServiceChainOfThoughtPrompt;
    final AiServiceFewShotPrompt aiServiceFewShotPrompt;
    final AiServiceFewShotPrompt2 aiServiceFewShotPrompt2;
    final AiServicePromptTemplate  aiServicePromptTemplate;
    final AiServiceStepBackPrompt aiServiceStepBackPrompt;

    @RequestMapping ("/few-shot-prompt")
    public String fewShotPrompt(@RequestParam("question") String question) {
        return aiServiceFewShotPrompt.fewShotPrompt(question);
    }

    @RequestMapping ("/few-shot-prompt2")
    public String fewShotPrompt2(@RequestParam("question") String question) {
        return aiServiceFewShotPrompt2.fewShotPrompt2(question);
    }

    @RequestMapping ("/chat-model")
    public String chatModel(@RequestParam("question") String question) {
        return aiServiceByChatClient.generateText(question);
    }

    @RequestMapping ("/chat-model-stream")
    public Flux<String> chatModelStream(@RequestParam("question") String question) {
        return aiServiceByChatClient.generateStreamText(question);
    }

    @RequestMapping ("/chat-of-thought")
    public Flux<String> chatOfThought(@RequestParam("question") String question) {
        return aiServiceChainOfThoughtPrompt.chainOfThought(question);
    }

    @RequestMapping ("/prompt-template")
    public Flux<String> promptTemplate(@RequestParam("question") String question,
                                       @RequestParam("language") String language) {
        return aiServicePromptTemplate.promptTemplate3(question, language);
    }

    @RequestMapping("role-assignment")
    public Flux<String> roleAssignment(@RequestParam("requirements") String requirements){
        return aiServicePromptTemplate.roleAssignment(requirements);
    }

    @RequestMapping(value = "/step-back-prompt")
    public String stepBackPrompt(@RequestParam("question") String question) throws Exception {
        String answer = aiServiceStepBackPrompt.stepBackPrompt(question);
        return answer;
    }
}
