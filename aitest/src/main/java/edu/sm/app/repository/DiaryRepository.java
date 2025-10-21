package edu.sm.app.repository;

import edu.sm.app.dto.DiaryEntry;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Select;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Mapper
public interface DiaryRepository {

    @Insert("INSERT INTO diary_entry (title, content, ai_feedback, entry_date) " +
            "VALUES (#{title}, #{content}, #{aiFeedback}, #{entryDate})")
    @Options(useGeneratedKeys = true, keyProperty = "diaryId", keyColumn = "diary_id")
    void insert(DiaryEntry diaryEntry) throws Exception;

    @Select("SELECT diary_id, title, content, ai_feedback, entry_date, created_at " +
            "FROM diary_entry ORDER BY entry_date DESC, diary_id DESC")
    List<DiaryEntry> selectAll() throws Exception;

    @Select("SELECT diary_id, title, content, ai_feedback, entry_date, created_at " +
            "FROM diary_entry WHERE diary_id=#{diaryId}")
    DiaryEntry select(Long diaryId) throws Exception;
}