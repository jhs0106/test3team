<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    #calendar-container {
        display: flex;
        gap: 20px;
        padding: 20px;
    }
    #calendar {
        flex: 2;
        min-height: 600px;
        background: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    #chat-panel {
        flex: 1;
        border: 1px solid #ddd;
        border-radius: 8px;
        padding: 20px;
        background: #f9f9f9;
        max-width: 400px;
    }
    #chat-messages {
        height: 400px;
        overflow-y: auto;
        border: 1px solid #ddd;
        padding: 10px;
        background: white;
        margin-bottom: 10px;
        border-radius: 5px;
    }
    .message {
        margin-bottom: 10px;
        padding: 10px;
        border-radius: 5px;
    }
    .user-message {
        background: #007bff;
        color: white;
        text-align: right;
    }
    .ai-message {
        background: #e9ecef;
        color: #333;
    }
    #schedule-input {
        width: 100%;
        height: 80px;
        margin-bottom: 10px;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 5px;
    }
    .modal-overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.7);
        z-index: 9998;
        animation: fadeIn 0.3s;
    }
    .schedule-modal {
        display: none;
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: white;
        border-radius: 15px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        z-index: 9999;
        width: 90%;
        max-width: 600px;
        max-height: 80vh;
        overflow-y: auto;
        animation: slideUp 0.3s;
    }
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translate(-50%, -40%);
        }
        to {
            opacity: 1;
            transform: translate(-50%, -50%);
        }
    }
    .modal-header {
        padding: 20px;
        border-bottom: 2px solid #f0f0f0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .modal-body {
        padding: 20px;
    }
    .modal-footer {
        padding: 15px 20px;
        border-top: 1px solid #f0f0f0;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
    }
    .info-row {
        display: flex;
        align-items: flex-start;
        margin-bottom: 15px;
        padding-bottom: 15px;
        border-bottom: 1px solid #f5f5f5;
    }
    .info-icon {
        width: 30px;
        font-size: 1.2em;
        margin-right: 10px;
    }
    .info-content {
        flex: 1;
    }
    .info-label {
        font-weight: bold;
        color: #666;
        font-size: 0.9em;
        margin-bottom: 5px;
    }
    .info-value {
        color: #333;
        white-space: pre-line;
    }
    .close-modal {
        background: none;
        border: none;
        font-size: 1.5em;
        cursor: pointer;
        color: #999;
        transition: color 0.2s;
    }
    .close-modal:hover {
        color: #333;
    }
    .category-badge {
        display: inline-block;
        padding: 5px 15px;
        border-radius: 20px;
        font-size: 0.85em;
        font-weight: bold;
        color: white;
    }
</style>

