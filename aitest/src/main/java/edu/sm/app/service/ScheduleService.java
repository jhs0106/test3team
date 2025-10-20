package edu.sm.app.service;

import edu.sm.app.dto.Schedule;
import edu.sm.app.repository.ScheduleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;

    public void register(Schedule schedule) throws Exception {
        scheduleRepository.insert(schedule);
    }

    public void remove(Integer scheduleId) throws Exception {
        scheduleRepository.delete(scheduleId);
    }

    public List<Schedule> get() throws Exception {
        return scheduleRepository.selectAll();
    }

    public List<Schedule> getSchedulesByDateRange(LocalDateTime startDate, LocalDateTime endDate) throws Exception {
        return scheduleRepository.selectByDateRange(startDate, endDate);
    }
}