<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- ⭐ Kakao Map SDK를 제일 먼저 로드 -->
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=YOUR_KAKAO_API_KEY"></script>

<style>
    .chatroom-detail-wrapper {
        max-width: 720px;
        margin: 0 auto;
    }

    .chatroom-detail-card {
        border-radius: 12px;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.12);
        border: none;
    }

    .chatroom-detail-header {
        background: linear-gradient(135deg, #2563eb 0%, #4f46e5 100%);
        color: #fff;
        padding: 24px;
        border-radius: 12px 12px 0 0;
    }

    .chatroom-detail-header h4 {
        margin: 0;
        font-weight: 700;
    }

    .chatroom-meta {
        display: flex;
        flex-wrap: wrap;
        gap: 12px 24px;
        margin-top: 12px;
        font-size: 14px;
        opacity: 0.9;
    }

    .chatroom-meta span {
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    .badge-status {
        font-size: 13px;
        padding: 6px 12px;
        border-radius: 999px;
    }

    #admin-connection-status {
        font-weight: 600;
    }

    #admin-message-log {
        height: 320px;
        overflow-y: auto;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 16px;
        margin-bottom: 16px;
    }

    .message-entry {
        margin-bottom: 14px;
        line-height: 1.5;
    }

    .message-entry .sender {
        font-weight: 600;
        color: #1d4ed8;
    }

    .message-entry .sender.customer {
        color: #dc2626;
    }

    .message-entry time {
        display: block;
        font-size: 12px;
        color: #6b7280;
        margin-top: 4px;
    }

    .message-input-group {
        display: flex;
        gap: 12px;
    }

    .message-input-group input {
        flex: 1;
        border-radius: 10px;
        border: 1px solid #cbd5f5;
        padding: 12px;
    }

    .message-input-group button {
        padding: 0 24px;
        border-radius: 10px;
    }

    .assign-alert {
        margin-top: 16px;
    }
</style>

