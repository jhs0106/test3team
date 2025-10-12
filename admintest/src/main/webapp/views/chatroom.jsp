<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    #chatRoomListTable {
        width: 100%;
        margin-top: 20px;
    }
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
    let chatRoomList = {
        init: function() {
            console.log("🚀 채팅방 리스트 초기화");
            this.loadWaitingRooms();

            // 5초마다 자동 새로고침
            setInterval(() => {
                this.loadWaitingRooms();
            }, 5000);
        },

        loadWaitingRooms: function() {
            $.ajax({
                url: 'https://localhost:8443/api/chatroom/waiting',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    console.log('✅ API 호출 성공:', data);
                    chatRoomList.displayRooms(data);
                },
                error: function(xhr, status, error) {
                    console.error('❌ API 호출 실패');
                    console.error('Status:', xhr.status);
                    console.error('Error:', error);
                    console.error('Response:', xhr.responseText);

                    // HTTPS 인증서 오류 처리
                    if (xhr.status === 0) {
                        $('#chatRoomListBody').html(
                            '<tr><td colspan="5" class="text-center text-danger" style="padding: 30px;">' +
                            '<i class="fas fa-exclamation-triangle fa-3x mb-3"></i><br>' +
                            '<h5>⚠️ HTTPS 인증서 오류</h5>' +
                            '<p>다음 단계를 진행하세요:</p>' +
                            '<ol class="text-left" style="display: inline-block;">' +
                            '<li>새 탭에서 <a href="https://localhost:8443/api/chatroom/waiting" target="_blank"><strong>이 링크</strong></a>를 클릭</li>' +
                            '<li>"고급" 버튼 클릭</li>' +
                            '<li>"localhost로 이동(안전하지 않음)" 클릭</li>' +
                            '<li>이 페이지를 새로고침</li>' +
                            '</ol>' +
                            '</td></tr>'
                        );
                    } else {
                        $('#chatRoomListBody').html(
                            '<tr><td colspan="5" class="text-center text-danger">' +
                            '서버 오류: ' + xhr.status + ' - ' + error +
                            '</td></tr>'
                        );
                    }
                }
            });
        },

        displayRooms: function(rooms) {
            let tbody = $('#chatRoomListBody');
            tbody.empty();

            if (rooms.length === 0) {
                tbody.append(
                    '<tr><td colspan="5" class="text-center text-muted" style="padding: 30px;">' +
                    '<i class="fas fa-inbox fa-3x mb-3"></i><br>' +
                    '<h5>대기 중인 채팅방이 없습니다</h5>' +
                    '</td></tr>'
                );
                return;
            }

            rooms.forEach(function(room) {
                let statusClass = 'status-' + room.status;
                let statusText = room.status === 'waiting' ? '대기중' :
                    room.status === 'active' ? '진행중' : '종료';

                let row = '<tr class="clickable-row" data-room-id="' + room.roomId + '">' +
                    '<td><strong>' + room.roomId + '</strong></td>' +
                    '<td>' + room.custId + '</td>' +
                    '<td>' + (room.adminId || '<span class="text-muted">-</span>') + '</td>' +
                    '<td><span class="' + statusClass + '">' + statusText + '</span></td>' +
                    '<td>' + new Date(room.createdAt).toLocaleString('ko-KR') + '</td>' +
                    '</tr>';

                tbody.append(row);
            });

            // 클릭 이벤트 등록 (6단계에서 입장 기능 구현 예정)
            $('.clickable-row').click(function() {
                let roomId = $(this).data('room-id');
                console.log('📌 선택된 채팅방 ID:', roomId);
                // TODO: 6단계에서 Admin 입장 기능 추가
                alert('채팅방 ID: ' + roomId + ' 선택됨\n(6단계에서 입장 기능 구현 예정)');
            });
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
            <i class="fas fa-comments"></i> 대기 중인 채팅방 리스트
        </h1>
        <button class="btn btn-primary btn-sm shadow-sm" onclick="chatRoomList.loadWaitingRooms()">
            <i class="fas fa-sync-alt"></i> 새로고침
        </button>
    </div>

    <!-- 테이블 카드 -->
    <div class="row">
        <div class="col-xl-12">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">
                        <i class="fas fa-list"></i> 고객 대기 채팅방
                    </h6>
                    <span class="badge badge-primary badge-pill">
                        실시간 자동 새로고침 (5초)
                    </span>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover" id="chatRoomListTable">
                            <thead class="thead-light">
                            <tr>
                                <th width="10%">방 번호</th>
                                <th width="20%">고객 ID</th>
                                <th width="20%">담당 Admin</th>
                                <th width="15%">상태</th>
                                <th width="35%">생성 시간</th>
                            </tr>
                            </thead>
                            <tbody id="chatRoomListBody">
                            <tr>
                                <td colspan="5" class="text-center text-muted" style="padding: 30px;">
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
                    <li>대기 중인 채팅방이 자동으로 표시됩니다</li>
                    <li>채팅방을 클릭하면 상세 정보가 콘솔에 출력됩니다</li>
                    <li>5초마다 자동으로 새로고침됩니다</li>
                    <li><strong>6단계</strong>에서 채팅방 입장 기능이 추가될 예정입니다</li>
                </ul>
            </div>
        </div>
    </div>
</div>