<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="col-sm-10">
  <h2 class="mb-4">결정사 회원 가입</h2>
  <c:if test="${not empty registerMessage}">
    <div class="alert alert-success">${registerMessage}</div>
  </c:if>
  <form action="<c:url value='/register'/>" method="post" class="card p-4 shadow-sm">
    <div class="form-row">
      <div class="form-group col-md-6">
        <label for="loginId">아이디</label>
        <input type="text" name="loginId" id="loginId" class="form-control" placeholder="로그인에 사용할 아이디"
               value="${registerMember.loginId}" />
      </div>
      <div class="form-group col-md-6">
        <label for="password">비밀번호</label>
        <input type="password" name="password" id="password" class="form-control" placeholder="파일럿 버전이므로 간단히 입력"
               value="${registerMember.password}" />
      </div>
    </div>
    <div class="form-row">
      <div class="form-group col-md-4">
        <label for="name">이름</label>
        <input type="text" name="name" id="name" class="form-control" placeholder="홍길동"
               value="${registerMember.name}" />
      </div>
      <div class="form-group col-md-4">
        <label for="birthDate">생년월일</label>
        <input type="date" name="birthDate" id="birthDate" class="form-control"
               value="${registerMember.birthDate}" />
      </div>
      <div class="form-group col-md-4">
        <label class="d-block">성별</label>
        <div class="form-check form-check-inline">
          <input class="form-check-input" type="radio" name="gender" id="genderMale" value="남성"
          ${registerMember.gender == '남성' ? 'checked' : ''}>
          <label class="form-check-label" for="genderMale">남성</label>
        </div>
        <div class="form-check form-check-inline">
          <input class="form-check-input" type="radio" name="gender" id="genderFemale" value="여성"
          ${registerMember.gender == '여성' ? 'checked' : ''}>
          <label class="form-check-label" for="genderFemale">여성</label>
        </div>
        <div class="form-check form-check-inline">
          <input class="form-check-input" type="radio" name="gender" id="genderOther" value="기타"
          ${registerMember.gender == '기타' ? 'checked' : ''}>
          <label class="form-check-label" for="genderOther">기타</label>
        </div>
      </div>
    </div>
    <div class="form-group">
      <label for="address">주소</label>
      <input type="text" name="address" id="address" class="form-control" placeholder="서울시 강남구"
             value="${registerMember.address}" />
    </div>
    <div class="form-row">
      <div class="form-group col-md-6">
        <label for="assetStatus">자산 규모</label>
        <input type="text" name="assetStatus" id="assetStatus" class="form-control" placeholder="예: 5억대, 1억~3억 등"
               value="${registerMember.assetStatus}" />
      </div>
      <div class="form-group col-md-6">
        <label for="phoneNumber">전화번호</label>
        <input type="text" name="phoneNumber" id="phoneNumber" class="form-control" placeholder="010-0000-0000"
               value="${registerMember.phoneNumber}" />
      </div>
    </div>
    <div class="form-group">
      <label for="membershipLevel">회원 등급</label>
      <select name="membershipLevel" id="membershipLevel" class="form-control">
        <option value="프리미엄" <c:if test="${registerMember.membershipLevel == '프리미엄'}">selected</c:if>>프리미엄</option>
        <option value="스탠다드" <c:if test="${registerMember.membershipLevel == '스탠다드'}">selected</c:if>>스탠다드</option>
        <option value="라이트" <c:if test="${registerMember.membershipLevel == '라이트'}">selected</c:if>>라이트</option>
      </select>
    </div>
    <c:if test="${not empty org.springframework.validation.BindingResult.registerMember}">
      <div class="alert alert-danger">
        <c:forEach var="error" items="${org.springframework.validation.BindingResult.registerMember.allErrors}">
          <div>${error.defaultMessage}</div>
        </c:forEach>
      </div>
    </c:if>
    <div class="d-flex justify-content-between align-items-center">
      <button type="submit" class="btn btn-success">회원가입 완료</button>
      <a href="<c:url value='/login'/>" class="btn btn-link">로그인 이동</a>
    </div>
  </form>
</div>