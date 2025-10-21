<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* 전체 컨테이너 - 상하 구조 */
    .schedule-wrapper {
        width: 100%;
        height: calc(100vh - 100px);
        display: flex;
        flex-direction: column;
        padding: 20px;
        gap: 20px;
    }

    /* 상단: 캘린더 영역 */
    .calendar-section {
        flex: 1;
        background: white;
        padding: 30px;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        min-height: 500px;
        overflow: auto;
    }

    /* 하단: AI 채팅 패널 */
    .chat-section {
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
        padding: 25px;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        max-height: 400px;
        display: flex;
        flex-direction: column;
    }

    .chat-header {
        color: white;
        margin-bottom: 15px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .chat-header h5 {
        margin: 0;
        font-size: 1.3rem;
        font-weight: 600;
    }

    .chat-hint {
        background: rgba(255,255,255,0.15);
        backdrop-filter: blur(10px);
        padding: 12px 15px;
        border-radius: 8px;
        color: white;
        font-size: 0.85em;
        margin-bottom: 15px;
        border-left: 4px solid rgba(255,255,255,0.5);
    }

    .chat-content {
        display: flex;
        gap: 15px;
        flex: 1;
    }

    #chat-messages {
        flex: 2;
        background: rgba(255,255,255,0.95);
        border-radius: 10px;
        padding: 15px;
        overflow-y: auto;
        max-height: 200px;
        box-shadow: inset 0 2px 4px rgba(0,0,0,0.06);
    }

    .chat-input-area {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    #schedule-input {
        flex: 1;
        padding: 12px;
        border: 2px solid rgba(255,255,255,0.3);
        border-radius: 8px;
        background: rgba(255,255,255,0.95);
        font-size: 0.95em;
        resize: none;
        min-height: 120px;
    }

    #schedule-input:focus {
        outline: none;
        border-color: rgba(255,255,255,0.6);
        box-shadow: 0 0 0 3px rgba(255,255,255,0.1);
    }

    #send-btn {
        background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
        color: white;
        border: none;
        padding: 12px 30px;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
        font-size: 1rem;
        box-shadow: 0 4px 15px rgba(0, 212, 255, 0.3);
    }

    #send-btn:hover {
        background: linear-gradient(135deg, #00b8e6 0%, #0088e6 100%);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 212, 255, 0.4);
    }

    .message {
        margin-bottom: 12px;
        padding: 10px 14px;
        border-radius: 10px;
        animation: slideIn 0.3s;
        clear: both;
        display: block;
    }

    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .user-message {
        background: linear-gradient(135deg, #00d4ff 0%, #0099ff 100%);
        color: white;
        margin-left: auto;
        text-align: right;
        max-width: 80%;
        float: right;
        box-shadow: 0 2px 8px rgba(0, 153, 255, 0.3);
    }

    .ai-message {
        background: #2d3748;
        color: #e2e8f0;
        max-width: 80%;
        float: left;
        border: 1px solid #4a5568;
    }

    /* 모달 스타일 */
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

    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
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
        max-width: 500px;
        width: 90%;
        animation: modalSlideIn 0.3s;
    }

    @keyframes modalSlideIn {
        from {
            opacity: 0;
            transform: translate(-50%, -45%);
        }
        to {
            opacity: 1;
            transform: translate(-50%, -50%);
        }
    }

    .modal-header {
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
        color: white;
        padding: 20px;
        border-radius: 15px 15px 0 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .modal-body {
        padding: 25px;
    }

    .close-btn {
        background: none;
        border: none;
        color: white;
        font-size: 1.5rem;
        cursor: pointer;
        opacity: 0.8;
        transition: opacity 0.2s;
    }

    .close-btn:hover {
        opacity: 1;
    }

    .modal-row {
        margin-bottom: 15px;
        padding-bottom: 15px;
        border-bottom: 1px solid #e9ecef;
    }

    .modal-row:last-child {
        border-bottom: none;
        padding-bottom: 0;
    }

    .modal-label {
        font-weight: 600;
        color: #495057;
        margin-bottom: 8px;
        font-size: 0.9em;
    }

    .modal-value {
        color: #212529;
        font-size: 1em;
    }

    .category-badge {
        display: inline-block;
        padding: 6px 14px;
        border-radius: 20px;
        color: white;
        font-size: 0.9em;
        font-weight: 500;
    }

    .modal-actions {
        display: flex;
        gap: 10px;
        margin-top: 20px;
    }

    .modal-actions button {
        flex: 1;
        padding: 12px;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
    }

    #modal-delete-btn {
        background: #ef4444;
        color: white;
    }

    #modal-delete-btn:hover {
        background: #dc2626;
    }

    #modal-close-btn {
        background: #e5e7eb;
        color: #374151;
    }

    #modal-close-btn:hover {
        background: #d1d5db;
    }

    /* FullCalendar 스타일 커스터마이징 */
    .fc .fc-toolbar-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: #1a1a2e;
    }

    .fc .fc-button-primary {
        background: #0099ff;
        border-color: #0099ff;
    }

    .fc .fc-button-primary:hover {
        background: #0088e6;
        border-color: #0088e6;
    }

    .fc-event {
        border-radius: 4px;
        border: none;
        padding: 2px 5px;
        cursor: pointer;
    }

    /* 반응형 */
    @media (max-width: 1024px) {
        .chat-content {
            flex-direction: column;
        }

        #chat-messages {
            max-height: 150px;
        }
    }
