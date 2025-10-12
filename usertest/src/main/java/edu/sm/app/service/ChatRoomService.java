package edu.sm.app.service;

import edu.sm.app.dto.ChatRoomDto;
import edu.sm.app.repository.ChatRoomRepository;
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
        return result > 0;
    }

    @Transactional
    public boolean closeRoom(Integer roomId) {
        log.info("채팅방 종료: roomId={}", roomId);
        int result = chatRoomRepository.closeRoom(roomId);
        return result > 0;
    }

    @Transactional
    public boolean createRoom(String custId) {
        log.info("채팅방 생성: custId={}", custId);
        int result = chatRoomRepository.createRoom(custId);
        return result > 0;
    }

    public ChatRoomDto getActiveByCustId(String custId) {
        log.info("고객 활성 채팅방 조회: custId={}", custId);
        return chatRoomRepository.getActiveByCustId(custId);
    }
}