package edu.sm.app.service;

import edu.sm.app.dto.Habit;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class HabitCoachService {

    private final ChatClient.Builder chatClientBuilder;
    private final HabitService habitService;

    /**
     * 주간 습관 분석 리포트 생성
     */
    public Map<String, Object> generateWeeklyReport() throws Exception {
        List<Habit> habits = habitService.getAllHabits();

        if (habits.isEmpty()) {
            return Map.of(
                    "status", "NO_HABITS",
                    "message", "아직 등록된 습관이 없습니다. 새로운 습관을 만들어보세요! 💪"
            );
        }

        // 습관 데이터 요약
        StringBuilder habitSummary = new StringBuilder();
        habitSummary.append("### 이번 주 습관 현황\n\n");

        int totalHabits = habits.size();
        int achievedCount = 0;
        int atRiskCount = 0;

        for (Habit habit : habits) {
            habitSummary.append(String.format("- %s %s: %d/%d 달성 (연속 %d일)\n",
                    habit.getIcon(), habit.getHabitName(),
                    habit.getWeeklyCheckins(), habit.getTargetFrequency(),
                    habit.getCurrentStreak()));

            // 목표 달성 여부
            if (habit.getWeeklyCheckins() >= habit.getTargetFrequency()) {
                achievedCount++;
            }

            // 포기 위험 (연속 0일 + 이번 주 0회)
            if (habit.getCurrentStreak() == 0 && habit.getWeeklyCheckins() == 0) {
                atRiskCount++;
            }
        }

        // AI에게 분석 요청
        String systemPrompt = """
            당신은 '사람다움 케어'의 습관 코치입니다.
            사용자의 습관 데이터를 분석하여 따뜻하고 구체적인 피드백을 제공하세요.
            
            응답 형식:
            1. 전체 평가 (2-3문장, 긍정적으로 시작)
            2. 잘하고 있는 습관 칭찬 (구체적으로)
            3. 개선이 필요한 습관 조언 (실천 가능한 방법 제시)
            4. 다음 주 목표 제안 (1-2가지)
            
            톤: 공감적, 격려, 구체적, 따뜻함
            """;

        String userMessage = String.format("""
            %s
            
            통계:
            - 전체 습관: %d개
            - 목표 달성: %d개
            - 포기 위험: %d개
            
            이 데이터를 바탕으로 따뜻하고 구체적인 주간 리포트를 작성해주세요.
            """, habitSummary.toString(), totalHabits, achievedCount, atRiskCount);

        try {
            ChatClient chatClient = chatClientBuilder.build();

            String aiResponse = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userMessage)
                    .call()
                    .content();

            Map<String, Object> result = new HashMap<>();
            result.put("status", "SUCCESS");
            result.put("report", aiResponse);
            result.put("stats", Map.of(
                    "totalHabits", totalHabits,
                    "achievedCount", achievedCount,
                    "atRiskCount", atRiskCount,
                    "achievementRate", totalHabits > 0 ? (achievedCount * 100 / totalHabits) : 0
            ));

            return result;

        } catch (Exception e) {
            log.error("AI 리포트 생성 실패", e);
            return Map.of(
                    "status", "ERROR",
                    "message", "AI 분석을 생성하는 중 오류가 발생했습니다."
            );
        }
    }

    /**
     * 개별 습관에 대한 조언 생성
     */
    public Map<String, Object> getHabitAdvice(Integer habitId) throws Exception {
        Habit habit = habitService.getHabit(habitId);

        if (habit == null) {
            return Map.of(
                    "status", "NOT_FOUND",
                    "message", "습관을 찾을 수 없습니다."
            );
        }

        String systemPrompt = """
            당신은 습관 형성 전문 코치입니다.
            사용자의 특정 습관 데이터를 분석하여 개인화된 조언을 제공하세요.
            
            응답 형식:
            1. 현재 상태 평가 (1-2문장)
            2. 구체적 조언 (실천 가능한 3가지 방법)
            3. 격려 메시지
            
            톤: 친근하고 따뜻하며 실용적
            길이: 150자 이내로 간결하게
            """;

        String userMessage = String.format("""
            습관: %s %s
            카테고리: %s
            주간 목표: %d회
            이번 주 달성: %d회
            총 체크인: %d회
            현재 연속: %d일
            
            이 습관에 대한 맞춤형 조언을 해주세요.
            """,
                habit.getIcon(), habit.getHabitName(),
                habit.getCategory(),
                habit.getTargetFrequency(),
                habit.getWeeklyCheckins(),
                habit.getTotalCheckins(),
                habit.getCurrentStreak());

        try {
            ChatClient chatClient = chatClientBuilder.build();

            String aiAdvice = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userMessage)
                    .call()
                    .content();

            return Map.of(
                    "status", "SUCCESS",
                    "habitName", habit.getHabitName(),
                    "advice", aiAdvice
            );

        } catch (Exception e) {
            log.error("AI 조언 생성 실패", e);
            return Map.of(
                    "status", "ERROR",
                    "message", "조언을 생성하는 중 오류가 발생했습니다."
            );
        }
    }

    /**
     * 포기 위험 습관 감지 및 격려
     */
    public Map<String, Object> detectAtRiskHabits() throws Exception {
        List<Habit> habits = habitService.getAllHabits();

        List<Habit> atRiskHabits = habits.stream()
                .filter(h -> h.getCurrentStreak() == 0 && h.getWeeklyCheckins() == 0)
                .toList();

        if (atRiskHabits.isEmpty()) {
            return Map.of(
                    "status", "ALL_GOOD",
                    "message", "모든 습관이 잘 유지되고 있습니다! 👍"
            );
        }

        StringBuilder habitList = new StringBuilder();
        for (Habit habit : atRiskHabits) {
            habitList.append(String.format("- %s %s\n", habit.getIcon(), habit.getHabitName()));
        }

        String systemPrompt = """
            당신은 공감 능력이 뛰어난 습관 코치입니다.
            사용자가 포기 위험에 처한 습관들에 대해 따뜻하게 격려하고, 
            다시 시작할 수 있는 구체적이고 작은 방법을 제안하세요.
            
            톤: 이해하고, 격려하고, 부담 없는
            """;

        String userMessage = String.format("""
            최근 하지 못한 습관들:
            %s
            
            이 습관들을 다시 시작할 수 있도록 따뜻한 격려와 
            아주 작은 실천 방법을 제안해주세요. (각 습관별로)
            """, habitList.toString());

        try {
            ChatClient chatClient = chatClientBuilder.build();

            String encouragement = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userMessage)
                    .call()
                    .content();

            return Map.of(
                    "status", "AT_RISK",
                    "count", atRiskHabits.size(),
                    "habits", atRiskHabits.stream().map(Habit::getHabitName).toList(),
                    "encouragement", encouragement
            );

        } catch (Exception e) {
            log.error("격려 메시지 생성 실패", e);
            return Map.of(
                    "status", "ERROR",
                    "message", "메시지를 생성하는 중 오류가 발생했습니다."
            );
        }
    }
}