package edu.sm.app.service;

import edu.sm.app.dto.ChatRoomDto;
import edu.sm.app.repository.ChatRoomRepository;
import edu.sm.util.ChatLogger;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatRoomService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatLogger chatLogger;

    public List<ChatRoomDto> getWaitingRooms() {
        log.info("대기 중인 채팅방 조회");
        return chatRoomRepository.getWaitingRooms();
    }

    public List<ChatRoomDto> getAllRooms() {
        log.info("모든 채팅방 조회");
        return chatRoomRepository.getAllRooms();
    }

    public ChatRoomDto getRoomById(Integer roomId) {
        log.info("채팅방 조회: roomId={}", roomId);
        return chatRoomRepository.selectById(roomId);
    }

    @Transactional
    public boolean assignAdmin(Integer roomId, String adminId) {
        log.info("Admin 채팅방 입장: roomId={}, adminId={}", roomId, adminId);
        int result = chatRoomRepository.assignAdmin(roomId, adminId);

        // ⭐ 채팅 로그 추가
        if (result > 0) {
            chatLogger.logSystem(roomId, "ASSIGN", "상담사 배정 - " + adminId);
        }

        return result > 0;
    }

    @Transactional
    public boolean closeRoom(Integer roomId) {
        log.info("채팅방 종료: roomId={}", roomId);
        int result = chatRoomRepository.closeRoom(roomId);

        // ⭐ 채팅 로그 추가
        if (result > 0) {
            chatLogger.logSystem(roomId, "CLOSE", "채팅방 종료");
        }

        return result > 0;
    }

    @Transactional
    public boolean createRoom(String custId) {
        log.info("채팅방 생성: custId={}", custId);
        int result = chatRoomRepository.createRoom(custId);

        // ⭐ 채팅 로그 추가
        if (result > 0) {
            // roomId를 얻기 위해 방금 생성된 방 조회
            ChatRoomDto createdRoom = chatRoomRepository.getActiveByCustId(custId);
            if (createdRoom != null) {
                chatLogger.logSystem(createdRoom.getRoomId(), "CREATE", "채팅방 생성 - 고객: " + custId);
            }
        }

        return result > 0;
    }

    public ChatRoomDto getActiveByCustId(String custId) {
        log.info("고객 활성 채팅방 조회: custId={}", custId);
        return chatRoomRepository.getActiveByCustId(custId);
    }

    @Transactional
    public boolean updateLocation(Integer roomId, Double latitude, Double longitude) {
        log.info("위치 정보 업데이트: roomId={}, lat={}, lng={}", roomId, latitude, longitude);
        int result = chatRoomRepository.updateLocation(roomId, latitude, longitude);
        return result > 0;
    }
}