<script>
    let scheduleManager = {
        calendar: null,
        currentEvent: null,

        init: function() {
            this.initCalendar();
            this.initEventHandlers();
        },

        initCalendar: function() {
            let calendarEl = document.getElementById('calendar');
            this.calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                timeZone: 'local',
                locale: 'ko',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay'
                },
                buttonText: {
                    today: '오늘',
                    month: '월',
                    week: '주',
                    day: '일'
                },
                events: function(info, successCallback, failureCallback) {
                    scheduleManager.loadSchedules(info.start, info.end, successCallback, failureCallback);
                },
                editable: true,
                selectable: true,
                eventClick: (info) => {
                    this.handleEventClick(info);
                }
            });
            this.calendar.render();
        },

        initEventHandlers: function() {
            $('#send-btn').click(() => this.sendScheduleRequest());
            $('#schedule-input').keypress((e) => {
                if (e.which === 13 && !e.shiftKey) {
                    e.preventDefault();
                    this.sendScheduleRequest();
                }
            });
        },

        sendScheduleRequest: async function() {
            const input = $('#schedule-input').val().trim();
            if (!input) {
                alert('일정 내용을 입력해주세요.');
                return;
            }

            this.addMessage('user', input);
            $('#schedule-input').val('');

            const loadingMsg = this.addMessage('ai', '일정을 분석하고 있습니다... ⏳');

            try {
                const response = await fetch('/schedule', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'input=' + encodeURIComponent(input)
                });

                if (!response.ok) {
                    throw new Error('서버 오류');
                }

                const data = await response.json();
                loadingMsg.remove();

                this.addMessage('ai', data.message);

                if (data.clarificationQuestions && data.clarificationQuestions.length > 0) {
                    data.clarificationQuestions.forEach(q => {
                        setTimeout(() => this.addMessage('ai', '❓ ' + q), 300);
                    });
                }

                if (data.status === 'SUCCESS') {
                    setTimeout(() => {
                        this.calendar.refetchEvents();
                        this.addMessage('ai', '✅ 일정이 캘린더에 추가되었습니다!');

                        const category = data.schedules[0].category;
                        const encouragement = this.getEncouragementMessage(category);
                        setTimeout(() => {
                            this.addMessage('ai', encouragement);
                        }, 500);
                    }, 500);
                }

            } catch (error) {
                loadingMsg.remove();
                this.addMessage('ai', '❌ 오류: ' + error.message);
            }
        },

        loadSchedules: async function(start, end, successCallback, failureCallback) {
            try {
                const startStr = start.toISOString();
                const endStr = end.toISOString();

                const response = await fetch('/schedule/events?start=' + startStr + '&end=' + endStr);

                if (!response.ok) {
                    throw new Error('일정 로드 실패');
                }

                const events = await response.json();

                const calendarEvents = events.map(event => {
                    return {
                        id: String(event.scheduleId || event.id),
                        title: event.title,
                        start: event.start,
                        end: event.end,
                        backgroundColor: this.getCategoryColor(event.category),
                        extendedProps: {
                            scheduleId: event.scheduleId || event.id,
                            description: event.description,
                            location: event.location,
                            category: event.category
                        }
                    };
                });

                successCallback(calendarEvents);

            } catch (error) {
                console.error('일정 로드 실패:', error);
                failureCallback(error);
            }
        },

        getCategoryColor: function(category) {
            const colors = {
                '외모관리': '#FF6B9D',
                '대화연습': '#4A90E2',
                '취미활동': '#FFA07A',
                '데이트연습': '#C44569',
                '자기계발': '#9B59B6'
            };
            return colors[category] || '#95A5A6';
        },

        getEncouragementMessage: function(category) {
            const messages = {
                '외모관리': '💪 꾸준한 외모 관리는 자신감의 시작이에요! 화이팅!',
                '대화연습': '🗣️ 사람을 만나는 게 최고의 연습이에요! 잘하고 있어요!',
                '취미활동': '🎨 취미는 매력 포인트가 됩니다! 멋져요!',
                '데이트연습': '💕 실전 연습이 중요해요! 긴장하지 말고 즐겨보세요!',
                '자기계발': '📚 자기계발은 미래에 대한 투자예요! 응원합니다!'
            };
            return messages[category] || '👍 잘하고 있어요!';
        },

        handleEventClick: function(info) {
            const event = info.event;
            const props = event.extendedProps;
            const scheduleId = event.id || event._def?.publicId || props.scheduleId;

            if (!scheduleId || scheduleId === '') {
                alert('일정 ID를 찾을 수 없습니다.');
                return;
            }

            this.currentEvent = event;

            $('#modal-title').text(event.title);

            const categoryColor = this.getCategoryColor(props.category);
            $('#modal-category').html(
                    '<span class="category-badge" style="background: ' + categoryColor + '">' + props.category + '</span>'
            );

            $('#modal-start').text(this.formatDateTime(event.start));
            $('#modal-end').text(this.formatDateTime(event.end));

            if (props.location) {
                $('#modal-location').text(props.location);
                $('#modal-location-row').show();
            } else {
                $('#modal-location-row').hide();
            }

            if (props.description) {
                $('#modal-description').text(props.description);
                $('#modal-description-row').show();
            } else {
                $('#modal-description-row').hide();
            }

            const self = this;

            $('#modal-delete-btn').off('click').on('click', function() {
                if (confirm('이 일정을 삭제하시겠습니까?')) {
                    self.deleteSchedule(scheduleId, event);
                    self.closeModal();
                }
            });

            $('#modal-overlay').fadeIn(300);
            $('#schedule-modal').fadeIn(300);
        },

        closeModal: function() {
            $('#modal-overlay').fadeOut(300);
            $('#schedule-modal').fadeOut(300);
            this.currentEvent = null;
        },

        deleteSchedule: async function(scheduleId, eventObj) {
            if (!scheduleId) {
                alert('삭제할 일정 ID가 없습니다.');
                return;
            }

            try {
                const url = '/schedule/' + scheduleId;
                const response = await fetch(url, {
                    method: 'DELETE'
                });

                if (!response.ok) {
                    throw new Error('삭제 실패');
                }

                eventObj.remove();
                this.addMessage('ai', '🗑️ 일정이 삭제되었습니다.');

            } catch (error) {
                console.error('삭제 실패:', error);
                alert('일정 삭제 실패: ' + error.message);
            }
        },

        addMessage: function(type, text) {
            const messageClass = type === 'user' ? 'user-message' : 'ai-message';
            const messageHtml = '<div class="message ' + messageClass + '">' + text + '</div>';
            $('#chat-messages').append(messageHtml);

            const chatMessages = document.getElementById('chat-messages');
            chatMessages.scrollTop = chatMessages.scrollHeight;

            return $('#chat-messages .message:last');
        },

        formatDateTime: function(date) {
            if (!date) return '';
            const d = new Date(date);
            return d.toLocaleString('ko-KR', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        }
    };

    $(document).ready(function() {
        scheduleManager.init();

        $('#modal-overlay').click(function() {
            scheduleManager.closeModal();
        });
    });
