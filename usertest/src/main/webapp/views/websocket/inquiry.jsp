<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .inquiry-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
    }
    .inquiry-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 30px;
        border-radius: 12px;
        text-align: center;
        margin-bottom: 30px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    .inquiry-header h2 {
        margin: 0 0 10px 0;
        font-size: 28px;
        font-weight: bold;
    }
    .inquiry-header p {
        margin: 0;
        font-size: 16px;
        opacity: 0.9;
    }
    .inquiry-info {
        background: #f8f9fa;
        border-left: 4px solid #667eea;
        padding: 20px;
        border-radius: 8px;
        margin-bottom: 30px;
    }
    .inquiry-info h5 {
        color: #333;
        margin-bottom: 15px;
        font-weight: 600;
    }
    .inquiry-info ul {
        margin: 0;
        padding-left: 20px;
    }
    .inquiry-info li {
        margin-bottom: 8px;
        color: #666;
    }
    .chat-status {
        background: white;
        border: 2px solid #e9ecef;
        border-radius: 12px;
        padding: 25px;
        margin-bottom: 20px;
        text-align: center;
    }
    .chat-status .status-icon {
        font-size: 48px;
        margin-bottom: 15px;
    }
    .chat-status .status-message {
        font-size: 18px;
        color: #333;
        margin-bottom: 10px;
        font-weight: 600;
    }
    .chat-status .status-detail {
        font-size: 14px;
        color: #666;
    }
    .chat-status .room-info {
        margin-top: 15px;
        padding-top: 15px;
        border-top: 1px solid #e9ecef;
        color: #999;
        font-size: 13px;
    }
    .btn-start-chat {
        width: 100%;
        padding: 15px;
        font-size: 18px;
        font-weight: bold;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border: none;
        border-radius: 8px;
        color: white;
        cursor: pointer;
        transition: all 0.3s;
        box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
    }
    .btn-start-chat:hover:not(:disabled) {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
    }
    .btn-start-chat:disabled {
        background: #6c757d;
        cursor: not-allowed;
        transform: none;
        box-shadow: none;
    }
    .alert {
        border-radius: 8px;
        padding: 15px;
        margin-bottom: 20px;
        border: none;
    }
    .alert-success {
        background: #d4edda;
        color: #155724;
    }
    .alert-danger {
        background: #f8d7da;
        color: #721c24;
    }
    .chat-panel {
        margin-top: 30px;
        border: 1px solid #e9ecef;
        border-radius: 12px;
        background: white;
        padding: 20px;
        box-shadow: 0 10px 30px rgba(31, 45, 61, 0.1);
    }
    .chat-panel h4 {
        margin-bottom: 15px;
        font-weight: 600;
        color: #4a4a4a;
    }
    .chat-status-indicator {
        font-size: 14px;
        color: #6c757d;
        margin-bottom: 10px;
    }
    .chat-messages {
        height: 280px;
        overflow-y: auto;
        border: 1px solid #e9ecef;
        border-radius: 10px;
        padding: 15px;
        margin-bottom: 15px;
        background: #f8f9fb;
    }
    .chat-message {
        margin-bottom: 12px;
        line-height: 1.5;
    }
    .chat-message .sender {
        display: block;
        font-weight: 600;
    }
    .chat-message.user .sender {
        color: #764ba2;
    }
    .chat-message.admin .sender {
        color: #007bff;
    }
    .chat-input-group {
        display: flex;
        gap: 10px;
    }
    .chat-input-group input {
        flex: 1;
        border-radius: 8px;
        border: 1px solid #ced4da;
        padding: 10px 12px;
    }
    .chat-input-group button {
        background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        border: none;
        color: white;
        padding: 0 24px;
        border-radius: 8px;
        font-weight: 600;
    }
    .chat-input-group button:disabled {
        background: #6c757d;
    }
</style>

