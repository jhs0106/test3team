<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="col-sm-10">
  <h2 class="mb-4">사람이 되어보자</h2>
  <c:if test="${not empty loginMessage}">
    <div class="alert alert-info">${loginMessage}</div>
  </c:if>
  <form action="<c:url value='/login'/>" method="post" class="card p-4 shadow-sm">
    <div class="form-group">
      <label for="loginId">아이디</label>
      <input type="text" name="loginId" id="loginId" class="form-control" placeholder="회원 아이디를 입력하세요"
             value="${loginMember.loginId}" />
    </div>
    <div class="form-group">
      <label for="password">비밀번호</label>
      <input type="password" name="password" id="password" class="form-control" placeholder="비밀번호를 입력하세요"
             value="${loginMember.password}" />
    </div>
    <c:if test="${not empty org.springframework.validation.BindingResult.loginMember}">
      <div class="alert alert-danger">
        <c:forEach var="error" items="${org.springframework.validation.BindingResult.loginMember.allErrors}">
          <div>${error.defaultMessage}</div>
        </c:forEach>
      </div>
    </c:if>
    <div class="d-flex justify-content-between align-items-center">
      <button type="submit" class="btn btn-primary">로그인</button>
      <a href="<c:url value='/register'/>" class="btn btn-link">회원가입</a>
    </div>
  </form>
</div>
