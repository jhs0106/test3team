package edu.sm.controller;

import edu.sm.app.msg.Msg;
import edu.sm.app.service.OperationMetricService;
import edu.sm.util.ChatLogger;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Slf4j
@Controller
@RequiredArgsConstructor
public class MsgController {

    private final SimpMessagingTemplate template;
    private final OperationMetricService operationMetricService;
    private final ChatLogger chatLogger;

    @MessageMapping("/receiveall") // 모두에게 전송
    public void receiveall(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        log.info("receiveall: {}", msg);
        template.convertAndSend("/send", msg);
        operationMetricService.recordChatMessage("broadcast");
    }

    @MessageMapping("/receiveme") // 나에게만 전송
    public void receiveme(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        log.info("receiveme: {}", msg);
        String id = msg.getSendid();
        template.convertAndSend("/send/" + id, msg);
        operationMetricService.recordChatMessage("private:" + id);
    }

    @MessageMapping("/receiveto") // 특정 ID에게 전송
    public void receiveto(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        log.info("receiveto: {}", msg);
        String target = msg.getReceiveid();

        // ⭐ 채팅 로그 저장 (User → Admin)
        if (msg.getRoomId() != null) {
            chatLogger.logChat(msg.getRoomId(), msg.getSendid(), "user", msg.getContent1());
        }

        template.convertAndSend("/send/to/" + target, msg);
        operationMetricService.recordChatMessage("direct:" + target);
    }

    @MessageMapping("/adminreceiveto") // admin → user 통신용
    public void adminreceiveto(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        log.info("adminreceiveto: {}", msg);
        String target = msg.getReceiveid();

        // ⭐ 채팅 로그 저장 (Admin → User)
        if (msg.getRoomId() != null) {
            chatLogger.logChat(msg.getRoomId(), msg.getSendid(), "admin", msg.getContent1());
        }

        template.convertAndSend("/adminsend/to/" + target, msg);
        operationMetricService.recordChatMessage("admin:" + target);
    }
}