package edu.sm.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class ChatLogger {
    private static final Logger chatLogger = LoggerFactory.getLogger("CHAT_LOGGER");

    /**
     * 채팅 메시지 로그
     */
    public void logChat(Integer roomId, String senderId, String senderType, String message) {
        chatLogger.info("ROOM[{}] | {}({}) | {}", roomId, senderId, senderType.toUpperCase(), message);
    }

    /**
     * 시스템 이벤트 로그
     */
    public void logSystem(Integer roomId, String event, String message) {
        chatLogger.info("ROOM[{}] | SYSTEM({}) | {}", roomId, event, message);
    }

    /**
     * 상담 방식 전환 로그
     */
    public void logModeChange(Integer roomId, String fromMode, String toMode, String initiator) {
        chatLogger.info("ROOM[{}] | MODE_CHANGE | {} -> {} (by {})", roomId, fromMode, toMode, initiator);
    }
}