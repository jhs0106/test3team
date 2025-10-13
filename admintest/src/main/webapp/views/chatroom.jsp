<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .status-waiting {
        background-color: #f8d7da;
        color: #721c24;
        padding: 5px 10px;
        border-radius: 5px;
        font-weight: bold;
    }
    .status-active {
        background-color: #d4edda;
        color: #155724;
        padding: 5px 10px;
        border-radius: 5px;
        font-weight: bold;
    }
    .status-closed {
        background-color: #d6d8db;
        color: #383d41;
        padding: 5px 10px;
        border-radius: 5px;
        font-weight: bold;
    }
    .clickable-row {
        cursor: pointer;
        transition: background-color 0.2s;
    }
    .clickable-row:hover {
        background-color: #f8f9fc;
    }
</style>

<script>
    const chatRoomDetailUrl = '<c:url value="/chatroom/detail" />';

    const STATUS_LABELS = {
        waiting: '대기중',
        active: '진행중',
        closed: '종료'
    };

    const STATUS_CLASS = {
        waiting: 'status-waiting',
        active: 'status-active',
        closed: 'status-closed'
    };

    const SECTION_TARGETS = {
        waiting: '#waitingRoomListBody',
        active: '#activeRoomListBody',
        closed: '#closedRoomListBody'
    };

    let chatRoomList = {
        init: function() {
            console.log("🚀 채팅방 리스트 초기화");
            this.loadRooms();

            // 5초마다 자동 새로고침
            setInterval(() => {
                this.loadRooms();
            }, 5000);
        },

        loadRooms: function() {
            $.ajax({
                url: 'https://10.20.33.248:8443/api/chatroom/all',
                type: 'GET',
                success: (data) => {
                    console.log("✅ 채팅방 리스트 조회 성공:", data);
                    this.displayRooms(data);
                },
                error: (xhr, status, error) => {
                    console.error("❌ 채팅방 리스트 조회 실패:", xhr);
                    const waitingErrorTarget = $('#waitingRoomListBody');
                    const activeErrorTarget = $('#activeRoomListBody');
                    const closedErrorTarget = $('#closedRoomListBody');

                    const errorRow = (colspan, message) => {
                        return '<tr><td colspan="' + colspan + '" class="text-center text-danger">' +
                            '<i class="fas fa-exclamation-triangle"></i> ' + message + '</td></tr>';
                    };

                    if (xhr.status === 0) {
                        const certificateGuide =
                            '⚠️ <strong>인증서 오류입니다.</strong><br>' +
                            '다음 URL을 새 탭에서 열어 인증서를 승인해주세요:<br>' +
                            '<a href="https://10.20.33.248:8443/api/chatroom/all" target="_blank" ' +
                            'style="color:#e74a3b; font-weight:bold;">https://10.20.33.28:8443/api/chatroom/all</a><br>' +
                            '<ol style="text-align: left; margin-top: 10px;">' +
                            '<li>위 링크를 클릭하여 새 탭에서 열기</li>' +
                            '<li>"고급" 버튼 클릭</li>' +
                            '<li>"localhost로 이동(안전하지 않음)" 클릭</li>' +
                            '<li>이 페이지를 새로고침</li>' +
                            '</ol>';

                        waitingErrorTarget.html(errorRow(5, certificateGuide));
                        activeErrorTarget.html(errorRow(5, certificateGuide));
                        closedErrorTarget.html(errorRow(6, certificateGuide));
                    } else {
                        const commonError = '서버 오류: ' + xhr.status + ' - ' + error;
                        waitingErrorTarget.html(errorRow(5, commonError));
                        activeErrorTarget.html(errorRow(5, commonError));
                        closedErrorTarget.html(errorRow(6, commonError));
                    }
                }
            });
        },

        displayRooms: function(rooms) {
            const grouped = {
                waiting: [],
                active: [],
                closed: []
            };

            rooms.forEach(room => {
                const status = (room.status || '').toLowerCase();
                if (grouped[status]) {
                    grouped[status].push(room);
                }
            });

            ['waiting', 'active', 'closed'].forEach(status => {
                chatRoomList.renderSection(status, grouped[status]);
            });
        },

        renderSection: function(status, rooms) {
            const target = $(SECTION_TARGETS[status]);
            target.empty();

            if (!rooms || rooms.length === 0) {
                const colspan = status === 'closed' ? 6 : 5;
                const emptyLabel = status === 'waiting'
                    ? '대기 중인 채팅방이 없습니다'
                    : status === 'active'
                        ? '진행 중인 채팅방이 없습니다'
                        : '종료된 채팅방이 없습니다';
                target.append(
                    '<tr><td colspan="' + colspan + '" class="text-center text-muted" style="padding: 24px;">' +
                    '<i class="fas fa-inbox fa-2x mb-3"></i><br>' + emptyLabel +
                    '</td></tr>'
                );
                return;
            }

            rooms.forEach(room => {
                const adminLabel = room.adminId || '<span class="text-muted">-</span>';
                const badgeClass = STATUS_CLASS[status] || 'badge badge-secondary';
                const badgeLabel = STATUS_LABELS[status] || status.toUpperCase();
                const statusBadge = '<span class="' + badgeClass + '">' + badgeLabel + '</span>';
                const createdAt = room.createdAt ? new Date(room.createdAt).toLocaleString('ko-KR') : '-';
                const closedAt = room.closedAt ? new Date(room.closedAt).toLocaleString('ko-KR') : '-';

                let row = '<tr class="clickable-row" data-room-id="' + room.roomId + '" data-cust-id="' + room.custId + '">';
                row += '<td>' + room.roomId + '</td>';
                row += '<td>' + room.custId + '</td>';
                row += '<td>' + adminLabel + '</td>';
                row += '<td>' + statusBadge + '</td>';
                row += '<td>' + createdAt + '</td>';
                if (status === 'closed') {
                    row += '<td>' + closedAt + '</td>';
                }
                row += '</tr>';

                target.append(row);
            });

            if (status === 'waiting' || status === 'active') {
                target.find('.clickable-row').on('click', function() {
                    const roomId = $(this).data('room-id');
                    const custId = $(this).data('cust-id');
                    if (!roomId || !custId) {
                        alert('채팅방 정보가 올바르지 않습니다.');
                        return;
                    }
                    window.location.href = chatRoomDetailUrl + '?roomId=' + roomId + '&custId=' + encodeURIComponent(custId);
                });
            }
        }
    };

    $(function() {
        chatRoomList.init();
    });
