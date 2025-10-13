<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="true" %>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    let sseChart = {
        eventSource: null,
        chart: null,

        init: function() {
            $('#connectBtn').click(() => {
                this.connect();
            });
            $('#disconnectBtn').click(() => {
                this.disconnect();
            });
            this.createChart();
        },

        createChart: function() {
            const ctx = document.getElementById('sensorChart').getContext('2d');
            this.chart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: [],
                    datasets: [
                        { label: '온도  (°C)', borderColor: 'red', data: [], tension: 0.3 },
                        { label: '습도 (%)', borderColor: 'blue', data: [], tension: 0.3 },
                        { label: '조도 (lux)', borderColor: 'green', data: [], tension: 0.3 }
                    ]
                },
                options: {
                    responsive: true,
                    animation: false,
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });
        },

        connect: function() {
            if (this.eventSource !== null) return; // 중복 연결 방지
            $('#status').text('연결 중...').css('color', 'orange');

            this.eventSource = new EventSource('https://localhost:8444/sse2/connect/user1');
            this.eventSource.addEventListener('connect', e => {
                console.log('SSE 연결 성공:', e.data);
                $('#status').text(' 연결됨').css('color', 'green');
            });

            this.eventSource.addEventListener('sensorData', e => {
                const json = JSON.parse(e.data);
                const time = new Date().toLocaleTimeString();

                console.log('수신 데이터:', json);

                this.chart.data.labels.push(time);
                this.chart.data.datasets[0].data.push(json.temperature);
                this.chart.data.datasets[1].data.push(json.humidity);
                this.chart.data.datasets[2].data.push(json.light);

                if (this.chart.data.labels.length > 10) {
                    this.chart.data.labels.shift();
                    this.chart.data.datasets.forEach(ds => ds.data.shift());
                }
                this.chart.update();

                $('#log').prepend(
                    `<p><strong>[${time}]</strong> 온도: ${json.temperature}°C, 습도: ${json.humidity}%, 조도: ${json.light}lux</p>`
                );
            });

            this.eventSource.onerror = () => {
                $('#status').text(' 연결 끊김').css('color', 'red');
                this.disconnect();
            };
        },

        disconnect: function() {
            if (this.eventSource) {
                this.eventSource.close();
                this.eventSource = null;
                $('#status').text('⏹ 연결 종료').css('color', 'gray');
                console.log("SSE 연결 종료");
            }
        }
    };

    $(function() {
        sseChart.init();
    });
</script>

<div class="col-sm-10">
    <h2>SSE 실시간 환경 데이터</h2>
    <p>SSE 연결 상태: <strong id="status">⏸ 대기 중</strong></p>

    <button id="connectBtn" class="btn btn-primary">연결</button>
    <button id="disconnectBtn" class="btn btn-danger">종료</button>
    <hr>

    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">실시간 센서 데이터 차트</h6>
        </div>
        <div class="card-body">
            <canvas id="sensorChart" width="900" height="400"></canvas>
        </div>
    </div>

    <hr>
    <h4>데이터 로그</h4>
    <div id="log" style="border: 1px solid #ccc; padding: 10px; height: 300px; overflow-y: auto; background: #fafafa;"></div>
</div>
