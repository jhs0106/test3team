package edu.sm.controller;

import edu.sm.app.dto.ChatRoomDto;
import edu.sm.app.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 채팅방 API - Admin과 User 모두 사용
 */
@RestController
@RequestMapping("/api/chatroom")
@RequiredArgsConstructor
@Slf4j
public class ChatRoomApiController {

    private final ChatRoomService chatRoomService;

    // Admin용: 대기 중인 채팅방 리스트
    @GetMapping("/waiting")
    public ResponseEntity<List<ChatRoomDto>> getWaitingRooms() {
        log.info("===== API: 대기 중인 채팅방 조회 =====");
        List<ChatRoomDto> rooms = chatRoomService.getWaitingRooms();
        return ResponseEntity.ok(rooms);
    }

    // Admin용: 모든 채팅방 조회
    @GetMapping("/all")
    public ResponseEntity<List<ChatRoomDto>> getAllRooms() {
        log.info("===== API: 모든 채팅방 조회 =====");
        List<ChatRoomDto> rooms = chatRoomService.getAllRooms();
        return ResponseEntity.ok(rooms);
    }

    // 채팅방 상세 조회
    @GetMapping("/{roomId}")
    public ResponseEntity<ChatRoomDto> getRoomById(@PathVariable Integer roomId) {
        log.info("===== API: 채팅방 상세 조회, roomId={} =====", roomId);
        ChatRoomDto room = chatRoomService.getRoomById(roomId);
        return ResponseEntity.ok(room);
    }

    // Admin용: 채팅방 입장
    @PostMapping("/{roomId}/assign")
    public ResponseEntity<Map<String, Object>> assignAdmin(
            @PathVariable Integer roomId,
            @RequestParam String adminId) {
        log.info("===== API: Admin 입장, roomId={}, adminId={} =====", roomId, adminId);

        boolean success = chatRoomService.assignAdmin(roomId, adminId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", success);
        response.put("roomId", roomId);
        response.put("adminId", adminId);

        return ResponseEntity.ok(response);
    }

    // 채팅방 종료
    @PostMapping("/{roomId}/close")
    public ResponseEntity<Map<String, Object>> closeRoom(@PathVariable Integer roomId) {
        log.info("===== API: 채팅방 종료, roomId={} =====", roomId);

        boolean success = chatRoomService.closeRoom(roomId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", success);
        response.put("roomId", roomId);

        return ResponseEntity.ok(response);
    }

    // User용: 채팅방 생성
    @PostMapping("/create")
    public ResponseEntity<Map<String, Object>> createRoom(@RequestParam String custId) {
        log.info("===== API: 채팅방 생성, custId={} =====", custId);

        boolean success = chatRoomService.createRoom(custId);

        Map<String, Object> response = new HashMap<>();
        response.put("success", success);
        response.put("custId", custId);

        return ResponseEntity.ok(response);
    }

    // User용: 내 활성 채팅방 조회
    @GetMapping("/active/{custId}")
    public ResponseEntity<ChatRoomDto> getActiveByCustId(@PathVariable String custId) {
        log.info("===== API: 고객 활성 채팅방 조회, custId={} =====", custId);
        ChatRoomDto room = chatRoomService.getActiveByCustId(custId);
        return ResponseEntity.ok(room);
    }
}