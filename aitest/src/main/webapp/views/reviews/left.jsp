<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="col-sm-2">
  <h5 class="font-weight-bold">사람다움 케어 여정</h5>
  <ol class="pl-3 small">
    <li>별점과 함께 케어 후기를 기록합니다.</li>
    <li>AI 코치가 후기에 맞춘 응답과 케어 제안을 전달합니다.</li>
    <li>필요 시 상담 쪽에서 더욱 자세한 케어가 가능합니다.</li>
  </ol>
  <hr>
  <p class="small text-muted mb-1">바로가기</p>
  <ul class="nav nav-pills flex-column small">
    <c:choose>
      <c:when test="${empty sessionScope.loginMember}">
        <li class="nav-item">
          <a class="nav-link" href="<c:url value='/register'/>">회원 가입</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="<c:url value='/login'/>">로그인</a>
        </li>
      </c:when>
      <c:otherwise>
        <li class="nav-item">
          <a class="nav-link" href="<c:url value='/logout'/>">로그아웃</a>
        </li>
      </c:otherwise>
    </c:choose>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value='/reviews'/>">리뷰 작성 홈</a>
    </li>
  </ul>
</div>