package edu.sm.app.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class DiaryAiService {

    private final ChatModel chatModel;

    public String generateFeedback(String diaryContent) {
        try {
            SystemMessage systemMessage = SystemMessage.builder()
                    .text("너는 섬세한 상담 코치야. 사용자의 일기 내용을 읽고 공감 어린 피드백과 실천 가능한 간단한 조언을 3문장 이내로 한국어로 작성해.")
                    .build();
            UserMessage userMessage = UserMessage.builder()
                    .text("일기 내용: " + diaryContent)
                    .build();
            ChatOptions options = ChatOptions.builder().build();
            Prompt prompt = Prompt.builder()
                    .messages(systemMessage, userMessage)
                    .chatOptions(options)
                    .build();

            ChatResponse response = chatModel.call(prompt);
            AssistantMessage assistantMessage = response.getResult().getOutput();
            String text = assistantMessage.getText();
            if (text == null) {
                log.warn("AI 피드백이 비어있습니다. 기본 메시지를 사용합니다.");
                return defaultFeedback();
            }
            return text.trim();
        } catch (Exception e) {
            log.error("AI 피드백 생성 실패", e);
            return defaultFeedback();
        }
    }

    private String defaultFeedback() {
        return "오늘의 감정을 잘 기록하셨어요. 스스로를 격려하며 작은 휴식을 가져보세요.";
    }
}