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

    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=YOUR_KEY"></script>

    <%-- Web Socket Lib --%>
    <script src="/webjars/sockjs-client/sockjs.min.js"></script>
    <script src="/webjars/stomp-websocket/stomp.min.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/lamejs@1.2.0/lame.min.js"></script>
    <link href="<c:url value="/css/springai.css"/>" rel="stylesheet" />
    <script src="<c:url value="/js/springai.js"/>"></script>
    <style>
        .fakeimg {
            height: 200px;
            background: #aaa;
        }
    </style>

</head>
<body>

<div class="jumbotron text-center" style="margin-bottom:0">
    <h1>사람다움 케어</h1>
    <p>당신의 일상, 외모, 마음, 습관을 가꿔드립니다</p>
</div>
<ul class="nav justify-content-end">
    <c:choose>
        <c:when test="${not empty sessionScope.loginMember}">
            <li class="nav-item">
                <span class="nav-link">${sessionScope.loginMember.name} 님 (${sessionScope.loginMember.membershipLevel})</span>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/logout'/>">로그아웃</a>
            </li>
        </c:when>
        <c:otherwise>
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/login'/>">LOGIN</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/register'/>">REGISTER</a>
            </li>
        </c:otherwise>
    </c:choose>

</ul>
<c:choose>
    <c:when test="${not empty sessionScope.loginMember}">
        <nav class="navbar navbar-expand-sm bg-dark navbar-dark">
            <a class="navbar-brand" href="<c:url value="/"/>">Home</a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#collapsibleNavbar">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="collapsibleNavbar">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="<c:url value="/springai1"/>">일정</a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="<c:url value="/reviews"/>">리뷰 작성</a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="<c:url value="/appearance"/>">외모 관리</a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="<c:url value="/book"/>">책 추천</a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="<c:url value="/diary"/>">일기 작성</a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="<c:url value="/createimg/createimg1"/>">옷 추천</a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="<c:url value="/websocket"/>">상담</a>
                    </li>
                </ul>
            </div>
        </nav>
    </c:when>
    <c:otherwise>
        <div class="alert alert-light border rounded-0 mb-0 text-center" role="alert">
            사람다움 케어 내비게이션은 로그인 후 이용할 수 있습니다.
        </div>
    </c:otherwise>
</c:choose>
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
    <p></p>
</div>

</body>
</html>
