<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- JSTL -->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<%----%>
<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>SB Admin 2 - Dashboard</title>

    <!-- Custom fonts for this template-->
    <link href="<c:url value="/vendor/fontawesome-free/css/all.min.css"/>" rel="stylesheet" type="text/css">
    <link
            href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
            rel="stylesheet">

    <!-- Custom styles for this template-->
    <link href="<c:url value="/css/sb-admin-2.min.css"/>" rel="stylesheet">

    <!-- Custom styles for this page -->
    <link href="<c:url value="/vendor/datatables/dataTables.bootstrap4.min.css"/>" rel="stylesheet">
    <!-- Bootstrap core JavaScript-->
    <script src="/vendor/jquery/jquery.min.js"></script>
    <script src="/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

    <!-- Core plugin JavaScript-->
    <script src="/vendor/jquery-easing/jquery.easing.min.js"></script>

    <%-- Web Socket Lib --%>
    <script src="/webjars/sockjs-client/sockjs.min.js"></script>
    <script src="/webjars/stomp-websocket/stomp.min.js"></script>

    <!-- HighCharts  -->
    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="https://code.highcharts.com/highcharts-3d.js"></script>
    <script src="https://code.highcharts.com/modules/series-label.js"></script>
    <script src="https://code.highcharts.com/modules/data.js"></script>
    <script src="https://code.highcharts.com/modules/drilldown.js"></script>
    <script src="https://code.highcharts.com/modules/cylinder.js"></script>
    <script src="https://code.highcharts.com/modules/wordcloud.js"></script>
    <script src="https://code.highcharts.com/modules/exporting.js"></script>
    <script src="https://code.highcharts.com/modules/export-data.js"></script>
    <script src="https://code.highcharts.com/modules/accessibility.js"></script>
    <script src="https://code.highcharts.com/modules/non-cartesian-zoom.js"></script>
    <script src="https://code.highcharts.com/themes/adaptive.js"></script>

    <script>
        $(function () {
            // 로그인 실패 시 모달 창을 띄우는 로직
            // Controller에서 model에 "loginfail" 이름으로 값을 넘겨주므로, "loginfail"로 체크합니다.
            <c:if test="${loginfail == 'fail'}">
            $('#loginModal').modal('show');
            </c:if>

            // 로그인 버튼 클릭 이벤트
            $('#login_form > button').click(() => {
                $('#login_form').attr({
                    'action': '<c:url value="/loginimpl"/>',
                    'method': 'POST'
                });
                $('#login_form').submit();
            });

            // 검색 관련 JavaScript는 모두 제거되었습니다.
        });
    </script>

</head>

<body id="page-top">

