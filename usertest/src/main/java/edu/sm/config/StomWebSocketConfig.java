package edu.sm.config;

import edu.sm.rtc.WebRTCSignalingHandler;
import edu.sm.websocket.ChatWebSocketHandler;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.*;

@EnableWebSocketMessageBroker
@EnableWebSocket
@Configuration
public class StomWebSocketConfig implements WebSocketMessageBrokerConfigurer, WebSocketConfigurer {

    private final ChatWebSocketHandler chatWebSocketHandler;

    public StomWebSocketConfig(ChatWebSocketHandler chatWebSocketHandler) {
        this.chatWebSocketHandler = chatWebSocketHandler;
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/chat").setAllowedOriginPatterns("*").withSockJS();
        registry.addEndpoint("/adminchat").setAllowedOriginPatterns("*").withSockJS();

    }
    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/send","/adminsend");
    }
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // WebRTC
        registry.addHandler(new WebRTCSignalingHandler(), "/signal")
                .setAllowedOrigins("*");

        // Chat
        registry.addHandler(chatWebSocketHandler, "/ws/chat")
                .setAllowedOriginPatterns("*");
    }

}