package edu.sm.controller;

import edu.sm.app.msg.Msg;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Slf4j
@Controller
public class MsgController {

    @Autowired
    SimpMessagingTemplate template;

    @MessageMapping("/receiveall") // 모두에게 전송
    public void receiveall(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        log.info("receiveall: {}", msg);
        template.convertAndSend("/send", msg);
    }

    @MessageMapping("/receiveme") // 나에게만 전송
    public void receiveme(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        log.info("receiveme: {}", msg);
        String id = msg.getSendid();
        template.convertAndSend("/send/" + id, msg);
    }

    @MessageMapping("/receiveto") // 특정 ID에게 전송
    public void receiveto(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        log.info("receiveto: {}", msg);
        String target = msg.getReceiveid();
        template.convertAndSend("/send/to/" + target, msg);
    }

    @MessageMapping("/adminreceiveto") // admin → user 통신용
    public void adminreceiveto(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        log.info("adminreceiveto: {}", msg);
        String target = msg.getReceiveid();
        template.convertAndSend("/adminsend/to/" + target, msg);
    }
}