<script>
    let inquiryPage = {
        custId: null,
        activeRoomId: null,
        stompClient: null,
        isConnected: false,

        init: function() {
            // 세션에서 사용자 ID 가져오기
            this.custId = '${sessionScope.cust}';

            if (!this.custId || this.custId === '') {
                this.custId = 'guest_' + Math.floor(Math.random() * 10000);
                console.log('⚠️ 세션 없음, 임시 ID 생성:', this.custId);
            }

            console.log('👤 현재 사용자 ID:', this.custId);

            this.bindEvents();
            this.updateConnectionStatus(false);
            this.connectWebSocket();
            // 활성 채팅방 확인
            this.checkActiveRoom();
        },

        bindEvents: function() {
            $('#sendChatBtn').click(() => {
                this.sendMessage();
            });
            $('#chatMessage').on('keypress', (e) => {
                if (e.which === 13) {
                    e.preventDefault();
                    this.sendMessage();
                }
            });
        },

        checkActiveRoom: function() {
            $.ajax({
                url: 'https://192.168.45.176:8443/api/chatroom/active/' + this.custId,
                type: 'GET',
                dataType: 'json',
                success: (data) => {
                    if (data && data.roomId) {
                        console.log('✅ 활성 채팅방 존재:', data);
                        this.activeRoomId = data.roomId;
                        this.showActiveRoomStatus(data);
                    } else {
                        console.log('ℹ️ 활성 채팅방 없음');
                        this.showReadyStatus();
                    }
                },
                error: (xhr) => {
                    console.log('ℹ️ 활성 채팅방 조회 실패 (없음)');
                    this.showReadyStatus();
                }
            });
        },

        connectWebSocket: function() {
            if (this.stompClient || !this.custId) {
                return;
            }

            try {
                const socket = new SockJS('${websocketurl}chat');
                this.stompClient = Stomp.over(socket);
                this.stompClient.connect({}, (frame) => {
                    console.log('✅ WebSocket 연결 완료:', frame);
                    this.updateConnectionStatus(true);

                    // 메시지 수신 처리
                    this.stompClient.subscribe('/adminsend/to/' + this.custId, (message) => {
                        const payload = JSON.parse(message.body);

                        // 종료 시그널 확인
                        if (payload.content1 === '__CHAT_CLOSED__') {
                            this.handleChatClosed();
                        } else {
                            this.appendMessage('admin', payload.content1);
                        }
                    });
                }, (error) => {
                    console.error('❌ WebSocket 연결 실패:', error);
                    this.stompClient = null;
                    this.updateConnectionStatus(false);
                });

                socket.onclose = () => {
                    console.log('ℹ️ WebSocket 연결 종료');
                    this.stompClient = null;
                    this.updateConnectionStatus(false);
                };
            } catch (e) {
                console.error('WebSocket 초기화 실패:', e);
                this.updateConnectionStatus(false);
            }
        },

        handleChatClosed: function() {
            // 시스템 메시지 표시
            this.appendMessage('admin', '⚠️ 상담사가 채팅을 종료했습니다. 감사합니다!');

            // UI 업데이트
            $('#chatConnection').text('상담 종료됨').removeClass('text-success').addClass('text-warning');
            $('#sendChatBtn').prop('disabled', true);
            $('#chatMessage').prop('disabled', true);

            // WebSocket 연결 해제
            if (this.stompClient) {
                this.stompClient.disconnect();
                this.stompClient = null;
            }

            this.isConnected = false;
            this.activeRoomId = null;

            // 상태 메시지 업데이트
            $('#statusMessage').html(
                '<div class="alert alert-warning">' +
                '<i class="fas fa-check-circle"></i> ' +
                '상담이 종료되었습니다. 새로운 문의를 시작하려면 페이지를 새로고침하세요.' +
                '</div>'
            );
        },

        updateConnectionStatus: function(isConnected) {
            this.isConnected = isConnected;
            const canChat = isConnected && this.activeRoomId;
            if (isConnected) {
                $('#chatConnection').text('실시간 상담 연결됨').removeClass('text-danger').addClass('text-success');
                $('#sendChatBtn').prop('disabled', !canChat);
                $('#chatMessage').prop('disabled', !canChat);
            } else {
                $('#chatConnection').text('연결 대기 중...').removeClass('text-success').addClass('text-danger');
                $('#sendChatBtn').prop('disabled', true);
                $('#chatMessage').prop('disabled', true);
            }
        },

        appendMessage: function(sender, message) {
            const sanitized = $('<div>').text(message).html();
            const time = new Date().toLocaleTimeString();
            const senderLabel = sender === 'user' ? '나' : '상담사';
            const messageClass = sender === 'user' ? 'user' : 'admin';

            $('#chatMessages').append(
                '<div class="chat-message ' + messageClass + '">' +
                '<span class="sender">[' + time + '] ' + senderLabel + '</span>' +
                '<span class="text">' + sanitized + '</span>' +
                '</div>'
            );
            $('#chatMessages').scrollTop($('#chatMessages')[0].scrollHeight);
        },

        sendMessage: function() {
            if (!this.isConnected || !this.stompClient) {
                alert('상담 연결이 아직 완료되지 않았습니다. 잠시 후 다시 시도해주세요.');
                return;
            }

            const message = $('#chatMessage').val().trim();
            if (!message) {
                return;
            }

            const payload = {
                sendid: this.custId,
                receiveid: 'admin',
                content1: message
            };

            this.stompClient.send('/receiveto', {}, JSON.stringify(payload));
            this.appendMessage('user', message);
            $('#chatMessage').val('');
        },

        createChatRoom: function() {
            if (this.activeRoomId) {
                alert('이미 진행 중인 채팅방이 있습니다.');
                return;
            }

            $('#startChatBtn').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> 생성 중...');

            $.ajax({
                url: 'https://192.168.45.176:8443/api/chatroom/create',
                type: 'POST',
                data: { custId: this.custId },
                success: (response) => {
                    console.log('✅ 채팅방 생성 성공:', response);

                    $('#statusMessage').html(
                        '<div class="alert alert-success">' +
                        '<i class="fas fa-check-circle"></i> ' +
                        '채팅방이 생성되었습니다! 상담사 연결 대기 중...' +
                        '</div>'
                    );

                    // 활성 채팅방 다시 확인
                    setTimeout(() => {
                        this.checkActiveRoom();
                    }, 1000);
                },
                error: (xhr, status, error) => {
                    console.error('❌ 채팅방 생성 실패:', error);
                    console.error('Response:', xhr.responseText);

                    $('#statusMessage').html(
                        '<div class="alert alert-danger">' +
                        '<i class="fas fa-exclamation-circle"></i> ' +
                        '채팅방 생성에 실패했습니다. 다시 시도해주세요.' +
                        '</div>'
                    );

                    $('#startChatBtn').prop('disabled', false).html('<i class="fas fa-comments"></i> 채팅 시작하기');
                }
            });
        },

        showReadyStatus: function() {
            this.activeRoomId = null;
            $('#chatStatus').html(
                '<div class="chat-status">' +
                '<div class="status-icon">💬</div>' +
                '<div class="status-message">상담을 시작할 준비가 되었습니다</div>' +
                '<div class="status-detail">아래 버튼을 클릭하여 상담을 시작하세요</div>' +
                '</div>' +
                '<button id="startChatBtn" class="btn-start-chat">' +
                '<i class="fas fa-comments"></i> 채팅 시작하기' +
                '</button>'
            );

            $('#startChatBtn').click(() => {
                this.createChatRoom();
            });
            this.updateConnectionStatus(this.isConnected);
        },

        showActiveRoomStatus: function(room) {
            let statusIcon = room.status === 'waiting' ? '⏳' : '✅';
            let statusText = room.status === 'waiting' ? '상담사 연결 대기 중' : '상담 진행 중';
            let statusDetail = room.status === 'waiting' ?
                '상담사가 곧 연결됩니다. 잠시만 기다려주세요.' :
                '상담사와 연결되었습니다.';

            $('#chatStatus').html(
                '<div class="chat-status">' +
                '<div class="status-icon">' + statusIcon + '</div>' +
                '<div class="status-message">' + statusText + '</div>' +
                '<div class="status-detail">' + statusDetail + '</div>' +
                '<div class="room-info">채팅방 번호: ' + room.roomId + ' | 고객 ID: ' + room.custId + '</div>' +
                '</div>' +
                '<button class="btn-start-chat" disabled>' +
                '<i class="fas fa-check-circle"></i> 채팅방 생성됨' +
                '</button>'
            );
            this.updateConnectionStatus(this.isConnected);
        }
    };

    $(function() {
        inquiryPage.init();
    });
