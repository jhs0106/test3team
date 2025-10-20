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
                events: function(info, successCallback, failureCallback) {
                    scheduleManager.loadSchedules(info.start, info.end, successCallback, failureCallback);
                },
                editable: true,
                selectable: true,
                eventClick: function(info) {
                    scheduleManager.handleEventClick(info);
                }
            });
            this.calendar.render();
        },

        initEventHandlers: function() {
            var self = this;
            $('#send-btn').click(function() {
                self.sendScheduleRequest();
            });
            $('#schedule-input').keypress(function(e) {
                if (e.which === 13 && !e.shiftKey) {
                    e.preventDefault();
                    self.sendScheduleRequest();
                }
            });
        },

        sendScheduleRequest: function() {
            var self = this;
            var input = $('#schedule-input').val().trim();
            if (!input) {
                alert('일정 내용을 입력해주세요.');
                return;
            }

            this.addMessage('user', input);
            $('#schedule-input').val('');

            var loadingMsg = this.addMessage('ai', '일정을 분석하고 있습니다... ⏳');

            fetch('/schedule/test', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'input=' + encodeURIComponent(input)
            })
                    .then(function(response) {
                        if (!response.ok) {
                            throw new Error('서버 오류');
                        }
                        return response.json();
                    })
                    .then(function(data) {
                        loadingMsg.remove();
                        self.addMessage('ai', data.message);

                        if (data.clarificationQuestions && data.clarificationQuestions.length > 0) {
                            data.clarificationQuestions.forEach(function(q) {
                                setTimeout(function() {
                                    self.addMessage('ai', '❓ ' + q);
                                }, 300);
                            });
                        }

                        if (data.status === 'SUCCESS') {
                            setTimeout(function() {
                                self.calendar.refetchEvents();
                                self.addMessage('ai', '✅ 일정이 캘린더에 추가되었습니다!');
                            }, 500);
                        }
                    })
                    .catch(function(error) {
                        loadingMsg.remove();
                        self.addMessage('ai', '❌ 오류: ' + error.message);
                    });
        },

        loadSchedules: function(start, end, successCallback, failureCallback) {
            var self = this;
            var startStr = start ? start.toISOString() : '';
            var endStr = end ? end.toISOString() : '';

            console.log('일정 조회:', startStr, endStr);

            fetch('/schedule/events?start=' + encodeURIComponent(startStr) + '&end=' + encodeURIComponent(endStr))
                    .then(function(response) {
                        if (!response.ok) {
                            throw new Error('일정 로드 실패');
                        }
                        return response.json();
                    })
                    .then(function(events) {
                        console.log('조회된 일정:', events);

                        var calendarEvents = events.map(function(event) {
                            return {
                                id: event.id,
                                title: event.title,
                                start: event.start,
                                end: event.end,
                                backgroundColor: self.getCategoryColor(event.category),
                                extendedProps: {
                                    description: event.description,
                                    location: event.location,
                                    category: event.category
                                }
                            };
                        });

                        successCallback(calendarEvents);
                    })
                    .catch(function(error) {
                        console.error('일정 로드 실패:', error);
                        failureCallback(error);
                    });
        },

        getCategoryColor: function(category) {
            var colors = {
                '회의': '#007bff',
                '약속': '#28a745',
                '개인': '#ffc107',
                '업무': '#dc3545',
                '기타': '#6c757d'
            };
            return colors[category] || '#6c757d';
        },

        handleEventClick: function(info) {
            var event = info.event;
            var props = event.extendedProps;

            var details = '제목: ' + event.title + '\n';
            details += '시작: ' + this.formatDateTime(event.start) + '\n';
            details += '종료: ' + this.formatDateTime(event.end) + '\n';
            if (props.location) details += '장소: ' + props.location + '\n';
            if (props.category) details += '카테고리: ' + props.category + '\n';
            if (props.description) details += '설명: ' + props.description + '\n';

            if (confirm(details + '\n\n이 일정을 삭제하시겠습니까?')) {
                this.deleteSchedule(event.id, info.event);
            }
        },

        deleteSchedule: function(scheduleId, eventObj) {
            var self = this;
            fetch('/schedule/' + scheduleId, {
                method: 'DELETE'
            })
                    .then(function(response) {
                        if (!response.ok) {
                            throw new Error('삭제 실패');
                        }
                        eventObj.remove();
                        self.addMessage('ai', '🗑️ 일정이 삭제되었습니다.');
                    })
                    .catch(function(error) {
                        alert('일정 삭제 실패');
                    });
        },

        addMessage: function(type, text) {
            var messageClass = type === 'user' ? 'user-message' : 'ai-message';
            var $message = $('<div class="message ' + messageClass + '">' + text + '</div>');
            $('#chat-messages').append($message);

            var chatMessages = document.getElementById('chat-messages');
            chatMessages.scrollTop = chatMessages.scrollHeight;

            return $message;
        },

        formatDateTime: function(date) {
            if (!date) return '';
            var d = new Date(date);
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
        <div id="calendar"></div>

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