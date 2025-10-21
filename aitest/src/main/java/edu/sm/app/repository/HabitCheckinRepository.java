package edu.sm.app.repository;

import edu.sm.app.dto.HabitCheckin;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
@Mapper
public interface HabitCheckinRepository {

    @Insert("INSERT INTO habit_checkin (habit_id, checkin_date, memo) " +
            "VALUES (#{habitId}, #{checkinDate}, #{memo}) " +
            "ON CONFLICT (habit_id, checkin_date) DO NOTHING")
    void insert(HabitCheckin checkin) throws Exception;

    @Select("SELECT hc.checkin_id as checkinId, hc.habit_id as habitId, " +
            "hc.checkin_date as checkinDate, hc.memo, hc.created_at as createdAt, " +
            "h.habit_name as habitName, h.icon " +
            "FROM habit_checkin hc " +
            "JOIN habit h ON hc.habit_id = h.habit_id " +
            "WHERE hc.habit_id = #{habitId} " +
            "ORDER BY hc.checkin_date DESC")
    List<HabitCheckin> selectByHabitId(Integer habitId) throws Exception;

    @Select("SELECT hc.checkin_id as checkinId, hc.habit_id as habitId, " +
            "hc.checkin_date as checkinDate, hc.memo, hc.created_at as createdAt, " +
            "h.habit_name as habitName, h.icon " +
            "FROM habit_checkin hc " +
            "JOIN habit h ON hc.habit_id = h.habit_id " +
            "WHERE hc.checkin_date BETWEEN #{startDate} AND #{endDate} " +
            "ORDER BY hc.checkin_date DESC, hc.habit_id")
    List<HabitCheckin> selectByDateRange(@Param("startDate") LocalDate startDate,
                                         @Param("endDate") LocalDate endDate) throws Exception;

    @Select("SELECT COUNT(*) FROM habit_checkin " +
            "WHERE habit_id = #{habitId} AND checkin_date = #{date}")
    int existsByHabitIdAndDate(@Param("habitId") Integer habitId,
                               @Param("date") LocalDate date) throws Exception;

    @Delete("DELETE FROM habit_checkin WHERE checkin_id = #{checkinId}")
    void delete(Integer checkinId) throws Exception;

    @Delete("DELETE FROM habit_checkin WHERE habit_id = #{habitId} AND checkin_date = #{date}")
    void deleteByHabitIdAndDate(@Param("habitId") Integer habitId,
                                @Param("date") LocalDate date) throws Exception;
}