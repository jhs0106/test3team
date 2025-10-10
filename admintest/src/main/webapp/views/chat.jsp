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
      this.stompClient.connect({}, function(frame) {
        console.log('Connected: ' + frame);
        this.subscribe('/adminsend/to/'+sid, function(msg) {
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

<!-- Begin Page Content -->
<div class="container-fluid">

  <!-- Page Heading -->
  <div class="d-sm-flex align-items-center justify-content-between mb-4">
    <h1 class="h3 mb-0 text-gray-800">Chat</h1>
  </div>

  <!-- Content Row -->
  <div class="row">
    <!-- Line Chart -->
    <div class="col-xl-8 col-lg-7">
      <div class="card shadow mb-4">
        <!-- Card Header - Dropdown -->
        <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
          <h6 class="m-0 font-weight-bold text-primary">Earnings Overview</h6>
        </div>
        <!-- Card Body -->
        <div class="card-body">
          <div class="table-responsive">
            <div class="col-sm-5">
              <h1 id="user_id">${sessionScope.admin.adminId}</h1>
              <H1 id="status">Status</H1>

              <h3>To</h3>
              <input type="text" id="target" value="id00">
              <input type="text" id="totext"><button id="sendto">Send</button>
              <div id="to"></div>

            </div>
          </div>
        </div>
      </div>
    </div>
  </div>


</div>