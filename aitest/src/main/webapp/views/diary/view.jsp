<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="col-sm-10">
  <h2>${entry.title}</h2>
  <p class="text-muted">${entry.entryDate}</p>

  <c:if test="${not empty successMessage}">
    <div class="alert alert-success" role="alert">${successMessage}</div>
  </c:if>

  <div class="card mb-4">
    <div class="card-body">
      <pre class="mb-0" style="white-space: pre-wrap;">${entry.content}</pre>
    </div>
  </div>

  <div class="card border-info">
    <div class="card-header bg-info text-white">AI 코멘트</div>
    <div class="card-body">
      <p class="mb-0">${entry.aiFeedback}</p>
    </div>
  </div>

  <div class="mt-4">
    <a href="<c:url value='/diary/diary'/>">목록으로 돌아가기</a>
  </div>
</div>