<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="col-sm-2">
  <p>Left Menu</p>
  <ul class="nav nav-pills flex-column">
    <li class="nav-item">
      <a class="nav-link" href="<c:url value ="/audio"/>">Audio</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value ="/pic"/>">Pic</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value ="/wt1"/>">Weather1</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value ="/wt2"/>">Weather2</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value ="/wt3"/>">Weather3</a>
    </li>
  </ul>
  <hr class="d-sm-none">
</div>