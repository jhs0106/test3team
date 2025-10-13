<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
  #to {
    width: 400px;
    height: 200px;
    overflow: auto;
    border: 2px solid black;
  }
</style>

<script>
  chat = {
    id:'',
    init:function(){
      this.id = $('#user_id').text();
      this.connect();
      $('#sendto').click(()=>{
        var msg = JSON.stringify({
          'sendid' : this.id,
          'receiveid' : $('#target').val(),
          'content1' : $('#totext').val()
        });
        this.stompClient.send('/adminreceiveto', {}, msg);
      });
    },
    connect:function(){
      let sid = this.id;
      let socket = new SockJS('${wsurl}adminchat');
      this.stompClient = Stomp.over(socket);
      this.setConnected(true);
      // this.stompClient.connect({}, function(frame) {  // 기존 코드
      // [수정] this가 stompClient를 가리키므로, 외부의 this(chat 객체)를 사용하기 위해 화살표 함수로 변경
      this.stompClient.connect({}, (frame) => {
        console.log('Connected: ' + frame);
        // this.subscribe('/adminsend/to/'+sid, function(msg) { // 기존 코드
        // [수정] this(stompClient)가 아닌 JSP 페이지의 this를 사용하기 위해 화살표 함수로 변경
        this.stompClient.subscribe('/adminsend/to/'+sid, (msg) => {
          $("#to").prepend(
                  "<h4>" + JSON.parse(msg.body).sendid +":"+
                  JSON.parse(msg.body).content1
                  + "</h4>");
        });
      });
    },
    setConnected:function(connected){
      if (connected) {
        $("#status").text("Connected");
      } else {
        $("#status").text("Disconnected");
      }
    }
  }
  $(()=>{
    chat.init();
  })
</script>

<div class="container-fluid">

  <div class="d-sm-flex align-items-center justify-content-between mb-4">
    <h1 class="h3 mb-0 text-gray-800">Chat</h1>
  </div>

  <div class="row">
    <div class="col-xl-8 col-lg-7">
      <div class="card shadow mb-4">
        <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
          <h6 class="m-0 font-weight-bold text-primary">Earnings Overview</h6>
        </div>
        <div class="card-body">
          <div class="table-responsive">
            <div class="col-sm-5">
              <%-- [수정] .adminId를 제거하고 세션 값을 바로 출력합니다. --%>
              <h1 id="user_id">${sessionScope.admin}</h1>
              <H1 id="status">Status</H1>

              <h3>To</h3>
              <input type="text" id="target" value="cust">
              <input type="text" id="totext"><button id="sendto">Send</button>
              <div id="to"></div>

            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

</div>