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
</style>

<script>
    let scheduleManager = {
        calendar: null,

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
                events: (info, successCallback, failureCallback) => {
                    this.loadSchedules(info.start, info.end, successCallback, failureCallback);
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
                const response = await fetch('/schedule/test', {
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

                const response = await fetch(`/schedule/events?start=\${startStr}&end=\${endStr}`);

                if (!response.ok) {
                    throw new Error('일정 로드 실패');
                }

                const events = await response.json();

                const calendarEvents = events.map(event => ({
                    id: event.scheduleId,
                    title: event.title,
                    start: event.startDatetime,
                    end: event.endDatetime,
                    backgroundColor: this.getCategoryColor(event.category),
                    extendedProps: {
                        description: event.description,
                        location: event.location,
                        category: event.category
                    }
                }));

                successCallback(calendarEvents);

            } catch (error) {
                console.error('일정 로드 실패:', error);
                failureCallback(error);
            }
        },

        getCategoryColor: function(category) {
            const colors = {
                '회의': '#007bff',
                '약속': '#28a745',
                '개인': '#ffc107',
                '업무': '#dc3545',
                '기타': '#6c757d'
            };
            return colors[category] || '#6c757d';
        },

        handleEventClick: function(info) {
            const event = info.event;
            const props = event.extendedProps;

            let details = `제목: \${event.title}\n`;
            details += `시작: \${this.formatDateTime(event.start)}\n`;
            details += `종료: \${this.formatDateTime(event.end)}\n`;
            if (props.location) details += `장소: \${props.location}\n`;
            if (props.category) details += `카테고리: \${props.category}\n`;
            if (props.description) details += `설명: \${props.description}\n`;

            if (confirm(details + '\n\n이 일정을 삭제하시겠습니까?')) {
                this.deleteSchedule(event.id, info.event);
            }
        },

        deleteSchedule: async function(scheduleId, eventObj) {
            try {
                const response = await fetch(`/schedule/\${scheduleId}`, {
                    method: 'DELETE'
                });

                if (!response.ok) {
                    throw new Error('삭제 실패');
                }

                eventObj.remove();
                this.addMessage('ai', '🗑️ 일정이 삭제되었습니다.');

            } catch (error) {
                alert('일정 삭제 실패');
            }
        },

        addMessage: function(type, text) {
            const messageClass = type === 'user' ? 'user-message' : 'ai-message';
            const $message = $(`<div class="message \${messageClass}">\${text}</div>`);
            $('#chat-messages').append($message);

            const chatMessages = document.getElementById('chat-messages');
            chatMessages.scrollTop = chatMessages.scrollHeight;

            return $message;
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
    });
</script>

<div class="col-sm-10">
    <h2>🗓️ AI 일정 관리 캘린더</h2>
    <p class="text-muted">자연어로 일정을 입력하면 AI가 자동으로 캘린더에 추가합니다!</p>

    <div id="calendar-container">
        <!-- FullCalendar -->
        <div id="calendar"></div>

        <!-- AI Chat Panel -->
        <div id="chat-panel">
            <h5>💬 일정 추가하기</h5>
            <div id="chat-messages">
                <div class="message ai-message">
                    안녕하세요! 일정을 자연어로 말씀해주시면 자동으로 캘린더에 추가해드립니다. 😊
                </div>
            </div>
            <textarea id="schedule-input" placeholder="예: 내일 오후 3시에 강남에서 회의"></textarea>
            <button id="send-btn" class="btn btn-primary btn-block">일정 추가</button>
        </div>
    </div>
</div>