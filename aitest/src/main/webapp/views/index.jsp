<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Bootstrap 4 Website Example</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.19/index.global.min.js'></script>

    <script src="https://cdn.jsdelivr.net/npm/lamejs@1.2.0/lame.min.js"></script>
    <link href="<c:url value="/css/springai.css"/>" rel="stylesheet" />
    <script src="<c:url value="/js/springai.js"/>"></script>
    <style>
        .fakeimg {
            height: 200px;
            background: #aaa;
        }
    </style>



    <script>
        let index = {
            init:function(){
                //this.startQuestion();
                //this.startVoice();
            },
            startVoice: async function(){
                const audioPlayer = document.getElementById("mainAudioPlayer");
                await audioPlayer.play();
            },
            startQuestion:function(){
                springai.voice.initMic(this);
                $('#mainSpinner').css('visibility','hidden');
            },
            handleVoice: async function(mp3Blob){

                //스피너 보여주기
                $('#mainSpinner').css('visibility','visible');

                // 멀티파트 폼 구성
                const formData = new FormData();
                formData.append("speech", mp3Blob, 'speech.mp3');

                // 녹화된 음성을 텍스트로 변환 요청
                const response = await fetch("/ai3/stt2", {
                    method: "post",
                    headers: {
                        'Accept': 'text/plain'
                    },
                    body: formData
                });

                // 텍스트 질문을 채팅 패널에 보여주기
                const target = await response.text();
                console.log('Handle:'+target);
                location.href=target;

                //
                // $.ajax({
                //     url:'/ai3/target',
                //     data:{'questionText':questionText},
                //     success:(target)=>{
                //         location.href=target;
                //     }
                // });
            }
        }

        $((()=>{
            index.init();
        }));

    </script>



</head>
<body>
<audio id="mainAudioPlayer" src="<c:url value="/mp3/start.mp3"/>" controls style="display:none;"></audio>

<div class="jumbotron text-center" style="margin-bottom:0">
    <h1>SpringAI System</h1>
</div>
<ul class="nav justify-content-end">
    <li class="nav-item">
        <a class="nav-link" href="#">LOGIN</a>
    </li>
    <li class="nav-item">
        <a class="nav-link" href="#">REGISTER</a>
    </li>
    <li class="nav-item">
        <button class="btn btn-primary" disabled >
            <span class="spinner-border spinner-border-sm" id="mainSpinner"></span>
        </button>
    </li>

</ul>
<nav class="navbar navbar-expand-sm bg-dark navbar-dark">
    <a class="navbar-brand" href="<c:url value="/"/>">Home</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#collapsibleNavbar">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="collapsibleNavbar">
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="<c:url value="/springai1"/>">SrpingAi1</a>
            </li>
        </ul>
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="<c:url value="/springai2"/>">SrpingAi2</a>
            </li>
        </ul>
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="<c:url value="/springai3"/>">SrpingAi3</a>
            </li>
        </ul>
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="<c:url value="/springai4"/>">SrpingAi4</a>
            </li>
        </ul>
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link" href="<c:url value="/springai5"/>">SrpingAi5</a>
            </li>
        </ul>
    </div>
</nav>
<div class="container" style="margin-top:30px; margin-bottom: 30px;">
    <div class="row">
        <%-- Left Menu Start ........  --%>
        <c:choose>
            <c:when test="${left == null}">
                <jsp:include page="left.jsp"/>
            </c:when>
            <c:otherwise>
                <jsp:include page="${left}.jsp"/>
            </c:otherwise>
        </c:choose>

        <%-- Left Menu End ........  --%>
        <c:choose>
            <c:when test="${center == null}">
                <jsp:include page="center.jsp"/>
            </c:when>
            <c:otherwise>
                <jsp:include page="${center}.jsp"/>
            </c:otherwise>
        </c:choose>
        <%-- Center Start ........  --%>

        <%-- Center End ........  --%>
    </div>
</div>

<div class="text-center" style="background-color:black; color: white; margin-bottom:0; max-height: 50px;">
    <p>Footer</p>
</div>

</body>
</html>