<script>
    const adminChatDetail = {
        roomId: '${roomId}',
        custId: '${custId}',
        adminId: '${sessionScope.admin}',
        stompClient: null,
        isConnected: false,
        assignCompleted: false,
        map: null,
        customerMarker: null,

        init() {
            this.cacheElements();
            this.bindEvents();
            this.renderInitialInfo();

            // ⭐ Kakao Maps SDK 로딩 확인 후 지도 초기화
            this.waitForKakao(() => {
                this.initMap();
            });

            if (!this.adminId) {
                this.appendSystemMessage('관리자 로그인이 필요합니다.');
                this.disableInputs(true);
                return;
            }

            this.assignRoom();
            this.connectWebSocket();
        },

        // ⭐ Kakao SDK 로딩 대기 함수
        waitForKakao(callback) {
            if (typeof kakao !== 'undefined' && kakao.maps) {
                callback();
            } else {
                setTimeout(() => this.waitForKakao(callback), 100);
            }
        },

        initMap: function() {
            const container = document.getElementById('customer-map');
            if (!container) {
                console.error('❌ 지도 컨테이너를 찾을 수 없습니다.');
                return;
            }

            const options = {
                center: new kakao.maps.LatLng(37.5665, 126.9780), // 서울 시청 기본값
                level: 3
            };

            this.map = new kakao.maps.Map(container, options);

            // 고객 위치 마커
            this.customerMarker = new kakao.maps.Marker({
                map: this.map
            });

            console.log('✅ Kakao Map 초기화 완료');
            this.loadCustomerLocation();
        },

        loadCustomerLocation: function() {
            $.ajax({
                url: 'https://192.168.45.176:8443/api/chatroom/' + this.roomId,
                type: 'GET',
                success: (room) => {
                    if (room.latitude && room.longitude) {
                        this.updateMapLocation(room.latitude, room.longitude);
                    } else {
                        console.log('ℹ️ 고객 위치 정보 없음');
                    }
                },
                error: (xhr) => {
                    console.error('❌ 채팅방 정보 조회 실패:', xhr.responseText);
                }
            });
        },

        updateMapLocation: function(lat, lng) {
            if (!this.map || !this.customerMarker) {
                console.warn('⚠️ 지도가 아직 초기화되지 않았습니다.');
                return;
            }

            const position = new kakao.maps.LatLng(lat, lng);

            // 지도 중심 이동
            this.map.setCenter(position);

            // 마커 위치 업데이트
            this.customerMarker.setPosition(position);

            // 좌표 표시
            $('#map-latitude').text(lat.toFixed(6));
            $('#map-longitude').text(lng.toFixed(6));

            console.log('📍 고객 위치 업데이트:', lat, lng);
        },

        cacheElements() {
            this.$log = $('#admin-message-log');
            this.$messageInput = $('#admin-chat-message');
            this.$sendBtn = $('#admin-send-btn');
            this.$closeBtn = $('#close-chat-btn');
            this.$connection = $('#admin-connection-status');
            this.$assignStatus = $('#assign-status');
        },

        bindEvents() {
            this.$sendBtn.click(() => this.sendMessage());
            this.$closeBtn.click(() => this.closeChat());
            this.$messageInput.on('keypress', (e) => {
                if (e.which === 13) {
                    e.preventDefault();
                    this.sendMessage();
                }
            });
        },

        renderInitialInfo() {
            $('#detail-room-id').text(this.roomId);
            $('#detail-cust-id').text(this.custId);
            $('#detail-admin-id').text(this.adminId || '-');
        },

        assignRoom() {
            const adminId = this.adminId;
            if (!adminId) {
                return;
            }
            $.ajax({
                url: 'https://192.168.45.176:8443/api/chatroom/' + this.roomId + '/assign',
                type: 'POST',
                data: { adminId },
                success: (response) => {
                    this.assignCompleted = true;
                    $('#detail-admin-id').text(adminId);
                    this.$assignStatus
                        .removeClass('badge-secondary badge-danger')
                        .addClass('badge-success')
                        .text('상담 진행 중');
                    this.appendSystemMessage('채팅방이 배정되었습니다. 고객과의 상담을 시작하세요.');
                    this.disableInputs(!(this.isConnected && this.assignCompleted));
                },
                error: (xhr) => {
                    let message = '채팅방 배정에 실패했습니다.';
                    if (xhr.status === 409) {
                        message = '이미 다른 관리자가 배정된 채팅방입니다.';
                        this.fetchRoomInfo();
                    }
                    this.$assignStatus
                        .removeClass('badge-success badge-secondary')
                        .addClass('badge-danger')
                        .text('배정 실패');
                    this.appendSystemMessage(message);
                    this.disableInputs(true);
                }
            });
        },

        fetchRoomInfo() {
            $.ajax({
                url: 'https://192.168.45.176:8443/api/chatroom/active/' + this.custId,
                type: 'GET',
                dataType: 'json',
                success: (data) => {
                    if (data && data.adminId) {
                        $('#detail-admin-id').text(data.adminId);
                        this.appendSystemMessage('현재 상담사는 ' + data.adminId + ' 입니다.');
                        if (data.adminId === this.adminId) {
                            this.assignCompleted = true;
                            this.$assignStatus
                                .removeClass('badge-secondary badge-danger')
                                .addClass('badge-success')
                                .text('상담 진행 중');
                            this.disableInputs(!(this.isConnected && this.assignCompleted));
                        }
                    }
                }
            });
        },

        connectWebSocket() {
            if (!this.adminId) {
                return;
            }
            const socket = new SockJS('${wsurl}adminchat');
            this.stompClient = Stomp.over(socket);
            this.$connection.text('연결 중...').removeClass('text-danger').addClass('text-warning');
            this.stompClient.connect({}, (frame) => {
                console.log('Admin connected:', frame);
                this.isConnected = true;
                this.$connection.text('연결 완료').removeClass('text-warning text-danger').addClass('text-success');
                this.disableInputs(!(this.assignCompleted));
                this.appendSystemMessage('WebSocket 연결이 완료되었습니다.');

                this.stompClient.subscribe('/send/to/' + this.adminId, (msg) => {
                    try {
                        const payload = JSON.parse(msg.body);
                        this.appendMessage(payload.sendid || '고객', payload.content1, 'customer');
                    } catch (error) {
                        console.error('메시지 파싱 오류', error);
                    }
                });
            }, () => {
                this.isConnected = false;
                this.$connection.text('연결 실패').removeClass('text-warning text-success').addClass('text-danger');
                this.disableInputs(true);
                this.stompClient = null;
            });

            socket.onclose = () => {
                this.isConnected = false;
                this.$connection.text('연결 종료').removeClass('text-success text-warning').addClass('text-danger');
                this.disableInputs(true);
                this.stompClient = null;
                this.appendSystemMessage('WebSocket 연결이 종료되었습니다. 새로고침 후 다시 시도해주세요.');
            };
        },

        disableInputs(disabled) {
            this.$messageInput.prop('disabled', disabled);
            this.$sendBtn.prop('disabled', disabled);
            this.$closeBtn.prop('disabled', disabled);
        },

        closeChat() {
            if (!confirm('상담을 종료하시겠습니까?\n종료 후에는 다시 시작할 수 없습니다.')) {
                return;
            }

            $.ajax({
                url: 'https://192.168.45.176:8443/api/chatroom/' + this.roomId + '/close',
                type: 'POST',
                success: (response) => {
                    this.appendSystemMessage('✅ 상담이 종료되었습니다.');
                    this.$assignStatus
                        .removeClass('badge-success badge-secondary badge-danger')
                        .addClass('badge-dark')
                        .text('종료됨');
                    this.disableInputs(true);

                    // WebSocket으로 종료 알림 전송
                    if (this.stompClient && this.isConnected) {
                        const closePayload = {
                            sendid: this.adminId,
                            receiveid: this.custId,
                            content1: '__CHAT_CLOSED__',
                            type: 'SYSTEM_CLOSE'
                        };
                        this.stompClient.send('/adminreceiveto', {}, JSON.stringify(closePayload));
                    }

                    // 3초 후 채팅방 리스트로 이동
                    setTimeout(() => {
                        window.location.href = '/chatroom';
                    }, 3000);
                },
                error: (xhr) => {
                    alert('채팅방 종료에 실패했습니다: ' + xhr.responseText);
                }
            });
        },

        sendMessage() {
            if (!this.stompClient || !this.isConnected || !this.assignCompleted) {
                alert('WebSocket 연결 또는 채팅방 배정이 완료되지 않았습니다.');
                return;
            }
            const content = this.$messageInput.val().trim();
            if (!content) {
                return;
            }
            const payload = {
                sendid: this.adminId,
                receiveid: this.custId,
                content1: content
            };
            this.stompClient.send('/adminreceiveto', {}, JSON.stringify(payload));
            this.appendMessage('나', content, 'admin');
            this.$messageInput.val('');
            this.$messageInput.focus();
        },

        appendMessage(sender, message, type) {
            const sanitized = $('<div>').text(message).html();
            const time = new Date().toLocaleTimeString('ko-KR', { hour12: false });
            const entry = [
                '<div class="message-entry">',
                '<div class="sender ' + (type || 'admin') + '">[' + time + '] ' + sender + '</div>',
                '<div class="body">' + sanitized + '</div>',
                '</div>'
            ].join('');
            this.$log.append(entry);
            this.$log.scrollTop(this.$log[0].scrollHeight);
        },

        appendSystemMessage(message) {
            const time = new Date().toLocaleTimeString('ko-KR', { hour12: false });
            this.$log.append(
                '<div class="message-entry">' +
                '<div class="sender">[' + time + '] 시스템</div>' +
                '<div class="body">' + $('<div>').text(message).html() + '</div>' +
                '</div>'
            );
            this.$log.scrollTop(this.$log[0].scrollHeight);
        }
    };

    $(function() {
        adminChatDetail.init();
    });
