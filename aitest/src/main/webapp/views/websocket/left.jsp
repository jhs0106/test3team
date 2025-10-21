<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="col-sm-2">
  <p>Chat Left Menu</p>
  <ul class="nav nav-pills flex-column">
    <li class="nav-item">
      <a class="nav-link" href="<c:url value ="/websocket/audio"/>">Audio</a>
      <a class="nav-link" href="<c:url value ="/websocket/video"/>">Video</a>
      <a class="nav-link" href="<c:url value='/websocket/inquiry'/>">Inquiry</a>
      <a class="nav-link" href="<c:url value='/websocket/aichat'/>">Aichat</a>
    </li>
  </ul>
  <hr class="d-sm-none">
</div>