<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .habit-tracker {
        padding: 20px;
    }
    .habit-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
    }
    .habit-card {
        background: white;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        transition: all 0.3s;
    }
    .habit-card:hover {
        box-shadow: 0 4px 16px rgba(0,0,0,0.15);
        transform: translateY(-2px);
    }
    .habit-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
    }
    .habit-icon {
        font-size: 2rem;
        margin-right: 15px;
    }
    .habit-title {
        display: flex;
        align-items: center;
        flex: 1;
    }
    .habit-name {
        font-size: 1.3rem;
        font-weight: 600;
        margin: 0;
    }
    .habit-category {
        display: inline-block;
        padding: 4px 12px;
        background: #f0f0f0;
        border-radius: 12px;
        font-size: 0.85rem;
        margin-left: 10px;
        color: #666;
    }
    .habit-stats {
        display: flex;
        gap: 20px;
        margin-top: 15px;
    }
    .stat-item {
        text-align: center;
    }
    .stat-value {
        font-size: 1.8rem;
        font-weight: bold;
        color: #667eea;
    }
    .stat-label {
        font-size: 0.85rem;
        color: #888;
        margin-top: 5px;
    }
    .checkin-button {
        padding: 10px 24px;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
    }
    .checkin-button.active {
        background: #667eea;
        color: white;
    }
    .checkin-button.inactive {
        background: #f0f0f0;
        color: #888;
    }
    .checkin-button:hover {
        transform: scale(1.05);
    }
    .habit-actions {
        display: flex;
        gap: 10px;
    }
    .action-btn {
        padding: 6px 12px;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-size: 0.85rem;
        transition: all 0.2s;
    }
    .action-btn:hover {
        opacity: 0.8;
    }
    .edit-btn {
        background: #f6c23e;
        color: white;
    }
    .delete-btn {
        background: #e74a3b;
        color: white;
    }
    .add-habit-form {
        background: white;
        border-radius: 12px;
        padding: 25px;
        margin-bottom: 30px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .form-row {
        display: flex;
        gap: 15px;
        margin-bottom: 15px;
    }
    .form-group {
        flex: 1;
    }
    .form-group label {
        display: block;
        margin-bottom: 8px;
        font-weight: 600;
        color: #333;
    }
    .form-group input,
    .form-group select,
    .form-group textarea {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 6px;
        font-size: 1rem;
    }
    .form-group textarea {
        resize: vertical;
        min-height: 80px;
    }
    .submit-btn {
        background: #1cc88a;
        color: white;
        padding: 12px 30px;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        font-size: 1rem;
        transition: all 0.3s;
    }
    .submit-btn:hover {
        background: #17a673;
        transform: translateY(-2px);
    }
    .empty-state {
        text-align: center;
        padding: 60px 20px;
        color: #999;
    }
    .empty-state-icon {
        font-size: 4rem;
        margin-bottom: 20px;
    }
    .progress-bar-container {
        width: 100%;
        height: 8px;
        background: #f0f0f0;
        border-radius: 4px;
        margin-top: 10px;
        overflow: hidden;
    }
    .progress-bar {
        height: 100%;
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
        border-radius: 4px;
        transition: width 0.3s;
    }
    .streak-badge {
        display: inline-block;
        padding: 4px 10px;
        background: linear-gradient(135deg, #f6d365 0%, #fda085 100%);
        color: white;
        border-radius: 12px;
        font-weight: 600;
        font-size: 0.9rem;
        margin-left: 10px;
    }
</style>

<script>
    const habitTracker = {
        habits: [],

        init: function() {
            this.loadHabits();
            this.setupEventListeners();
        },

        setupEventListeners: function() {
            var self = this;
            $('#habitForm').on('submit', function(e) {
                e.preventDefault();
                self.createHabit();
            });
        },

        toggleForm: function() {
            $('#add-habit-form').slideToggle(300);
        },

        loadHabits: async function() {
            try {
                const response = await fetch('/api/habit');
                if (!response.ok) throw new Error('습관 조회 실패');

                this.habits = await response.json();
                this.renderHabits();
            } catch (error) {
                console.error('습관 조회 오류:', error);
                alert('습관을 불러오는데 실패했습니다.');
            }
        },

        renderHabits: function() {
            const container = $('#habit-list');

            if (this.habits.length === 0) {
                container.html(
                        '<div class="empty-state">' +
                        '<div class="empty-state-icon">📋</div>' +
                        '<h4>아직 등록된 습관이 없습니다</h4>' +
                        '<p>위의 "새 습관 추가" 버튼을 눌러 시작해보세요!</p>' +
                        '</div>'
                );
                return;
            }

            let html = '';
            this.habits.forEach(habit => {
                const isCheckedToday = this.isCheckedToday(habit);
                const progressPercent = (habit.weeklyCheckins / habit.targetFrequency) * 100;

                let streakBadge = '';
                if (habit.currentStreak > 0) {
                    streakBadge = '<span class="streak-badge">🔥 ' + habit.currentStreak + '일 연속</span>';
                }

                let descriptionHtml = '';
                if (habit.description) {
                    descriptionHtml = '<p style="color: #666; margin-bottom: 15px;">' + habit.description + '</p>';
                }

                html += '<div class="habit-card" data-habit-id="' + habit.habitId + '">' +
                        '<div class="habit-card-header">' +
                        '<div class="habit-title">' +
                        '<span class="habit-icon">' + habit.icon + '</span>' +
                        '<div>' +
                        '<h3 class="habit-name">' +
                        habit.habitName +
                        streakBadge +
                        '</h3>' +
                        '<span class="habit-category">' + habit.category + '</span>' +
                        '</div>' +
                        '</div>' +
                        '<div class="habit-actions">' +
                        '<button class="checkin-button ' + (isCheckedToday ? 'active' : 'inactive') + '" ' +
                        'onclick="habitTracker.toggleCheckin(' + habit.habitId + ', ' + isCheckedToday + ')">' +
                        (isCheckedToday ? '✓ 완료' : '체크인') +
                        '</button>' +
                        '<button class="action-btn edit-btn" onclick="habitTracker.getAdvice(' + habit.habitId + ')">' +
                        'AI 조언' +
                        '</button>' +
                        '<button class="action-btn delete-btn" onclick="habitTracker.deleteHabit(' + habit.habitId + ')">' +
                        '삭제' +
                        '</button>' +
                        '</div>' +
                        '</div>' +
                        descriptionHtml +
                        '<div class="habit-stats">' +
                        '<div class="stat-item">' +
                        '<div class="stat-value">' + habit.weeklyCheckins + '/' + habit.targetFrequency + '</div>' +
                        '<div class="stat-label">이번 주</div>' +
                        '</div>' +
                        '<div class="stat-item">' +
                        '<div class="stat-value">' + habit.totalCheckins + '</div>' +
                        '<div class="stat-label">총 체크인</div>' +
                        '</div>' +
                        '<div class="stat-item">' +
                        '<div class="stat-value">' + habit.currentStreak + '</div>' +
                        '<div class="stat-label">연속 일수</div>' +
                        '</div>' +
                        '</div>' +
                        '<div class="progress-bar-container">' +
                        '<div class="progress-bar" style="width: ' + Math.min(progressPercent, 100) + '%"></div>' +
                        '</div>' +
                        '</div>';
            });

            container.html(html);
        },

        createHabit: async function() {
            const formData = {
                habitName: $('#habitName').val(),
                description: $('#description').val(),
                category: $('#category').val(),
                icon: $('#icon').val(),
                targetFrequency: parseInt($('#targetFrequency').val())
            };

            try {
                const response = await fetch('/api/habit', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(formData)
                });

                if (!response.ok) throw new Error('습관 등록 실패');

                alert('🎉 새로운 습관이 등록되었습니다!');
                $('#habitForm')[0].reset();
                this.toggleForm();
                this.loadHabits();
            } catch (error) {
                console.error('습관 등록 오류:', error);
                alert('습관 등록에 실패했습니다.');
            }
        },

        toggleCheckin: async function(habitId, isChecked) {
            const today = new Date().toISOString().split('T')[0];

            try {
                if (isChecked) {
                    const response = await fetch('/api/habit/checkin?habitId=' + habitId + '&date=' + today, {
                        method: 'DELETE'
                    });

                    if (!response.ok) throw new Error('체크인 취소 실패');

                } else {
                    const response = await fetch('/api/habit/checkin', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            habitId: habitId,
                            checkinDate: today
                        })
                    });

                    if (!response.ok) throw new Error('체크인 실패');

                    const result = await response.json();
                    if (result.habit.currentStreak > 0 && result.habit.currentStreak % 7 === 0) {
                        alert('🎉 ' + result.habit.currentStreak + '일 연속 달성! 대단해요!');
                    }
                }

                this.loadHabits();
            } catch (error) {
                console.error('체크인 오류:', error);
                alert('체크인 처리에 실패했습니다.');
            }
        },

        deleteHabit: async function(habitId) {
            if (!confirm('정말 이 습관을 삭제하시겠습니까?\n모든 체크인 기록도 함께 삭제됩니다.')) {
                return;
            }

            try {
                const response = await fetch('/api/habit/' + habitId, {
                    method: 'DELETE'
                });

                if (!response.ok) throw new Error('삭제 실패');

                alert('습관이 삭제되었습니다.');
                this.loadHabits();
            } catch (error) {
                console.error('삭제 오류:', error);
                alert('삭제에 실패했습니다.');
            }
        },

        isCheckedToday: function(habit) {
            return false;
        },

        // ===== AI 코치 기능 =====

        showWeeklyReport: async function() {
            this.openModal();

            try {
                const response = await fetch('/api/habit/coach/weekly-report');
                if (!response.ok) throw new Error('리포트 조회 실패');

                const data = await response.json();

                if (data.status === 'NO_HABITS') {
                    $('#modal-content').html(
                            '<div style="text-align: center; padding: 40px;">' +
                            '<h4>📋 등록된 습관이 없습니다</h4>' +
                            '<p>' + data.message + '</p>' +
                            '</div>'
                    );
                    return;
                }

                if (data.status === 'SUCCESS') {
                    const stats = data.stats;
                    const report = data.report.replace(/\n/g, '<br>');

                    $('#modal-content').html(
                            '<h3 style="margin-bottom: 20px;">📊 이번 주 습관 분석 리포트</h3>' +
                            '<div style="display: flex; gap: 20px; margin-bottom: 30px;">' +
                            '<div style="flex: 1; text-align: center; padding: 20px; background: #f8f9fa; border-radius: 8px;">' +
                            '<div style="font-size: 2rem; font-weight: bold; color: #667eea;">' + stats.totalHabits + '</div>' +
                            '<div style="color: #666; margin-top: 5px;">전체 습관</div>' +
                            '</div>' +
                            '<div style="flex: 1; text-align: center; padding: 20px; background: #f8f9fa; border-radius: 8px;">' +
                            '<div style="font-size: 2rem; font-weight: bold; color: #1cc88a;">' + stats.achievedCount + '</div>' +
                            '<div style="color: #666; margin-top: 5px;">목표 달성</div>' +
                            '</div>' +
                            '<div style="flex: 1; text-align: center; padding: 20px; background: #f8f9fa; border-radius: 8px;">' +
                            '<div style="font-size: 2rem; font-weight: bold; color: #f6c23e;">' + stats.atRiskCount + '</div>' +
                            '<div style="color: #666; margin-top: 5px;">주의 필요</div>' +
                            '</div>' +
                            '<div style="flex: 1; text-align: center; padding: 20px; background: #f8f9fa; border-radius: 8px;">' +
                            '<div style="font-size: 2rem; font-weight: bold; color: #36b9cc;">' + stats.achievementRate + '%</div>' +
                            '<div style="color: #666; margin-top: 5px;">달성률</div>' +
                            '</div>' +
                            '</div>' +
                            '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px; line-height: 1.8;">' +
                            '<h5 style="margin-bottom: 15px;">🤖 AI 코치의 분석</h5>' +
                            '<div>' + report + '</div>' +
                            '</div>'
                    );
                }
            } catch (error) {
                console.error('주간 리포트 오류:', error);
                $('#modal-content').html(
                        '<div style="text-align: center; padding: 40px; color: #e74a3b;">' +
                        '<h4>❌ 오류 발생</h4>' +
                        '<p>리포트를 불러올 수 없습니다.</p>' +
                        '</div>'
                );
            }
        },

        getAdvice: async function(habitId) {
            this.openModal();

            try {
                const response = await fetch('/api/habit/coach/advice/' + habitId);
                if (!response.ok) throw new Error('조언 조회 실패');

                const data = await response.json();

                if (data.status === 'SUCCESS') {
                    const advice = data.advice.replace(/\n/g, '<br>');

                    $('#modal-content').html(
                            '<h3 style="margin-bottom: 20px;">💡 ' + data.habitName + ' 조언</h3>' +
                            '<div style="background: #f8f9fa; padding: 25px; border-radius: 8px; line-height: 1.8; font-size: 1.05rem;">' +
                            advice +
                            '</div>' +
                            '<div style="margin-top: 20px; text-align: center;">' +
                            '<button class="btn btn-primary" onclick="habitTracker.closeModal()">확인</button>' +
                            '</div>'
                    );
                }
            } catch (error) {
                console.error('조언 조회 오류:', error);
                $('#modal-content').html(
                        '<div style="text-align: center; padding: 40px; color: #e74a3b;">' +
                        '<h4>❌ 오류 발생</h4>' +
                        '<p>조언을 불러올 수 없습니다.</p>' +
                        '</div>'
                );
            }
        },

        checkAtRisk: async function() {
            this.openModal();

            try {
                const response = await fetch('/api/habit/coach/at-risk');
                if (!response.ok) throw new Error('조회 실패');

                const data = await response.json();

                if (data.status === 'ALL_GOOD') {
                    $('#modal-content').html(
                            '<div style="text-align: center; padding: 40px;">' +
                            '<div style="font-size: 4rem; margin-bottom: 20px;">✅</div>' +
                            '<h4>' + data.message + '</h4>' +
                            '</div>'
                    );
                } else if (data.status === 'AT_RISK') {
                    const encouragement = data.encouragement.replace(/\n/g, '<br>');

                    $('#modal-content').html(
                            '<h3 style="margin-bottom: 20px;">⚠️ 다시 시작해볼까요?</h3>' +
                            '<div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px;">' +
                            '<strong>주의가 필요한 습관 (' + data.count + '개):</strong><br>' +
                            data.habits.join(', ') +
                            '</div>' +
                            '<div style="background: #f8f9fa; padding: 25px; border-radius: 8px; line-height: 1.8;">' +
                            '<h5 style="margin-bottom: 15px;">🤖 AI 코치의 격려</h5>' +
                            '<div>' + encouragement + '</div>' +
                            '</div>'
                    );
                }
            } catch (error) {
                console.error('포기 위험 체크 오류:', error);
                $('#modal-content').html(
                        '<div style="text-align: center; padding: 40px; color: #e74a3b;">' +
                        '<h4>❌ 오류 발생</h4>' +
                        '<p>데이터를 불러올 수 없습니다.</p>' +
                        '</div>'
                );
            }
        },

        openModal: function() {
            $('#ai-report-modal').fadeIn(200);
            $('#modal-content').html(
                    '<div style="text-align: center; padding: 40px;">' +
                    '<div class="spinner-border text-primary" role="status">' +
                    '<span class="sr-only">Loading...</span>' +
                    '</div>' +
                    '<p style="margin-top: 20px;">AI가 분석 중입니다...</p>' +
                    '</div>'
            );
        },

        closeModal: function() {
            $('#ai-report-modal').fadeOut(200);
        }
    };

    $(document).ready(function() {
        habitTracker.init();
    });
