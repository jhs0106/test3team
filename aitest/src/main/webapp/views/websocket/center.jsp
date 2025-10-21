<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    let websocket = {
        id: '${sessionScope.cust}',
        stompClient: null,
        init: function() {
            // 초기 UI 상태를 '연결 끊김'으로 설정ddd
            this.updateUiState(false);

            $('#connectBtn').click(() => {
                this.connect();
            });
            $('#disconnectBtn').click(() => {
                this.disconnect();
            });
            $('#sendToAdminBtn').click(() => {
                this.sendToAdmin();
            });
        },
        // UI 상태를 업데이트하는 함수 추가
        updateUiState: function(connected) {
            if (connected) {
                $('#statusIndicator').text('(연결 O)').css('color', 'green');
                $('#connectBtn').prop('disabled', true);
                $('#disconnectBtn').prop('disabled', false);
                $('#messageInput').prop('disabled', false);
                $('#sendToAdminBtn').prop('disabled', false);
            } else {
                $('#statusIndicator').text('(연결 X)').css('color', 'red');
                $('#connectBtn').prop('disabled', false);
                $('#disconnectBtn').prop('disabled', true);
                $('#messageInput').prop('disabled', true);
                $('#sendToAdminBtn').prop('disabled', true);
            }
        },
        connect: function() {
            let socket = new SockJS('${websocketurl}adminchat');
            this.stompClient = Stomp.over(socket);

            this.stompClient.connect({}, (frame) => {
                console.log('Connected: ' + frame);
                this.updateUiState(true); // 연결 성공 시 UI 업데이트

                // 나에게 오는 개인 메시지 구독
                this.stompClient.subscribe('/adminsend/to/' + this.id, (message) => {
                    let msg = JSON.parse(message.body);
                    $('#messages').prepend('<p><strong>[' + msg.sendid + ']:</strong> ' + msg.content1 + '</p>');
                });
            });
        },
        disconnect: function() {
            if (this.stompClient !== null) {
                // disconnect 함수에 콜백을 추가하여 연결이 완전히 끊긴 후 UI를 업데이트합니다.
                this.stompClient.disconnect(() => {
                    this.updateUiState(false); // 연결 종료 시 UI 업데이트
                    console.log("Disconnected");
                });
            }
        },
        sendToAdmin: function() {
            let content = $('#messageInput').val();
            if(content.trim() === '') return; // 빈 메시지 전송 방지

            let msg = {
                sendid: this.id,
                receiveid: 'admin',
                content1: content
            };
            console.log('Sending to admin:', msg);
            this.stompClient.send("/adminreceiveto", {}, JSON.stringify(msg));

            $('#messages').prepend('<p><strong>나 → admin:</strong> ' + msg.content1 + '</p>');
            $('#messageInput').val('');
        }
    };

    $(function() {
        websocket.init();
    });
</script>

<div class="col-sm-10">
    <h2>WebSocket Chat</h2>
    <%-- 연결 상태를 표시할 span 태그 추가 --%>
    <p>현재 사용자: <strong>${sessionScope.cust}</strong> <span id="statusIndicator"></span></p>

    <button id="connectBtn" class="btn btn-primary">연결</button>
    <%-- 초기에는 비활성화되도록 disabled 속성 추가 --%>
    <button id="disconnectBtn" class="btn btn-danger" disabled>종료</button>
    <hr>

    <div class="input-group mb-3">
        <%-- 초기에는 비활성화되도록 disabled 속성 추가 --%>
        <input type="text" id="messageInput" class="form-control" placeholder="메시지 입력" disabled>
        <button id="sendToAdminBtn" class="btn btn-success" disabled>Admin에게 전송</button>
    </div>

    <hr>
    <h4>메시지</h4>
    <div id="messages" style="border: 1px solid #ccc; padding: 10px; height: 400px; overflow-y: auto;"></div>
</div>