</script>

<div class="chatroom-detail-wrapper">
    <div class="card chatroom-detail-card">
        <div class="chatroom-detail-header">
            <h4>실시간 상담</h4>
            <div class="chatroom-meta">
                <span><i class="fas fa-hashtag"></i> 방 번호: <strong id="detail-room-id"></strong></span>
                <span><i class="fas fa-user"></i> 고객 ID: <strong id="detail-cust-id"></strong></span>
                <span><i class="fas fa-user-shield"></i> 담당자: <strong id="detail-admin-id"></strong></span>
                <span class="badge badge-secondary badge-status" id="assign-status">배정 중...</span>
            </div>
        </div>
        <div class="card-body">
            <!-- 지도 영역 -->
            <div class="card mb-3">
                <div class="card-header bg-info text-white">
                    <i class="fas fa-map-marker-alt"></i> 고객 위치 정보
                </div>
                <div class="card-body p-0">
                    <div id="customer-map" style="width:100%; height:300px;"></div>
                    <div class="p-3">
                        <small class="text-muted">
                            <i class="fas fa-info-circle"></i>
                            위도: <span id="map-latitude">-</span>,
                            경도: <span id="map-longitude">-</span>
                        </small>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <span class="text-muted">WebSocket 상태:</span>
                    <span id="admin-connection-status" class="text-danger">연결 대기</span>
                </div>
                <div class="text-muted">고객에게서 온 메시지는 아래에 표시됩니다.</div>
            </div>

            <div id="admin-message-log"></div>

            <div class="d-flex justify-content-end mb-3">
                <button id="close-chat-btn" class="btn btn-danger btn-sm" disabled>
                    <i class="fas fa-times-circle"></i> 상담 종료
                </button>
            </div>

            <div class="message-input-group">
                <input type="text" id="admin-chat-message" placeholder="메시지를 입력하세요" disabled>
                <button id="admin-send-btn" class="btn btn-primary" disabled>전송</button>
            </div>

            <div class="alert alert-info assign-alert" role="alert">
                채팅방에 입장하면 자동으로 상담사로 배정되며, 고객과의 메시지가 실시간으로 표시됩니다.
            </div>
        </div>
    </div>
</div>