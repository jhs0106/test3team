package edu.sm.app.service;

import edu.sm.app.dto.DiaryEntry;
import edu.sm.app.repository.DiaryRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DiaryService implements SmService<DiaryEntry, Long> {

    private final DiaryRepository diaryRepository;

    @Override
    public void register(DiaryEntry diaryEntry) throws Exception {
        diaryRepository.insert(diaryEntry);
    }

    @Override
    public void modify(DiaryEntry diaryEntry) throws Exception {
        throw new UnsupportedOperationException("Diary entries cannot be modified");
    }

    @Override
    public void remove(Long diaryId) throws Exception {
        throw new UnsupportedOperationException("Diary entries cannot be removed");
    }

    @Override
    public List<DiaryEntry> get() throws Exception {
        return diaryRepository.selectAll();
    }

    @Override
    public DiaryEntry get(Long diaryId) throws Exception {
        return diaryRepository.select(diaryId);
    }
}