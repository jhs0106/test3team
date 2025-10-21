package edu.sm.controller;

import edu.sm.app.dto.Habit;
import edu.sm.app.dto.HabitCheckin;
import edu.sm.app.service.HabitService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/habit")
@Slf4j
@RequiredArgsConstructor
public class HabitApiController {

    private final HabitService habitService;

    /**
     * 습관 등록
     */
    @PostMapping
    public ResponseEntity<Habit> createHabit(@RequestBody Habit habit) {
        try {
            log.info("습관 등록 요청: {}", habit.getHabitName());

            // 기본값 설정
            if (habit.getTargetFrequency() == null) {
                habit.setTargetFrequency(7); // 기본 주 7회
            }

            Habit created = habitService.register(habit);
            return ResponseEntity.ok(created);
        } catch (Exception e) {
            log.error("습관 등록 실패", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 전체 습관 조회
     */
    @GetMapping
    public ResponseEntity<List<Habit>> getAllHabits() {
        try {
            List<Habit> habits = habitService.getAllHabits();
            return ResponseEntity.ok(habits);
        } catch (Exception e) {
            log.error("습관 조회 실패", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 습관 상세 조회
     */
    @GetMapping("/{habitId}")
    public ResponseEntity<Habit> getHabit(@PathVariable Integer habitId) {
        try {
            Habit habit = habitService.getHabit(habitId);
            if (habit == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(habit);
        } catch (Exception e) {
            log.error("습관 조회 실패: ID={}", habitId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 습관 수정
     */
    @PutMapping("/{habitId}")
    public ResponseEntity<Map<String, String>> updateHabit(
            @PathVariable Integer habitId,
            @RequestBody Habit habit) {
        try {
            habit.setHabitId(habitId);
            habitService.update(habit);
            return ResponseEntity.ok(Map.of("status", "SUCCESS", "message", "수정 완료"));
        } catch (Exception e) {
            log.error("습관 수정 실패: ID={}", habitId, e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("status", "ERROR", "message", "수정 실패"));
        }
    }

    /**
     * 습관 삭제
     */
    @DeleteMapping("/{habitId}")
    public ResponseEntity<Map<String, String>> deleteHabit(@PathVariable Integer habitId) {
        try {
            habitService.remove(habitId);
            return ResponseEntity.ok(Map.of("status", "SUCCESS", "message", "삭제 완료"));
        } catch (Exception e) {
            log.error("습관 삭제 실패: ID={}", habitId, e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("status", "ERROR", "message", "삭제 실패"));
        }
    }

    /**
     * 체크인
     */
    @PostMapping("/checkin")
    public ResponseEntity<Map<String, Object>> checkin(@RequestBody HabitCheckin checkin) {
        try {
            log.info("체크인 요청: 습관ID={}, 날짜={}", checkin.getHabitId(), checkin.getCheckinDate());

            // 날짜 미지정 시 오늘 날짜
            if (checkin.getCheckinDate() == null) {
                checkin.setCheckinDate(LocalDate.now());
            }

            habitService.checkin(checkin);

            // 업데이트된 습관 정보 반환
            Habit habit = habitService.getHabit(checkin.getHabitId());

            Map<String, Object> response = new HashMap<>();
            response.put("status", "SUCCESS");
            response.put("message", "체크인 완료! 🎉");
            response.put("habit", habit);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("체크인 실패", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("status", "ERROR", "message", "체크인 실패"));
        }
    }

    /**
     * 체크인 취소
     */
    @DeleteMapping("/checkin")
    public ResponseEntity<Map<String, Object>> uncheckByDate(
            @RequestParam Integer habitId,
            @RequestParam String date) {
        try {
            LocalDate checkinDate = LocalDate.parse(date);
            habitService.uncheckByDate(habitId, checkinDate);

            // 업데이트된 습관 정보 반환
            Habit habit = habitService.getHabit(habitId);

            Map<String, Object> response = new HashMap<>();
            response.put("status", "SUCCESS");
            response.put("message", "체크인 취소");
            response.put("habit", habit);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("체크인 취소 실패", e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("status", "ERROR", "message", "취소 실패"));
        }
    }

    /**
     * 기간별 체크인 조회 (캘린더용)
     */
    @GetMapping("/checkins")
    public ResponseEntity<List<HabitCheckin>> getCheckins(
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            LocalDate start = LocalDate.parse(startDate);
            LocalDate end = LocalDate.parse(endDate);

            List<HabitCheckin> checkins = habitService.getCheckinsByDateRange(start, end);
            return ResponseEntity.ok(checkins);
        } catch (Exception e) {
            log.error("체크인 조회 실패", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 특정 날짜 체크인 여부 확인
     */
    @GetMapping("/check")
    public ResponseEntity<Map<String, Boolean>> isChecked(
            @RequestParam Integer habitId,
            @RequestParam String date) {
        try {
            LocalDate checkinDate = LocalDate.parse(date);
            boolean checked = habitService.isCheckedOn(habitId, checkinDate);
            return ResponseEntity.ok(Map.of("checked", checked));
        } catch (Exception e) {
            log.error("체크인 여부 확인 실패", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}