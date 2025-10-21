<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="col-sm-2">
  <p>Left Menu</p>
  <ul class="nav nav-pills flex-column">
    <li class="nav-item">
      <a class="nav-link" href="<c:url value='/diary/diary'/>">Today's Diary</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value='/diary/diarylist'/>">Diary List</a>
    </li>
  </ul>
  <hr class="d-sm-none">
</div>