<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="col-sm-2 sidenav">
    <h4>AI Schedule</h4>
    <ul class="nav nav-pills flex-column">
        <li class="nav-item">
            <a class="nav-link" href="<c:url value="/springai1/schedule"/>">일정 관리</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="<c:url value="/springai1/ai2"/>">습관 트래커</a>
        </li>
    </ul>
    <hr class="d-sm-none">
</div>