<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    let websocket = {
        id: '${sessionScope.cust}',
        stompClient: null,
        init: function() {
            $('#connectBtn').click(() => {
                this.connect();
            });
            $('#disconnectBtn').click(() => {
                this.disconnect();
            });
            $('#sendToAdminBtn').click(() => {  // 버튼 ID 변경
                this.sendToAdmin();
            });
        },
        connect: function() {
            let socket = new SockJS('${websocketurl}adminchat');
            this.stompClient = Stomp.over(socket);

            this.stompClient.connect({}, (frame) => {
                console.log('Connected: ' + frame);

                // 나에게 오는 개인 메시지 구독
                this.stompClient.subscribe('/adminsend/to/' + this.id, (message) => {
                    let msg = JSON.parse(message.body);
                    $('#messages').prepend('<p><strong>[' + msg.sendid + ']:</strong> ' + msg.content1 + '</p>');
                });
            });
        },
        disconnect: function() {
            if (this.stompClient !== null) {
                this.stompClient.disconnect();
            }
            console.log("Disconnected");
        },
        sendToAdmin: function() {
            let msg = {
                sendid: this.id,        // cust
                receiveid: 'admin',     // 받는 사람: admin
                content1: $('#messageInput').val()
            };
            console.log('Sending to admin:', msg);  // 디버깅용
            this.stompClient.send("/adminreceiveto", {}, JSON.stringify(msg));

            // 내가 보낸 메시지도 화면에 표시
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
    <p>현재 사용자: <strong>${sessionScope.cust}</strong></p>

    <button id="connectBtn" class="btn btn-primary">연결</button>
    <button id="disconnectBtn" class="btn btn-danger">종료</button>
    <hr>

    <h4>관리자에게 메시지 보내기</h4>
    <div class="input-group mb-3">
        <input type="text" id="messageInput" class="form-control" placeholder="메시지 입력">
        <button id="sendToAdminBtn" class="btn btn-success">Admin에게 전송</button>
    </div>

    <hr>
    <h4>메시지</h4>
    <div id="messages" style="border: 1px solid #ccc; padding: 10px; height: 400px; overflow-y: auto;"></div>
</div>