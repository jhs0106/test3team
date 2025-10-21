<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .inquiry-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
    }
    .inquiry-header {
        background: #2563eb;
        color: white;
        padding: 30px;
        border-radius: 8px;
        text-align: center;
        margin-bottom: 30px;
    }
    .inquiry-header h2 {
        margin: 0 0 10px 0;
        font-size: 28px;
        font-weight: 600;
    }
    .inquiry-header p {
        margin: 0;
        font-size: 16px;
        opacity: 0.9;
    }
    .inquiry-info {
        background: #f8fafc;
        border-left: 3px solid #2563eb;
        padding: 20px;
        border-radius: 4px;
        margin-bottom: 30px;
    }
    .inquiry-info h5 {
        color: #1e293b;
        margin-bottom: 15px;
        font-weight: 600;
    }
    .inquiry-info ul {
        margin: 0;
        padding-left: 20px;
    }
    .inquiry-info li {
        margin-bottom: 8px;
        color: #64748b;
    }
    .chat-status {
        background: white;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
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
        color: #1e293b;
        margin-bottom: 10px;
        font-weight: 600;
    }
    .chat-status .status-detail {
        font-size: 14px;
        color: #64748b;
    }
    .chat-status .room-info {
        margin-top: 10px;
        font-size: 13px;
        color: #94a3b8;
    }
    .btn-start-chat {
        background: #2563eb;
        color: white;
        border: none;
        padding: 15px 40px;
        border-radius: 6px;
        font-size: 16px;
        font-weight: 500;
        cursor: pointer;
        margin-top: 15px;
        transition: background 0.2s;
    }
    .btn-start-chat:hover {
        background: #1d4ed8;
    }
    .btn-start-chat:disabled {
        background: #94a3b8;
        cursor: not-allowed;
    }
    .chat-panel {
        background: white;
        border-radius: 8px;
        padding: 20px;
        border: 1px solid #e2e8f0;
    }
    .chat-panel h4 {
        margin: 0 0 15px 0;
        color: #1e293b;
        font-weight: 600;
    }
    .chat-status-indicator {
        margin-bottom: 15px;
        font-size: 14px;
        color: #64748b;
    }
    .chat-messages {
        height: 300px;
        overflow-y: auto;
        border: 1px solid #e2e8f0;
        padding: 15px;
        border-radius: 6px;
        margin-bottom: 15px;
        background: #f8fafc;
    }
    .chat-message {
        margin-bottom: 12px;
        line-height: 1.5;
    }
    .chat-message .sender {
        display: block;
        font-weight: 600;
        font-size: 13px;
    }
    .chat-message.user .sender {
        color: #2563eb;
    }
    .chat-message.admin .sender {
        color: #0ea5e9;
    }
    .chat-input-group {
        display: flex;
        gap: 10px;
    }
    .chat-input-group input {
        flex: 1;
        border-radius: 6px;
        border: 1px solid #e2e8f0;
        padding: 10px 12px;
        font-size: 14px;
    }
    .chat-input-group input:focus {
        outline: none;
        border-color: #2563eb;
    }
    .chat-input-group button {
        background: #2563eb;
        border: none;
        color: white;
        padding: 0 24px;
        border-radius: 6px;
        font-weight: 500;
        transition: background 0.2s;
    }
    .chat-input-group button:hover {
        background: #1d4ed8;
    }
    .chat-input-group button:disabled {
        background: #94a3b8;
    }
    .btn-video-call {
        background: #10b981;
        border: none;
        color: white;
        padding: 10px 20px;
        border-radius: 6px;
        font-weight: 500;
        margin-top: 10px;
        width: 100%;
        cursor: pointer;
        transition: background 0.2s;
    }
    .btn-video-call:hover {
        background: #059669;
    }
    .btn-video-call:disabled {
        background: #94a3b8;
        cursor: not-allowed;
    }

    .video-modal {
        display: none;
        position: fixed;
        z-index: 9999;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.85);
    }

    .video-modal-content {
        position: relative;
        background-color: #1e293b;
        margin: 2% auto;
        padding: 0;
        width: 90%;
        max-width: 1200px;
        height: 90%;
        border-radius: 12px;
        display: flex;
        flex-direction: column;
    }

    .video-modal-header {
        background: #334155;
        color: white;
        padding: 20px;
        border-radius: 12px 12px 0 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .video-modal-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
    }

    .video-modal-close {
        color: white;
        font-size: 28px;
        font-weight: normal;
        cursor: pointer;
        background: none;
        border: none;
        padding: 0;
        width: 36px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 6px;
        transition: background-color 0.2s;
    }

    .video-modal-close:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }

    .video-modal-body {
        flex: 1;
        padding: 20px;
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    .video-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        flex: 1;
    }

    .video-wrapper {
        position: relative;
        background: #0f172a;
        border-radius: 8px;
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .video-stream {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .video-label {
        position: absolute;
        top: 12px;
        left: 12px;
        background: rgba(0, 0, 0, 0.6);
        color: white;
        padding: 6px 12px;
        border-radius: 4px;
        font-size: 13px;
        font-weight: 500;
    }

    .video-controls {
        display: flex;
        justify-content: center;
        gap: 15px;
        padding: 15px;
        background: #334155;
        border-radius: 8px;
    }

    .video-control-btn {
        padding: 12px 24px;
        border: none;
        border-radius: 6px;
        font-size: 15px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 8px;
        background: #dc2626;
        color: white;
    }

    .video-control-btn:hover {
        background: #b91c1c;
    }

    .connection-status {
        text-align: center;
        padding: 10px;
        background: #334155;
        border-radius: 6px;
        color: #e2e8f0;
        font-size: 14px;
    }

    .connection-status.connected {
        background: #10b981;
        color: white;
    }

    .connection-status.disconnected {
        background: #64748b;
        color: white;
    }

    .connection-status.connecting {
        background: #f59e0b;
        color: white;
    }
</style>

<script>
    let inquiryPage = {
        custId: null,
        activeRoomId: null,
        stompClient: null,
        isConnected: false,
        rtcConnection: null,
        rtcSocket: null,
        localStream: null,

        init: function() {
            this.custId = '${sessionScope.cust}';

            if (!this.custId || this.custId === '') {
                this.custId = 'guest_' + Math.floor(Math.random() * 10000);
                console.log('⚠️ 세션 없음, 임시 ID 생성:', this.custId);
            }

            console.log('👤 현재 사용자 ID:', this.custId);

            this.bindEvents();
            this.updateConnectionStatus(false);
            this.connectWebSocket();
            this.checkActiveRoom();
        },

        getCurrentLocation: function() {
            if (!navigator.geolocation) {
                console.warn('⚠️ Geolocation API를 지원하지 않는 브라우저입니다.');
                return;
            }

            navigator.geolocation.getCurrentPosition(
                    (position) => {
                        const lat = position.coords.latitude;
                        const lng = position.coords.longitude;
                        console.log('📍 현재 위치:', lat, lng);

                        if (this.activeRoomId) {
                            this.sendLocation(lat, lng);
                        }
                    },
                    (error) => {
                        console.error('❌ 위치 정보 수집 실패:', error.message);
                    },
                    {
                        enableHighAccuracy: true,
                        timeout: 5000,
                        maximumAge: 0
                    }
            );
        },

        sendLocation: function(latitude, longitude) {
            $.ajax({
                url: 'https://10.20.34.124:8443/api/chatroom/' + this.activeRoomId + '/location',
                type: 'POST',
                data: {
                    latitude: latitude,
                    longitude: longitude
                },
                success: (response) => {
                    console.log('✅ 위치 정보 전송 성공:', response);
                },
                error: (xhr) => {
                    console.error('❌ 위치 정보 전송 실패:', xhr.responseText);
                }
            });
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

            // ⭐ 영상통화 버튼 - 바로 시작
            $('#videoCallBtn').click(() => {
                this.startVideoCall();
            });

            // ⭐ 모달 닫기
            $('#closeVideoModal').click(() => {
                this.closeVideoModal();
            });

            // ⭐ 통화 종료
            $('#endCallBtn').click(() => {
                this.endVideoCall();
            });
        },

        checkActiveRoom: function() {
            $.ajax({
                url: 'https://10.20.34.124:8443/api/chatroom/active/' + this.custId,
                type: 'GET',
                dataType: 'json',
                success: (data) => {
                    if (data && data.roomId) {
                        console.log('✅ 활성 채팅방 존재:', data);
                        this.activeRoomId = data.roomId;
                        this.showActiveRoomStatus(data);
                        $('#videoCallBtn').prop('disabled', false);
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
                    this.getCurrentLocation();

                    // ⭐ 일반 채팅 메시지 구독
                    this.stompClient.subscribe('/adminsend/to/' + this.custId, (message) => {
                        const payload = JSON.parse(message.body);

                        if (payload.content1 === '__CHAT_CLOSED__') {
                            this.handleChatClosed();
                        } else if (payload.content1 === '__VIDEO_CALL_START__') {
                            // ⭐ Admin이 영상통화 시작 신호를 보냄
                            console.log('📞 Admin이 영상통화를 시작했습니다!');
                            this.receiveVideoCallStart();
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
            this.appendMessage('admin', '⚠️ 상담사가 채팅을 종료했습니다. 감사합니다!');

            $('#chatConnection').text('상담 종료됨').removeClass('text-success').addClass('text-warning');
            $('#sendChatBtn').prop('disabled', true);
            $('#chatMessage').prop('disabled', true);
            $('#videoCallBtn').prop('disabled', true);

            if (this.stompClient) {
                this.stompClient.disconnect();
                this.stompClient = null;
            }

            this.isConnected = false;
            this.activeRoomId = null;

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
                content1: message,
                roomId: this.activeRoomId
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
                url: 'https://10.20.34.124:8443/api/chatroom/create',
                type: 'POST',
                data: { custId: this.custId },
                success: (response) => {
                    console.log('✅ 채팅방 생성 성공:', response);

                    $('#statusMessage').html(
                            '<div class="alert alert-success">' +
                            '<i class="fas fa-check-circle"></i> ' +
                            '채팅방이 생성되었습니다! 상담사가 곧 연결됩니다.' +
                            '</div>'
                    );

                    setTimeout(() => {
                        this.checkActiveRoom();
                    }, 1000);
                },
                error: (xhr) => {
                    console.error('❌ 채팅방 생성 실패:', xhr);
                    $('#statusMessage').html(
                            '<div class="alert alert-danger">' +
                            '<i class="fas fa-exclamation-circle"></i> ' +
                            '채팅방 생성에 실패했습니다. 다시 시도해주세요.' +
                            '</div>'
                    );
                    $('#startChatBtn').prop('disabled', false).html('<i class="fas fa-comments"></i> 상담 시작하기');
                }
            });
        },

        showReadyStatus: function() {
            $('#chatStatus').html(
                    '<div class="chat-status">' +
                    '<div class="status-icon">💬</div>' +
                    '<div class="status-message">상담 준비 완료</div>' +
                    '<div class="status-detail">아래 버튼을 클릭하여 상담을 시작하세요</div>' +
                    '</div>' +
                    '<button id="startChatBtn" class="btn-start-chat" onclick="inquiryPage.createChatRoom()">' +
                    '<i class="fas fa-comments"></i> 상담 시작하기' +
                    '</button>'
            );
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
        },

        // ⭐ User가 영상통화 시작 (Admin에게 알림 전송)
        startVideoCall: function() {
            if (!this.activeRoomId) {
                alert('먼저 채팅방을 생성해주세요.');
                return;
            }

            console.log('📞 User가 영상통화를 시작합니다...');

            // ⭐ Admin에게 영상통화 시작 신호 전송
            if (this.stompClient && this.isConnected) {
                const payload = {
                    sendid: this.custId,
                    receiveid: 'admin',
                    content1: '__VIDEO_CALL_START__',
                    roomId: this.activeRoomId
                };
                this.stompClient.send('/receiveto', {}, JSON.stringify(payload));
            }

            // 모달 열고 자동으로 통화 시작
            $('#videoModal').fadeIn(300);
            this.initializeVideoCall();
        },

        // ⭐ Admin이 영상통화를 시작했을 때 (수신)
        receiveVideoCallStart: function() {
            console.log('📞 Admin의 영상통화 요청을 받았습니다!');

            // 모달 자동 열림
            $('#videoModal').fadeIn(300);

            // 자동으로 통화 시작
            this.initializeVideoCall();
        },

        // ⭐ 실제 영상통화 초기화 (WebRTC)
        initializeVideoCall: function() {
            $('#videoConnectionStatus').removeClass('disconnected').addClass('connecting').text('연결 중...');

            navigator.mediaDevices.getUserMedia({ video: true, audio: true })
                    .then((stream) => {
                        this.localStream = stream;
                        document.getElementById('localVideo').srcObject = stream;
                        this.setupWebRTC();
                    })
                    .catch((error) => {
                        console.error('❌ 미디어 접근 실패:', error);
                        alert('카메라/마이크 접근 권한이 필요합니다. 브라우저 설정을 확인해주세요.');
                        $('#videoConnectionStatus').removeClass('connecting').addClass('disconnected').text('연결 실패');
                    });
        },

        setupWebRTC: function() {
            this.rtcSocket = new WebSocket('wss://10.20.34.124:8443/signal');

            this.rtcSocket.onopen = () => {
                console.log('✅ Signaling Server 연결');

                this.rtcSocket.send(JSON.stringify({
                    type: 'join',
                    roomId: this.activeRoomId.toString(),
                    custId: this.custId
                }));
            };

            this.rtcSocket.onmessage = (event) => {
                const message = JSON.parse(event.data);
                this.handleSignalingMessage(message);
            };

            this.rtcSocket.onerror = (error) => {
                console.error('❌ Signaling 오류:', error);
                $('#videoConnectionStatus').removeClass('connecting').addClass('disconnected').text('연결 실패');
            };

            this.rtcSocket.onclose = (event) => {
                console.log('ℹ️ Signaling WebSocket 연결 종료');
            };

            const configuration = {
                iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
            };

            this.rtcConnection = new RTCPeerConnection(configuration);

            this.localStream.getTracks().forEach(track => {
                this.rtcConnection.addTrack(track, this.localStream);
            });

            this.rtcConnection.onconnectionstatechange = () => {
                console.log('🔄 RTC 연결 상태:', this.rtcConnection.connectionState);

                switch (this.rtcConnection.connectionState) {
                    case 'connected':
                        $('#videoConnectionStatus').removeClass('connecting disconnected').addClass('connected').text('통화 연결됨');
                        break;
                    case 'disconnected':
                        $('#videoConnectionStatus').removeClass('connecting connected').addClass('disconnected').text('연결 끊김');
                        break;
                    case 'failed':
                        $('#videoConnectionStatus').removeClass('connecting connected').addClass('disconnected').text('연결 실패');
                        break;
                    case 'closed':
                        $('#videoConnectionStatus').removeClass('connecting connected').addClass('disconnected').text('연결 종료됨');
                        break;
                }
            };

            this.rtcConnection.ontrack = (event) => {
                console.log('📹 원격 스트림 수신');
                const remoteVideo = document.getElementById('remoteVideo');
                remoteVideo.srcObject = event.streams[0];
                remoteVideo.play().catch(err => console.warn('⚠️ 원격 영상 자동재생 실패:', err));
            };

            this.rtcConnection.onicecandidate = (event) => {
                if (event.candidate && this.rtcSocket && this.rtcSocket.readyState === WebSocket.OPEN) {
                    this.rtcSocket.send(JSON.stringify({
                        type: 'ice-candidate',
                        roomId: this.activeRoomId.toString(),
                        data: event.candidate
                    }));
                }
            };
        },

        handleSignalingMessage: function(message) {
            console.log('📨 Signaling 메시지:', message.type);

            switch (message.type) {
                case 'offer':
                    const offer = message.offer || message.data;
                    if (!offer) return;

                    this.rtcConnection.setRemoteDescription(new RTCSessionDescription(offer))
                            .then(() => this.rtcConnection.createAnswer())
                            .then(answer => this.rtcConnection.setLocalDescription(answer))
                            .then(() => {
                                this.rtcSocket.send(JSON.stringify({
                                    type: 'answer',
                                    roomId: this.activeRoomId.toString(),
                                    data: this.rtcConnection.localDescription
                                }));
                            });
                    break;

                case 'answer':
                    const answer = message.answer || message.data;
                    if (!answer) return;

                    this.rtcConnection.setRemoteDescription(new RTCSessionDescription(answer));
                    break;

                case 'ice-candidate':
                    const candidate = message.candidate || message.data;
                    if (!candidate) return;

                    this.rtcConnection.addIceCandidate(new RTCIceCandidate(candidate));
                    break;

                case 'user-joined':
                    // Admin이 먼저 들어왔을 때 User가 Offer 생성
                    this.rtcConnection.createOffer()
                            .then(offer => this.rtcConnection.setLocalDescription(offer))
                            .then(() => {
                                this.rtcSocket.send(JSON.stringify({
                                    type: 'offer',
                                    roomId: this.activeRoomId.toString(),
                                    data: this.rtcConnection.localDescription
                                }));
                            });
                    break;
            }
        },

        closeVideoModal: function() {
            if (confirm('통화를 종료하시겠습니까?')) {
                this.endVideoCall();
                $('#videoModal').fadeOut(300);
            }
        },

        endVideoCall: function() {
            console.log('📴 영상통화 종료');

            if (this.localStream) {
                this.localStream.getTracks().forEach(track => track.stop());
                this.localStream = null;
            }

            if (this.rtcConnection) {
                this.rtcConnection.close();
                this.rtcConnection = null;
            }

            if (this.rtcSocket) {
                this.rtcSocket.close();
                this.rtcSocket = null;
            }

            document.getElementById('localVideo').srcObject = null;
            document.getElementById('remoteVideo').srcObject = null;
            $('#videoConnectionStatus').removeClass('connected connecting').addClass('disconnected').text('연결 대기 중');
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
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <h4>실시간 상담</h4>
                <button id="videoCallBtn" class="btn btn-success btn-sm" disabled>
                    <i class="fas fa-video"></i> 영상 통화
                </button>
            </div>
            <div class="chat-status-indicator">연결 상태: <span id="chatConnection" class="text-danger">연결 대기 중...</span></div>
            <div id="chatMessages" class="chat-messages"></div>
            <div class="chat-input-group">
                <input type="text" id="chatMessage" placeholder="상담사에게 메시지를 입력하세요" disabled>
                <button id="sendChatBtn" disabled>전송</button>
            </div>

            <button id="videoCallBtn" class="btn-video-call" disabled>
                <i class="fas fa-video"></i> 영상 통화 시작
            </button>

            <!-- 영상통화 모달 -->
            <div id="videoModal" class="video-modal">
                <div class="video-modal-content">
                    <div class="video-modal-header">
                        <h3><i class="fas fa-video"></i> 영상 상담</h3>
                        <button class="video-modal-close" id="closeVideoModal">&times;</button>
                    </div>
                    <div class="video-modal-body">
                        <div class="video-container">
                            <div class="video-wrapper">
                                <video id="localVideo" autoplay playsinline muted class="video-stream"></video>
                                <div class="video-label">내 화면</div>
                            </div>
                            <div class="video-wrapper">
                                <video id="remoteVideo" autoplay playsinline class="video-stream"></video>
                                <div class="video-label">상담사 화면</div>
                            </div>
                        </div>
                        <div class="video-controls">
                            <button id="endCallBtn" class="video-control-btn">
                                <i class="fas fa-phone-slash"></i> 통화 종료
                            </button>
                        </div>
                        <div id="videoConnectionStatus" class="connection-status disconnected">
                            연결 대기 중
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>