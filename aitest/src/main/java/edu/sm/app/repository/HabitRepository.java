package edu.sm.app.repository;

import edu.sm.app.dto.Habit;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
@Mapper
public interface HabitRepository {

    @Insert("INSERT INTO habit (habit_name, description, category, icon, target_frequency) " +
            "VALUES (#{habitName}, #{description}, #{category}, #{icon}, #{targetFrequency})")
    @Options(useGeneratedKeys = true, keyProperty = "habitId", keyColumn = "habit_id")
    void insert(Habit habit) throws Exception;

    @Select("SELECT habit_id as habitId, habit_name as habitName, description, category, " +
            "icon, target_frequency as targetFrequency, created_at as createdAt " +
            "FROM habit ORDER BY created_at DESC")
    List<Habit> selectAll() throws Exception;

    @Select("SELECT habit_id as habitId, habit_name as habitName, description, category, " +
            "icon, target_frequency as targetFrequency, created_at as createdAt " +
            "FROM habit WHERE habit_id = #{habitId}")
    Habit select(Integer habitId) throws Exception;

    @Update("UPDATE habit SET habit_name = #{habitName}, description = #{description}, " +
            "category = #{category}, icon = #{icon}, target_frequency = #{targetFrequency} " +
            "WHERE habit_id = #{habitId}")
    void update(Habit habit) throws Exception;

    @Delete("DELETE FROM habit WHERE habit_id = #{habitId}")
    void delete(Integer habitId) throws Exception;
}