</style>

<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/locales/ko.global.min.js"></script>

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
            let self = this;

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
                height: 'auto',
                events: function(info, successCallback, failureCallback) {
                    self.loadSchedules(info.start, info.end, successCallback, failureCallback);
                },
                editable: true,
                selectable: true,
                eventClick: function(info) {
                    self.handleEventClick(info);
                }
            });
            this.calendar.render();
        },

        initEventHandlers: function() {
            let self = this;
            $('#send-btn').click(function() { self.sendScheduleRequest(); });
            $('#schedule-input').keypress(function(e) {
                if (e.which === 13 && !e.shiftKey) {
                    e.preventDefault();
                    self.sendScheduleRequest();
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

            const loadingMsg = this.addMessage('ai', '⏳ AI가 일정을 분석 중입니다...');

            try {
                const response = await fetch('/schedule?input=' + encodeURIComponent(input), {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'}
                });

                if (!response.ok) {
                    throw new Error('일정 등록 실패');
                }

                const data = await response.json();
                loadingMsg.remove();

                if (data.message) {
                    setTimeout(function() {
                        scheduleManager.addMessage('ai', data.message);

                        if (data.schedules && data.schedules.length > 0) {
                            setTimeout(function() {
                                scheduleManager.addMessage('ai', '✅ 일정이 캘린더에 추가되었습니다!');

                                const category = data.schedules[0].category;
                                const encouragement = scheduleManager.getEncouragementMessage(category);
                                setTimeout(function() {
                                    scheduleManager.addMessage('ai', encouragement);
                                }, 500);
                            }, 500);
                        }
                    }, 500);
                }

                this.calendar.refetchEvents();

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

                const calendarEvents = events.map(function(event) {
                    return {
                        id: String(event.scheduleId || event.id),
                        title: event.title,
                        start: event.start,
                        end: event.end,
                        backgroundColor: scheduleManager.getCategoryColor(event.category),
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
                '외모관리': '#ff6b9d',
                '대화연습': '#00d4ff',
                '취미활동': '#ffd93d',
                '데이트연습': '#ff3864',
                '자기계발': '#a78bfa'
            };
            return colors[category] || '#6c757d';
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
            const scheduleId = event.id || (event._def && event._def.publicId) || props.scheduleId;

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

    <div class="schedule-wrapper">
        <!-- 상단: 캘린더 영역 -->
        <div class="calendar-section">
            <div id="calendar"></div>
        </div>

        <!-- 하단: AI 채팅 패널 -->
        <div class="chat-section">
            <div class="chat-header">
                <h5>💬 일정 추가하기</h5>
                <span style="font-size: 0.9em; opacity: 0.9;">AI가 자동으로 분석해드려요</span>
            </div>

            <div class="chat-hint">
                <strong>💡 예시:</strong> 내일 저녁 7시 헬스장 | 이번주 운동 계획
            </div>

            <div class="chat-content">
                <div id="chat-messages">
                    <div class="message ai-message">
                        안녕하세요! 😊 자기계발 일정을 말씀해주시면 AI가 자동으로 캘린더에 추가해드립니다.<br><br>
                        <strong>카테고리:</strong> 💪 외모관리 | 🗣️ 대화연습 | 🎨 취미활동 | 💕 데이트연습 | 📚 자기계발<br><br>
                        <strong>💡 Tip:</strong> 장기 계획은 일주일씩 나눠서 요청하세요!
                    </div>
                </div>

                <div class="chat-input-area">
                    <textarea id="schedule-input" placeholder="예: 내일 저녁 7시 헬스장 / 이번주 운동 계획 / 다음 주 계획"></textarea>
                    <button id="send-btn">✨ 일정 추가</button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 일정 상세 모달 -->
<div id="modal-overlay" class="modal-overlay"></div>
<div id="schedule-modal" class="schedule-modal">
    <div class="modal-header">
        <h5>📅 일정 상세</h5>
        <button class="close-btn" onclick="scheduleManager.closeModal()">×</button>
    </div>
    <div class="modal-body">
        <div class="modal-row">
            <div class="modal-label">제목</div>
            <div id="modal-title" class="modal-value" style="font-size: 1.1em; font-weight: 600;"></div>
        </div>
        <div class="modal-row">
            <div class="modal-label">카테고리</div>
            <div id="modal-category" class="modal-value"></div>
        </div>
        <div class="modal-row">
            <div class="modal-label">시작</div>
            <div id="modal-start" class="modal-value"></div>
        </div>
        <div class="modal-row">
            <div class="modal-label">종료</div>
            <div id="modal-end" class="modal-value"></div>
        </div>
        <div class="modal-row" id="modal-location-row">
            <div class="modal-label">장소</div>
            <div id="modal-location" class="modal-value"></div>
        </div>
        <div class="modal-row" id="modal-description-row">
            <div class="modal-label">설명</div>
            <div id="modal-description" class="modal-value"></div>
        </div>
        <div class="modal-actions">
            <button id="modal-delete-btn">🗑️ 삭제</button>
            <button id="modal-close-btn" onclick="scheduleManager.closeModal()">닫기</button>
        </div>
    </div>
</div>