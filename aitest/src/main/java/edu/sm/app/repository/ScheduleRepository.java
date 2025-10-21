package edu.sm.app.repository;

import edu.sm.app.dto.Schedule;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
@Mapper
public interface ScheduleRepository {

    @Insert("INSERT INTO schedule (title, description, start_datetime, end_datetime, location, category) " +
            "VALUES (#{title}, #{description}, #{startDatetime}, #{endDatetime}, #{location}, #{category})")
    void insert(Schedule schedule) throws Exception;

    @Select("SELECT schedule_id as scheduleId, title, description, " +
            "start_datetime as startDatetime, end_datetime as endDatetime, " +
            "location, category, created_at as createdAt " +
            "FROM schedule WHERE start_datetime >= #{startDate} AND end_datetime <= #{endDate} " +
            "ORDER BY start_datetime")
    List<Schedule> selectByDateRange(@Param("startDate") LocalDateTime startDate,
                                     @Param("endDate") LocalDateTime endDate) throws Exception;

    @Select("SELECT schedule_id as scheduleId, title, description, " +
            "start_datetime as startDatetime, end_datetime as endDatetime, " +
            "location, category, created_at as createdAt " +
            "FROM schedule ORDER BY start_datetime")
    List<Schedule> selectAll() throws Exception;

    @Delete("DELETE FROM schedule WHERE schedule_id = #{scheduleId}")
    void delete(Integer scheduleId) throws Exception;
}