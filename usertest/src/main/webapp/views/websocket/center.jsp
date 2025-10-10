<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    let websocket = {
        id: '${sessionScope.cust}', // 테스트용 ID
        stompClient: null,
        init: function() {
            $('#connectBtn').click(() => {
                this.connect();
            });
            $('#disconnectBtn').click(() => {
                this.disconnect();
            });
            $('#sendAllBtn').click(() => {
                this.sendAll();
            });
        },
        connect: function() {
            let socket = new SockJS('${websocketurl}chat');
            this.stompClient = Stomp.over(socket);

            this.stompClient.connect({}, (frame) => {
                console.log('Connected: ' + frame);

                // 전체 메시지 구독
                this.stompClient.subscribe('/send', (message) => {
                    let msg = JSON.parse(message.body);
                    $('#messages').prepend('<p>' + msg.sendid + ': ' + msg.content1 + '</p>');
                });
            });
        },
        disconnect: function() {
            if (this.stompClient !== null) {
                this.stompClient.disconnect();
            }
            console.log("Disconnected");
        },
        sendAll: function() {
            let msg = {
                sendid: this.id,
                content1: $('#messageInput').val()
            };
            this.stompClient.send("/receiveall", {}, JSON.stringify(msg));
            $('#messageInput').val('');
        }
    };

    $(function() {
        websocket.init();
    });
</script>

<div class="col-sm-10">
    <h2>WebSocket Test</h2>

    <button id="connectBtn" class="btn btn-primary">연결</button>
    <button id="disconnectBtn" class="btn btn-danger">종료</button>
    <hr>
    <input type="text" id="messageInput" class="form-control" placeholder="메시지 입력">
    <button id="sendAllBtn" class="btn btn-success mt-2">전체 전송</button>
    <hr>
    <div id="messages" style="border: 1px solid #ccc; padding: 10px; height: 300px; overflow-y: auto;"></div>
</div>