<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="col-sm-10">
    <h2>Login</h2>

    <c:if test="${loginfail != null}">
        <div class="alert alert-danger">
                ${msg}
        </div>
    </c:if>

    <form action="<c:url value='/loginimpl'/>" method="post">
        <div class="form-group">
            <label for="id">ID:</label>
            <input type="text" class="form-control" id="id" name="id" value="admin">
        </div>
        <div class="form-group">
            <label for="pwd">Password:</label>
            <input type="password" class="form-control" id="pwd" name="pwd" value="111111">
        </div>
        <button type="submit" class="btn btn-primary">로그인</button>
    </form>
</div>
