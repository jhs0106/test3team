package edu.sm.app.service;

import edu.sm.app.dto.Habit;
import edu.sm.app.dto.HabitCheckin;
import edu.sm.app.repository.HabitRepository;
import edu.sm.app.repository.HabitCheckinRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class HabitService {

    private final HabitRepository habitRepository;
    private final HabitCheckinRepository checkinRepository;

    // 습관 등록
    public Habit register(Habit habit) throws Exception {
        habitRepository.insert(habit);
        log.info("습관 등록: {}", habit.getHabitName());
        return habit;
    }

    // 전체 습관 조회
    public List<Habit> getAllHabits() throws Exception {
        List<Habit> habits = habitRepository.selectAll();

        // 각 습관의 통계 정보 추가
        for (Habit habit : habits) {
            enrichHabitWithStats(habit);
        }

        return habits;
    }

    // 습관 상세 조회
    public Habit getHabit(Integer habitId) throws Exception {
        Habit habit = habitRepository.select(habitId);
        if (habit != null) {
            enrichHabitWithStats(habit);
        }
        return habit;
    }

    // 습관 수정
    public void update(Habit habit) throws Exception {
        habitRepository.update(habit);
        log.info("습관 수정: {}", habit.getHabitName());
    }

    // 습관 삭제
    public void remove(Integer habitId) throws Exception {
        habitRepository.delete(habitId);
        log.info("습관 삭제: ID={}", habitId);
    }

    // 체크인
    public void checkin(HabitCheckin checkin) throws Exception {
        checkinRepository.insert(checkin);
        log.info("체크인 완료: 습관ID={}, 날짜={}", checkin.getHabitId(), checkin.getCheckinDate());
    }

    // 체크인 취소
    public void uncheckByDate(Integer habitId, LocalDate date) throws Exception {
        checkinRepository.deleteByHabitIdAndDate(habitId, date);
        log.info("체크인 취소: 습관ID={}, 날짜={}", habitId, date);
    }

    // 기간별 체크인 조회
    public List<HabitCheckin> getCheckinsByDateRange(LocalDate startDate, LocalDate endDate) throws Exception {
        return checkinRepository.selectByDateRange(startDate, endDate);
    }

    // 특정 습관의 체크인 기록 조회
    public List<HabitCheckin> getCheckinsByHabitId(Integer habitId) throws Exception {
        return checkinRepository.selectByHabitId(habitId);
    }

    // 특정 날짜에 체크인 여부 확인
    public boolean isCheckedOn(Integer habitId, LocalDate date) throws Exception {
        return checkinRepository.existsByHabitIdAndDate(habitId, date) > 0;
    }

    // 습관 통계 정보 추가 (연속 일수, 총 체크인 횟수 등)
    private void enrichHabitWithStats(Habit habit) throws Exception {
        List<HabitCheckin> checkins = checkinRepository.selectByHabitId(habit.getHabitId());

        // 총 체크인 횟수
        habit.setTotalCheckins(checkins.size());

        // 이번 주 체크인 횟수
        LocalDate weekStart = LocalDate.now().minusDays(LocalDate.now().getDayOfWeek().getValue() - 1);
        LocalDate weekEnd = weekStart.plusDays(6);
        long weeklyCount = checkins.stream()
                .filter(c -> !c.getCheckinDate().isBefore(weekStart) && !c.getCheckinDate().isAfter(weekEnd))
                .count();
        habit.setWeeklyCheckins((int) weeklyCount);

        // 현재 연속 일수 계산
        int streak = calculateCurrentStreak(checkins);
        habit.setCurrentStreak(streak);
    }

    // 연속 일수 계산
    private int calculateCurrentStreak(List<HabitCheckin> checkins) {
        if (checkins.isEmpty()) {
            return 0;
        }

        // 날짜순 정렬 (최신순)
        checkins.sort((a, b) -> b.getCheckinDate().compareTo(a.getCheckinDate()));

        LocalDate today = LocalDate.now();
        LocalDate yesterday = today.minusDays(1);

        // 오늘이나 어제 체크인이 없으면 연속 끊김
        if (!checkins.get(0).getCheckinDate().equals(today) &&
                !checkins.get(0).getCheckinDate().equals(yesterday)) {
            return 0;
        }

        int streak = 0;
        LocalDate expectedDate = checkins.get(0).getCheckinDate();

        for (HabitCheckin checkin : checkins) {
            if (checkin.getCheckinDate().equals(expectedDate)) {
                streak++;
                expectedDate = expectedDate.minusDays(1);
            } else {
                break;
            }
        }

        return streak;
    }
}