</script>

<div class="col-sm-10">
    <h2>📈 자기계발 캘린더</h2>
    <p class="text-muted">
        AI와 함께하는 나만의 성장 일정! 외모관리, 대화연습, 취미활동 등을 계획하고 실천해보세요. 💪
    </p>

    <div id="calendar-container">
        <!-- FullCalendar -->
        <div id="calendar"></div>

        <!-- AI Chat Panel -->
        <div id="chat-panel">
            <h5>💬 일정 추가하기</h5>

            <div style="background: #e3f2fd; padding: 10px; border-radius: 5px; margin-bottom: 10px; font-size: 0.85em;">
                <strong>💡 예시:</strong><br>
                • 내일 저녁 7시 헬스장<br>
                • 다음주 토요일 친구들이랑 등산<br>
                • 목요일 오후 2시 미용실<br>
                • 10월 22일부터 26일까지 운동 계획 짜줘
            </div>

            <div id="chat-messages">
                <div class="message ai-message">
                    안녕하세요! 😊<br>
                    자기계발 일정을 말씀해주시면 AI가 자동으로 캘린더에 추가해드립니다.<br><br>
                    <strong>카테고리:</strong><br>
                    💪 외모관리 | 🗣️ 대화연습 | 🎨 취미활동<br>
                    💕 데이트연습 | 📚 자기계발
                </div>
            </div>
            <textarea id="schedule-input" placeholder="계획을 입력해주세요."></textarea>
            <button id="send-btn" class="btn btn-primary btn-block">
                <i class="fas fa-plus-circle"></i> 일정 추가
            </button>
        </div>
    </div>

    <!-- Modal -->
    <div class="modal-overlay" id="modal-overlay"></div>
    <div class="schedule-modal" id="schedule-modal">
        <div class="modal-header">
            <h4 id="modal-title" style="margin: 0;">일정 상세</h4>
            <button class="close-modal" onclick="scheduleManager.closeModal()">×</button>
        </div>
        <div class="modal-body">
            <div class="info-row">
                <div class="info-icon">🏷️</div>
                <div class="info-content">
                    <div class="info-label">카테고리</div>
                    <div id="modal-category"></div>
                </div>
            </div>
            <div class="info-row">
                <div class="info-icon">📅</div>
                <div class="info-content">
                    <div class="info-label">시작 시간</div>
                    <div class="info-value" id="modal-start"></div>
                </div>
            </div>
            <div class="info-row">
                <div class="info-icon">⏰</div>
                <div class="info-content">
                    <div class="info-label">종료 시간</div>
                    <div class="info-value" id="modal-end"></div>
                </div>
            </div>
            <div class="info-row" id="modal-location-row" style="display: none;">
                <div class="info-icon">📍</div>
                <div class="info-content">
                    <div class="info-label">장소</div>
                    <div class="info-value" id="modal-location"></div>
                </div>
            </div>
            <div class="info-row" id="modal-description-row" style="display: none;">
                <div class="info-icon">📝</div>
                <div class="info-content">
                    <div class="info-label">상세 정보</div>
                    <div class="info-value" id="modal-description"></div>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="scheduleManager.closeModal()">닫기</button>
            <button class="btn btn-danger" id="modal-delete-btn">
                <i class="fas fa-trash"></i> 삭제
            </button>
        </div>
    </div>
</div>