<div id="wrapper">

    <ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">

        <a class="sidebar-brand d-flex align-items-center justify-content-center" href="<c:url value="/"/>">
            <div class="sidebar-brand-text mx-3" href="<c:url value="/"/>">
                SMU Admin
            </div>
        </a>

        <hr class="sidebar-divider my-0">

        <c:if test="${sessionScope.admin != null}">
            <li class="nav-item active">
                <a class="nav-link" href="<c:url value="/"/>">
                    <i class="fas fa-fw fa-tachometer-alt"></i>
                    <span>Dashboard</span></a>
            </li>
            <li class="nav-item active">
                <a class="nav-link" href="<c:url value="/websocket" />">
                    <i class="fas fa-fw fa-tachometer-alt"></i>
                    <span>Web Socket</span></a>
            </li>
            <li class="nav-item active">
                <a class="nav-link" href="<c:url value="/chart" />">
                    <i class="fas fa-fw fa-tachometer-alt"></i>
                    <span>chart</span></a>
            </li>
            <li class="nav-item active">
                <a class="nav-link" href="<c:url value="/chat" />">
                    <i class="fas fa-fw fa-tachometer-alt"></i>
                    <span>chat</span></a>
            </li>

            <%-- [수정] 'super' 역할 체크: adminId가 'admin'인지 직접 비교 --%>
            <c:if test="${sessionScope.admin == 'admin'}">
                <li class="nav-item active">
                    <a class="nav-link" href="<c:url value="#" />">
                        <i class="fas fa-fw fa-tachometer-alt"></i>
                        <span>Admin</span></a>
                </li>
            </c:if>

            <hr class="sidebar-divider">

            <div class="sidebar-heading">
                Admin Menu
            </div>
            <li class="nav-item">
                <a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseTwo"
                   aria-expanded="true" aria-controls="collapseTwo">
                    <i class="fas fa-fw fa-cog"></i>
                    <span>Cust</span>
                </a>
                <div id="collapseTwo" class="collapse" aria-labelledby="headingTwo" data-parent="#accordionSidebar">
                    <div class="bg-white py-2 collapse-inner rounded">
                        <h6 class="collapse-header">Customer Management:</h6>
                        <a class="collapse-item" href="<c:url value="/cust/add"/>">Add</a>
                        <a class="collapse-item" href="<c:url value="/cust/get"/>">Get</a>
                        <a class="collapse-item" href="<c:url value="/cust/logininfo"/>">Login Info</a>

                    </div>
                </div>
            </li>

            <li class="nav-item">
                <a class="nav-link collapsed" href="#" data-toggle="collapse" data-target="#collapseUtilities"
                   aria-expanded="true" aria-controls="collapseUtilities">
                    <i class="fas fa-fw fa-wrench"></i>
                    <span>Product</span>
                </a>
                <div id="collapseUtilities" class="collapse" aria-labelledby="headingUtilities"
                     data-parent="#accordionSidebar">
                    <div class="bg-white py-2 collapse-inner rounded">
                        <h6 class="collapse-header">Product Management:</h6>
                        <a class="collapse-item" href="<c:url value="/product/add"/>">Add</a>
                        <a class="collapse-item" href="<c:url value="/product/get"/>">Get</a>
                    </div>
                </div>
            </li>
        </c:if>

        <hr class="sidebar-divider">

        <div class="text-center d-none d-md-inline">
            <button class="rounded-circle border-0" id="sidebarToggle"></button>
        </div>

    </ul>
    <div id="content-wrapper" class="d-flex flex-column">

        <div id="content">

            <nav class="navbar navbar-expand navbar-light bg-white topbar mb-4 static-top shadow">

                <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle mr-3">
                    <i class="fa fa-bars"></i>
                </button>

                <ul class="navbar-nav ml-auto">

                    <li class="nav-item dropdown no-arrow d-sm-none">
                    </li>
                    <li class="nav-item dropdown no-arrow mx-1">
                    </li>
                    <li class="nav-item dropdown no-arrow mx-1">
                    </li>

                    <div class="topbar-divider d-none d-sm-block"></div>

                    <c:choose>
                        <c:when test="${sessionScope.admin == null}">
                            <form class="form-inline">
                                <a href="#" data-toggle="modal" data-target="#loginModal"
                                   class="btn btn-warning mb-2 mr-sm-2" role="button">Login</a>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <li class="nav-item dropdown no-arrow">
                                <a class="nav-link dropdown-toggle" href="#" role="button"
                                   aria-haspopup="true" aria-expanded="false">

                                    <span class="mr-2 d-none d-lg-inline text-gray-600 small">${sessionScope.admin}</span>
                                    <img class="img-profile rounded-circle"
                                         src="<c:url value="/img/undraw_profile.svg"/>">
                                </a>
                            </li>
                            <li class="nav-item dropdown no-arrow">
                                <a href="<c:url value="/logoutimpl"/>" role="button"
                                   aria-haspopup="true" aria-expanded="false">LOGOUT</a>
                            </li>
                        </c:otherwise>
                    </c:choose>
                </ul>

            </nav>
            <c:choose>
                <c:when test="${center == null}">
                    <jsp:include page="center.jsp"></jsp:include>
                </c:when>
                <c:otherwise>
                    <jsp:include page="${center}.jsp"></jsp:include>
                </c:otherwise>
            </c:choose>
        </div>
        <footer class="sticky-footer bg-white">
        </footer>
    </div>
</div>
<a class="scroll-to-top rounded" href="#page-top">
    <i class="fas fa-angle-up"></i>
</a>

<div class="modal fade" id="loginModal" tabindex="-1" role="dialog" aria-labelledby="loginModalLabel"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="loginModalLabel">Try Login</h5>
                <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">×</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="login_form" action="<c:url value="/loginimpl"/>" method="post">
                    <div class="form-group">
                        <label for="id">ID:</label>
                        <input type="text" class="form-control" id="id" placeholder="Enter id" name="id">
                    </div>
                    <div class="form-group">
                        <label for="pwd">Password:</label>
                        <input type="password" class="form-control" id="pwd" placeholder="Enter password" name="pwd">
                    </div>
                    <button type="button" class="btn btn-primary">LOGIN</button>
                    <c:if test="${loginfail == 'fail'}">
                        <div class="alert alert-danger">아이디 또는 비밀번호가 틀렸습니다.</div>
                    </c:if>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>
<!-- Logout Modal-->
<div class="modal fade" id="logoutModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">Ready to Leave?</h5>
                <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">×</span>
                </button>
            </div>
            <div class="modal-body">Select "Logout" below if you are ready to end your current session.</div>
            <div class="modal-footer">
                <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancel</button>
                <a class="btn btn-primary" href="login.html">Logout</a>
            </div>
        </div>
    </div>
</div>



<!-- Custom scripts for all pages-->
<script src="/js/sb-admin-2.min.js"></script>

</body>

</html>