</script>

<div class="col-sm-10">
    <div class="habit-tracker">
        <div class="habit-header">
            <div>
                <h2>습관 관리</h2>
                <p class="text-muted">꾸준함이 당신을 변화시킵니다</p>
            </div>
            <div style="display: flex; gap: 10px;">
                <button class="btn btn-info" onclick="habitTracker.showWeeklyReport()">
                    <i class="fas fa-chart-line"></i> AI 주간 분석
                </button>
                <button class="btn btn-warning" onclick="habitTracker.checkAtRisk()">
                    <i class="fas fa-exclamation-triangle"></i> 포기 위험 체크
                </button>
                <button class="btn btn-primary" onclick="habitTracker.toggleForm()">
                    <i class="fas fa-plus"></i> 새 습관 추가
                </button>
            </div>
        </div>

        <!-- 습관 추가 폼 -->
        <div id="add-habit-form" class="add-habit-form" style="display: none;">
            <h5 style="margin-bottom: 20px;">새로운 습관 만들기</h5>
            <form id="habitForm">
                <div class="form-row">
                    <div class="form-group">
                        <label for="habitName">습관 이름 *</label>
                        <input type="text" id="habitName" name="habitName" placeholder="예: 아침 운동" required>
                    </div>
                    <div class="form-group">
                        <label for="icon">아이콘</label>
                        <select id="icon" name="icon">
                            <option value="💪">💪 운동</option>
                            <option value="📚">📚 독서</option>
                            <option value="🧘">🧘 명상</option>
                            <option value="💧">💧 물 마시기</option>
                            <option value="🎨">🎨 취미</option>
                            <option value="✍️">✍️ 글쓰기</option>
                            <option value="🎵">🎵 음악</option>
                            <option value="🌱">🌱 자기계발</option>
                            <option value="😴">😴 수면</option>
                            <option value="🍎">🍎 건강식</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="category">카테고리</label>
                        <select id="category" name="category">
                            <option value="건강">건강</option>
                            <option value="학습">학습</option>
                            <option value="생산성">생산성</option>
                            <option value="취미">취미</option>
                            <option value="관계">관계</option>
                            <option value="기타">기타</option>
                        </select>
                    </div>
                    <div class="form-group" style="max-width: 150px;">
                        <label for="targetFrequency">주당 목표</label>
                        <input type="number" id="targetFrequency" name="targetFrequency" value="7" min="1" max="7">
                    </div>
                </div>
                <div class="form-group">
                    <label for="description">설명 (선택)</label>
                    <textarea id="description" name="description" placeholder="이 습관에 대한 간단한 설명을 적어주세요"></textarea>
                </div>
                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="submit-btn">습관 등록</button>
                    <button type="button" class="btn btn-secondary" onclick="habitTracker.toggleForm()">취소</button>
                </div>
            </form>
        </div>

        <!-- 습관 목록 -->
        <div id="habit-list">
            <div class="empty-state">
                <div class="empty-state-icon">📋</div>
                <h4>아직 등록된 습관이 없습니다</h4>
                <p>위의 "새 습관 추가" 버튼을 눌러 시작해보세요!</p>
            </div>
        </div>
    </div>
</div>

<!-- AI 리포트 모달 -->
<div id="ai-report-modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 9999; padding: 20px; overflow-y: auto;">
    <div style="max-width: 800px; margin: 50px auto; background: white; border-radius: 12px; padding: 30px; position: relative;">
        <button onclick="habitTracker.closeModal()" style="position: absolute; top: 20px; right: 20px; background: none; border: none; font-size: 1.5rem; cursor: pointer; color: #999;">&times;</button>
        <div id="modal-content">
            <div style="text-align: center; padding: 40px;">
                <div class="spinner-border text-primary" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <p style="margin-top: 20px;">AI가 분석 중입니다...</p>
            </div>
        </div>
    </div>
</div>