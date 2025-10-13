<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="true" %>


<style>
    #result {
        width: 500px;
        padding: 10px;
        margin-top: 15px;
        background: #fff;
        border: 2px solid #ddd;
        color: #000;
    }
</style>

<div class="col-sm-10">
    <h2>🌡️ 실시간 환경 센서 그래프</h2>
    <button id="connectBtn" class="btn btn-primary">연결</button>
    <button id="disconnectBtn" class="btn btn-danger">종료</button>

    <div id="result">
        <h4>현재 센서 상태</h4>
        <p id="temp-info" style="font-size:1.2em;"></p>
        <p id="humi-info" style="font-size:1.2em;"></p>
        <p id="light-info" style="font-size:1.2em;"></p>
    </div>

    <div id="chart-container" style="width:600px; height:400px; margin-top:20px;"></div>

    <script>
        let sseEnv = {
            eventSource: null,
            chart: null,

            init: function() {
                $('#connectBtn').click(() => this.connect());
                $('#disconnectBtn').click(() => this.disconnect());
                this.createChart();
            },

            createChart: function() {
                this.chart = Highcharts.chart('chart-container', {
                    chart: { type: 'areaspline', animation: Highcharts.svg },
                    title: { text: '실시간 온도·습도·조도 변화' },
                    xAxis: { type: 'datetime' },
                    yAxis: { title: { text: '값' } },
                    legend: { layout: 'horizontal', align: 'center', verticalAlign: 'top' },
                    series: [
                        {
                            name: '온도 (°C)',
                            data: [],
                            color: '#FF6347', // 토마토색
                            fillColor: {
                                linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                                stops: [
                                    [0, 'rgba(255,99,71,0.6)'],
                                    [1, 'rgba(255,99,71,0)']
                                ]
                            },
                            marker: { lineWidth: 1, fillColor: 'white' },
                            threshold: null
                        },
                        {
                            name: '습도 (%)',
                            data: [],
                            color: '#1E90FF', // 파란색
                            fillColor: {
                                linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                                stops: [
                                    [0, 'rgba(30,144,255,0.6)'],
                                    [1, 'rgba(30,144,255,0)']
                                ]
                            },
                            marker: { lineWidth: 1, fillColor: 'white' },
                            threshold: null
                        },
                        {
                            name: '조도 (lux)',
                            data: [],
                            color: '#32CD32', // 연두색
                            fillColor: {
                                linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                                stops: [
                                    [0, 'rgba(50,205,50,0.6)'],
                                    [1, 'rgba(50,205,50,0)']
                                ]
                            },
                            marker: { lineWidth: 1, fillColor: 'white' },
                            threshold: null
                        }
                    ]
                });
            },

            connect: function() {
                if (this.eventSource) return;
                $('#connectBtn').prop('disabled', true);

                this.eventSource = new EventSource('https://localhost:8444/sse2/connect/user1');

                this.eventSource.addEventListener('connect', e => {
                    console.log('SSE 연결 성공:', e.data);
                    $('#connectBtn').text('연결됨 ').removeClass('btn-primary').addClass('btn-success');
                });

                this.eventSource.addEventListener('sensorData', e => {
                    const data = JSON.parse(e.data);
                    const now = (new Date()).getTime();

                    // 그래프에 추가
                    this.chart.series[0].addPoint([now, data.temperature], true, this.chart.series[0].data.length > 30);
                    this.chart.series[1].addPoint([now, data.humidity], true, this.chart.series[1].data.length > 30);
                    this.chart.series[2].addPoint([now, data.light], true, this.chart.series[2].data.length > 30);

                    // 표시 영역 업데이트
                    const colorT = data.temperature >= 25 ? 'red' : 'blue';
                    const colorH = data.humidity >= 60 ? 'dodgerblue' : 'gray';
                    const colorL = data.light >= 400 ? 'orange' : 'green';

                    $('#temp-info').html(`온도: <span style="color:${colorT}; font-weight:bold;">${data.temperature}°C</span>`);
                    $('#humi-info').html(`습도: <span style="color:${colorH}; font-weight:bold;">${data.humidity}%</span>`);
                    $('#light-info').html(`조도: <span style="color:${colorL}; font-weight:bold;">${data.light} lux</span>`);
                });

                this.eventSource.onerror = () => {
                    $('#connectBtn').text('연결 끊김 ').removeClass('btn-success').addClass('btn-danger');
                    this.disconnect();
                };
            },

            disconnect: function() {
                if (this.eventSource) {
                    this.eventSource.close();
                    this.eventSource = null;
                    $('#connectBtn').prop('disabled', false).text('연결');
                    console.log('SSE 연결 종료');
                }
            }
        };

        $(() => sseEnv.init());
    </script>
</div>
