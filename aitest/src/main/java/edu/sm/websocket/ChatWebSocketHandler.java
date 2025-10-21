package edu.sm.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import edu.sm.app.dto.ChatMessageDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {

    // roomId -> List<WebSocketSession>
    private static final Map<Integer, Map<String, WebSocketSession>> chatRooms = new ConcurrentHashMap<>();
    private static final ObjectMapper objectMapper = new ObjectMapper().registerModule(new JavaTimeModule());

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String roomId = getRoomIdFromSession(session);
        String userId = getUserIdFromSession(session);

        log.info("WebSocket 연결 성공 - Room: {}, User: {}", roomId, userId);

        if (roomId != null) {
            int room = Integer.parseInt(roomId);
            chatRooms.computeIfAbsent(room, k -> new ConcurrentHashMap<>()).put(session.getId(), session);

            // 입장 메시지 전송
            ChatMessageDto joinMessage = ChatMessageDto.builder()
                    .roomId(room)
                    .senderId(userId)
                    .senderType(getSenderType(userId))
                    .message(userId + "님이 입장했습니다.")
                    .messageType("JOIN")
                    .timestamp(LocalDateTime.now())
                    .build();

            broadcastMessage(room, joinMessage);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        log.info("수신 메시지: {}", payload);

        try {
            ChatMessageDto chatMessage = objectMapper.readValue(payload, ChatMessageDto.class);
            chatMessage.setTimestamp(LocalDateTime.now());

            // 같은 방의 모든 사용자에게 메시지 전송
            broadcastMessage(chatMessage.getRoomId(), chatMessage);

        } catch (Exception e) {
            log.error("메시지 처리 오류: {}", e.getMessage());
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        String roomId = getRoomIdFromSession(session);
        String userId = getUserIdFromSession(session);

        log.info("WebSocket 연결 종료 - Room: {}, User: {}", roomId, userId);

        if (roomId != null) {
            int room = Integer.parseInt(roomId);
            chatRooms.getOrDefault(room, new ConcurrentHashMap<>()).remove(session.getId());

            // 퇴장 메시지 전송
            ChatMessageDto leaveMessage = ChatMessageDto.builder()
                    .roomId(room)
                    .senderId(userId)
                    .senderType(getSenderType(userId))
                    .message(userId + "님이 퇴장했습니다.")
                    .messageType("LEAVE")
                    .timestamp(LocalDateTime.now())
                    .build();

            broadcastMessage(room, leaveMessage);
        }
    }

    private void broadcastMessage(Integer roomId, ChatMessageDto message) {
        Map<String, WebSocketSession> roomSessions = chatRooms.get(roomId);
        if (roomSessions != null) {
            String messageJson;
            try {
                messageJson = objectMapper.writeValueAsString(message);
            } catch (Exception e) {
                log.error("메시지 JSON 변환 오류: {}", e.getMessage());
                return;
            }

            roomSessions.values().forEach(session -> {
                try {
                    if (session.isOpen()) {
                        session.sendMessage(new TextMessage(messageJson));
                    }
                } catch (Exception e) {
                    log.error("메시지 전송 오류: {}", e.getMessage());
                }
            });
        }
    }

    private String getRoomIdFromSession(WebSocketSession session) {
        String uri = session.getUri().toString();
        String[] params = uri.split("roomId=");
        return params.length > 1 ? params[1].split("&")[0] : null;
    }

    private String getUserIdFromSession(WebSocketSession session) {
        String uri = session.getUri().toString();
        String[] params = uri.split("userId=");
        return params.length > 1 ? params[1].split("&")[0] : "Unknown";
    }

    private String getSenderType(String userId) {
        return userId.startsWith("admin") ? "ADMIN" : "CUSTOMER";
    }
}