</script>

<div class="container-fluid">
    <!-- 헤더 -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-comments"></i> 채팅방 현황
        </h1>
        <div>
            <button class="btn btn-primary btn-sm shadow-sm" onclick="chatRoomList.loadRooms()">
                <i class="fas fa-sync-alt"></i> 새로고침
            </button>
        </div>
    </div>

    <!-- 대기 중인 채팅방 -->
    <div class="row">
        <div class="col-xl-12">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">
                        <i class="fas fa-hourglass-half"></i> 대기 중인 채팅방
                    </h6>
                    <span class="badge badge-primary badge-pill">
                        실시간 자동 새로고침 (5초)
                    </span>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="thead-light">
                            <tr>
                                <th width="10%">방 번호</th>
                                <th width="20%">고객 ID</th>
                                <th width="20%">담당 Admin</th>
                                <th width="10%">상태</th>
                                <th width="40%">생성 시간</th>
                            </tr>
                            </thead>
                            <tbody id="waitingRoomListBody">
                            <tr>
                                <td colspan="5" class="text-center text-muted" style="padding: 24px;">
                                    <i class="fas fa-spinner fa-spin fa-2x mb-3"></i><br>
                                    로딩 중...
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 진행 중인 채팅방 -->
    <div class="row">
        <div class="col-xl-12">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-success">
                        <i class="fas fa-comment-dots"></i> 진행 중인 채팅방
                    </h6>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="thead-light">
                            <tr>
                                <th width="10%">방 번호</th>
                                <th width="20%">고객 ID</th>
                                <th width="20%">담당 Admin</th>
                                <th width="10%">상태</th>
                                <th width="40%">생성 시간</th>
                            </tr>
                            </thead>
                            <tbody id="activeRoomListBody">
                            <tr>
                                <td colspan="5" class="text-center text-muted" style="padding: 24px;">
                                    <i class="fas fa-spinner fa-spin fa-2x mb-3"></i><br>
                                    로딩 중...
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 종료된 채팅방 -->
    <div class="row">
        <div class="col-xl-12">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-secondary">
                        <i class="fas fa-archive"></i> 종료된 채팅방
                    </h6>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="thead-light">
                            <tr>
                                <th width="10%">방 번호</th>
                                <th width="20%">고객 ID</th>
                                <th width="20%">담당 Admin</th>
                                <th width="10%">상태</th>
                                <th width="20%">생성 시간</th>
                                <th width="20%">종료 시간</th>
                            </tr>
                            </thead>
                            <tbody id="closedRoomListBody">
                            <tr>
                                <td colspan="6" class="text-center text-muted" style="padding: 24px;">
                                    <i class="fas fa-spinner fa-spin fa-2x mb-3"></i><br>
                                    로딩 중...
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 안내 카드 -->
    <div class="row">
        <div class="col-xl-12">
            <div class="alert alert-info shadow">
                <i class="fas fa-info-circle"></i>
                <strong>사용 안내:</strong>
                <ul class="mb-0 mt-2">
                    <li>대기/진행/종료 상태별로 채팅방이 구분되어 표시됩니다</li>
                    <li>대기 또는 진행 중인 채팅방을 클릭하면 상세 콘솔로 이동합니다</li>
                    <li>5초마다 자동으로 새로고침되며 상단 버튼으로 즉시 새로고침할 수 있습니다</li>
                    <li><strong>📊 사용량 통계 버튼을 클릭하면 고객 통계 대시보드를 확인할 수 있습니다</strong></li>
                </ul>
            </div>
        </div>
    </div>
</div>