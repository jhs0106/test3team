package edu.sm.app.repository;

import edu.sm.app.dto.ChatRoomDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface ChatRoomRepository {
    List<ChatRoomDto> getWaitingRooms();
    int assignAdmin(@Param("roomId") Integer roomId, @Param("adminId") String adminId);
    int closeRoom(@Param("roomId") Integer roomId);
    int createRoom(@Param("custId") String custId);
    ChatRoomDto getActiveByCustId(@Param("custId") String custId);
    List<ChatRoomDto> getAllRooms();
    ChatRoomDto selectById(@Param("roomId") Integer roomId);
}