</script>

<div class="col-sm-10">
    <div class="inquiry-container">
        <div class="inquiry-header">
            <h2>🎧 고객 상담 센터</h2>
            <p>무엇을 도와드릴까요?</p>
        </div>

        <div class="inquiry-info">
            <h5>📋 상담 안내</h5>
            <ul>
                <li>실시간 1:1 상담을 제공합니다</li>
                <li>상담 가능 시간: 평일 09:00 ~ 18:00</li>
                <li>긴급한 문의는 고객센터(1588-0000)로 연락해주세요</li>
            </ul>
        </div>

        <div id="statusMessage"></div>

        <div id="chatStatus">
            <div class="chat-status">
                <div class="status-icon">⏳</div>
                <div class="status-message">로딩 중...</div>
                <div class="status-detail">잠시만 기다려주세요</div>
            </div>
        </div>

        <div class="chat-panel">
            <h4>실시간 상담</h4>
            <div class="chat-status-indicator">연결 상태: <span id="chatConnection" class="text-danger">연결 대기 중...</span></div>
            <div id="chatMessages" class="chat-messages"></div>
            <div class="chat-input-group">
                <input type="text" id="chatMessage" placeholder="상담사에게 메시지를 입력하세요" disabled>
                <button id="sendChatBtn" disabled>전송</button>
            </div>
        </div>
    </div>
</div>

