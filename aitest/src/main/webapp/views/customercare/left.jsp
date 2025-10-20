<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="col-sm-2">
  <h5 class="font-weight-bold">결정사 케어 단계</h5>
  <ol class="pl-3 small">
    <li>회원 후기를 수집합니다.</li>
    <li>AI가 감정을 분류하고 우선순위를 정합니다.</li>
    <li>담당 매니저가 맞춤 케어 플랜을 실행합니다.</li>
  </ol>
  <hr>
  <p class="small text-muted mb-1">바로가기</p>
  <ul class="nav nav-pills flex-column small">
    <li class="nav-item">
      <a class="nav-link" href="<c:url value='/register'/>">회원 가입</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value='/login'/>">로그인</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value='/customer-care'/>">케어 센터 홈</a>
    </li>
  </ul>
</div