<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="col-sm-10">
  <h2>Diary List</h2>
  <c:if test="${not empty errorMessage}">
    <div class="alert alert-danger" role="alert">${errorMessage}</div>
  </c:if>
  <c:choose>
    <c:when test="${not empty entries}">
      <div class="list-group">
        <c:forEach var="entry" items="${entries}">
          <a href="<c:url value='/diary/view/${entry.diaryId}'/>" class="list-group-item list-group-item-action">
            <div class="d-flex w-100 justify-content-between">
              <h5 class="mb-1">${entry.title}</h5>
              <small>${entry.entryDate}</small>
            </div>
            <p class="mb-1 text-truncate">${entry.content}</p>
          </a>
        </c:forEach>
      </div>
    </c:when>
    <c:otherwise>
      <p class="text-muted">아직 작성된 일기가 없습니다. 오늘의 일기를 작성해보세요!</p>
    </c:otherwise>
  </c:choose>
</div>
