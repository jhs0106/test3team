<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>고객 사용량 통계 대시보드</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- HighCharts -->
    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="https://code.highcharts.com/modules/exporting.js"></script>
    <script src="https://code.highcharts.com/modules/export-data.js"></script>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        body {
            background-color: #f8f9fc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .dashboard-container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .dashboard-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        .chart-container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            font-size: 0.9rem;
            color: #6c757d;
            text-transform: uppercase;
        }
        .controls {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .btn-primary {
            background: #667eea;
            border: none;
        }
        .btn-primary:hover {
            background: #5568d3;
        }
    </style>
</head>
<body>
<div class="dashboard-container">
    <!-- 헤더 -->
    <div class="dashboard-header">
        <h1>📊 고객 사용량 통계 대시보드</h1>
        <p class="mb-0">실시간 고객 서비스 이용 현황 및 통계</p>
    </div>

    <!-- 컨트롤 패널 -->
    <div class="controls">
        <div class="row align-items-end">
            <div class="col-md-3">
                <label class="form-label">고객 ID</label>
                <input type="text" id="custIdInput" class="form-control" placeholder="예: user1" value="user1">
            </div>
            <div class="col-md-3">
                <label class="form-label">조회 기간 (일)</label>
                <select id="daysSelect" class="form-select">
                    <option value="7">최근 7일</option>
                    <option value="14">최근 14일</option>
                    <option value="30" selected>최근 30일</option>
                    <option value="60">최근 60일</option>
                    <option value="90">최근 90일</option>
                </select>
            </div>
            <div class="col-md-3">
                <button id="loadStatsBtn" class="btn btn-primary w-100">
                    🔄 데이터 불러오기
                </button>
            </div>
            <div class="col-md-3">
                <button id="loadSummaryBtn" class="btn btn-secondary w-100">
                    📋 전체 요약 보기
                </button>
            </div>
        </div>
    </div>

    <!-- 통계 카드 -->
    <div class="row" id="statCards">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-label">총 채팅 횟수</div>
                <div class="stat-number" id="totalChats">0</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-label">총 대화 시간 (분)</div>
                <div class="stat-number" id="totalDuration">0</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-label">평균 응답 시간 (초)</div>
                <div class="stat-number" id="avgResponse">0</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-label">평균 만족도</div>
                <div class="stat-number" id="avgSatisfaction">0.0</div>
            </div>
        </div>
    </div>

    <!-- 차트 영역 -->
    <div class="row">
        <div class="col-md-12">
            <div class="chart-container">
                <div id="chatCountChart"></div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="chart-container">
                <div id="durationChart"></div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="chart-container">
                <div id="satisfactionChart"></div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="chart-container">
                <div id="responseTimeChart"></div>
            </div>
        </div>
    </div>
</div>

<script>
    // API URL 설정
    const API_BASE = 'https://192.168.45.176:8443/api/stats';

    // HighCharts 글로벌 옵션
    Highcharts.setOptions({
        lang: {
            thousandsSep: ','
        }
    });

    // 통계 대시보드 객체
    const statsDashboard = {
        init: function() {
            console.log("📊 통계 대시보드 초기화");
            this.bindEvents();
            this.loadCustomerStats(); // 초기 로드
        },

        bindEvents: function() {
            $('#loadStatsBtn').on('click', () => this.loadCustomerStats());
            $('#loadSummaryBtn').on('click', () => this.loadSummary());
        },

        // 고객 통계 로드
        loadCustomerStats: function() {
            const custId = $('#custIdInput').val().trim();
            const days = $('#daysSelect').val();

            if (!custId) {
                alert('고객 ID를 입력하세요.');
                return;
            }

            console.log(`📊 통계 로드: custId=${custId}, days=${days}`);

            $.ajax({
                url: `${API_BASE}/customer/${custId}`,
                type: 'GET',
                data: { days: days },
                success: (data) => {
                    console.log("✅ 통계 데이터:", data);
                    this.updateStatCards(data);
                    this.renderCharts(data);
                },
                error: (xhr) => {
                    console.error("❌ 통계 로드 실패:", xhr);
                    alert('통계 데이터를 불러오는데 실패했습니다.');
                }
            });
        },

        // 통계 카드 업데이트
        updateStatCards: function(data) {
            const totalChats = data.reduce((sum, item) => sum + (item.chatCount || 0), 0);
            const totalDuration = data.reduce((sum, item) => sum + (item.totalDuration || 0), 0);
            const avgResponse = data.length > 0
                ? (data.reduce((sum, item) => sum + (item.avgResponseTime || 0), 0) / data.length).toFixed(1)
                : 0;
            const avgSatisfaction = data.length > 0
                ? (data.reduce((sum, item) => sum + (item.satisfactionScore || 0), 0) / data.length).toFixed(1)
                : 0;

            $('#totalChats').text(totalChats.toLocaleString());
            $('#totalDuration').text(totalDuration.toLocaleString());
            $('#avgResponse').text(avgResponse);
            $('#avgSatisfaction').text(avgSatisfaction);
        },

        // 차트 렌더링
        renderCharts: function(data) {
            // 데이터를 날짜 오름차순으로 정렬
            const sortedData = data.sort((a, b) => new Date(a.statDate) - new Date(b.statDate));

            const dates = sortedData.map(item => item.statDate);
            const chatCounts = sortedData.map(item => item.chatCount || 0);
            const durations = sortedData.map(item => item.totalDuration || 0);
            const responseTimes = sortedData.map(item => item.avgResponseTime || 0);
            const satisfactionScores = sortedData.map(item => item.satisfactionScore || 0);

            // 1. 채팅 횟수 차트
            Highcharts.chart('chatCountChart', {
                chart: { type: 'area' },
                title: { text: '일별 채팅 횟수 추이' },
                xAxis: {
                    categories: dates,
                    title: { text: '날짜' }
                },
                yAxis: {
                    title: { text: '채팅 횟수' },
                    min: 0
                },
                plotOptions: {
                    area: {
                        fillColor: {
                            linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                            stops: [
                                [0, 'rgba(102, 126, 234, 0.5)'],
                                [1, 'rgba(102, 126, 234, 0.05)']
                            ]
                        },
                        marker: { radius: 2 },
                        lineWidth: 2,
                        states: {
                            hover: { lineWidth: 3 }
                        }
                    }
                },
                series: [{
                    name: '채팅 횟수',
                    data: chatCounts,
                    color: '#667eea'
                }],
                credits: { enabled: false }
            });

            // 2. 대화 시간 차트
            Highcharts.chart('durationChart', {
                chart: { type: 'column' },
                title: { text: '일별 총 대화 시간' },
                xAxis: {
                    categories: dates,
                    title: { text: '날짜' }
                },
                yAxis: {
                    title: { text: '시간 (분)' },
                    min: 0
                },
                series: [{
                    name: '대화 시간',
                    data: durations,
                    color: '#f093fb'
                }],
                credits: { enabled: false }
            });

            // 3. 만족도 차트
            Highcharts.chart('satisfactionChart', {
                chart: { type: 'spline' },
                title: { text: '일별 만족도 점수' },
                xAxis: {
                    categories: dates,
                    title: { text: '날짜' }
                },
                yAxis: {
                    title: { text: '만족도 (1-5)' },
                    min: 0,
                    max: 5
                },
                series: [{
                    name: '만족도',
                    data: satisfactionScores,
                    color: '#4facfe'
                }],
                credits: { enabled: false }
            });

            // 4. 응답 시간 차트
            Highcharts.chart('responseTimeChart', {
                chart: { type: 'line' },
                title: { text: '일별 평균 응답 시간' },
                xAxis: {
                    categories: dates,
                    title: { text: '날짜' }
                },
                yAxis: {
                    title: { text: '응답 시간 (초)' },
                    min: 0
                },
                series: [{
                    name: '응답 시간',
                    data: responseTimes,
                    color: '#fa709a'
                }],
                credits: { enabled: false }
            });
        },

        // 전체 요약 보기
        loadSummary: function() {
            const days = $('#daysSelect').val();

            console.log(`📋 전체 요약 로드: days=${days}`);

            $.ajax({
                url: `${API_BASE}/summary`,
                type: 'GET',
                data: { days: days },
                success: (data) => {
                    console.log("✅ 전체 요약 데이터:", data);
                    this.renderSummaryChart(data);
                },
                error: (xhr) => {
                    console.error("❌ 전체 요약 로드 실패:", xhr);
                    alert('전체 요약 데이터를 불러오는데 실패했습니다.');
                }
            });
        },

        // 전체 요약 차트 렌더링
        renderSummaryChart: function(data) {
            const customers = data.map(item => item.cust_id);
            const totalChats = data.map(item => item.total_chats);
            const avgSatisfaction = data.map(item => parseFloat(item.avg_satisfaction).toFixed(1));

            // 고객별 채팅 횟수 비교
            Highcharts.chart('chatCountChart', {
                chart: { type: 'bar' },
                title: { text: '고객별 총 채팅 횟수 비교' },
                xAxis: {
                    categories: customers,
                    title: { text: '고객 ID' }
                },
                yAxis: {
                    title: { text: '총 채팅 횟수' },
                    min: 0
                },
                series: [{
                    name: '채팅 횟수',
                    data: totalChats,
                    color: '#667eea'
                }],
                credits: { enabled: false }
            });

            // 고객별 만족도 비교
            Highcharts.chart('satisfactionChart', {
                chart: { type: 'column' },
                title: { text: '고객별 평균 만족도 비교' },
                xAxis: {
                    categories: customers,
                    title: { text: '고객 ID' }
                },
                yAxis: {
                    title: { text: '평균 만족도' },
                    min: 0,
                    max: 5
                },
                series: [{
                    name: '만족도',
                    data: avgSatisfaction.map(parseFloat),
                    color: '#4facfe'
                }],
                credits: { enabled: false }
            });

            // 통계 카드 업데이트
            const totalAllChats = totalChats.reduce((sum, count) => sum + count, 0);
            const avgAllSatisfaction = (avgSatisfaction.reduce((sum, score) => sum + parseFloat(score), 0) / avgSatisfaction.length).toFixed(1);

            $('#totalChats').text(totalAllChats.toLocaleString());
            $('#avgSatisfaction').text(avgAllSatisfaction);
            $('#totalDuration').text('-');
            $('#avgResponse').text('-');
        }
    };

    // 페이지 로드 시 초기화
    $(document).ready(function() {
        statsDashboard.init();
    });
</script>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>