<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="true" %>



<div class="col-sm-10">
    <h2>🌡️ 실시간 센서 평균값 (3D Cylinder Chart)</h2>
    <p>5초마다 SSE로 들어오는 온도·습도·조도 데이터를 기반으로 평균값이 자동 갱신</p>

    <div id="avg-info" style="margin-top:15px; background:#fafafa; border:1px solid #ddd; padding:10px; width:400px;">
        <strong>실시간 평균값</strong><br>
        온도: <span id="avg-temp">-</span> °C<br>
        습도: <span id="avg-humi">-</span> %<br>
        조도: <span id="avg-light">-</span> lux
    </div>

    <div id="chart-container" style="width:700px; height:500px; margin-top:30px;"></div>

    <button id="connectBtn" class="btn btn-primary mt-3">연결</button>
    <button id="disconnectBtn" class="btn btn-danger mt-3">종료</button>

    <script>
        let sseChart2 = {
            eventSource: null,
            chart: null,
            dataList: { temp: [], humi: [], light: [] },

            init: function() {
                this.createChart();
                $('#connectBtn').click(() => this.connect());
                $('#disconnectBtn').click(() => this.disconnect());
            },

            createChart: function() {
                this.chart = Highcharts.chart('chart-container', {
                    chart: {
                        type: 'cylinder',
                        options3d: {
                            enabled: true,
                            alpha: 15,
                            beta: 15,
                            depth: 50,
                            viewDistance: 25
                        },
                        backgroundColor: '#ffffff'
                    },
                    title: { text: '🌡️ 실시간 센서 평균값 (3D Cylinder)' },
                    xAxis: { categories: ['온도(°C)', '습도(%)', '조도(lux)'] },
                    yAxis: { title: { text: '값' } },
                    plotOptions: { series: { depth: 25, colorByPoint: true } },
                    series: [{
                        name: '평균값',
                        data: [
                            ['온도(°C)', 0],
                            ['습도(%)', 0],
                            ['조도(lux)', 0]
                        ],
                        showInLegend: false
                    }],
                    credits: { enabled: false }
                });
            },

            connect: function() {
                if (this.eventSource) return;
                $('#connectBtn').prop('disabled', true);

                this.eventSource = new EventSource('https://localhost:8444/sse2/connect/chart2');
                console.log("SSE 연결 시도 중...");

                this.eventSource.addEventListener('connect', e => {
                    console.log('SSE 연결 성공:', e.data);
                    $('#connectBtn').text('연결됨').removeClass('btn-primary').addClass('btn-success');
                });

                this.eventSource.addEventListener('sensorData', e => {
                    const json = JSON.parse(e.data);
                    this.addData(json);
                    this.updateChart();
                });

                this.eventSource.onerror = () => {
                    console.error("SSE 연결 오류 발생");
                    this.disconnect();
                };
            },

            disconnect: function() {
                if (this.eventSource) {
                    this.eventSource.close();
                    this.eventSource = null;
                    $('#connectBtn').prop('disabled', false).text('연결');
                    $('#connectBtn').removeClass('btn-success').addClass('btn-primary');
                    console.log('SSE 연결 종료');
                }
            },

            addData: function(data) {
                this.dataList.temp.push(data.temperature);
                this.dataList.humi.push(data.humidity);
                this.dataList.light.push(data.light);

                // 오래된 데이터 삭제 (50개 이상이면)
                Object.keys(this.dataList).forEach(k => {
                    if (this.dataList[k].length > 50) this.dataList[k].shift();
                });
            },

            calcAvg: function(list) {
                if (list.length === 0) return 0;
                const sum = list.reduce((a, b) => a + b, 0);
                return (sum / list.length).toFixed(1);
            },

            updateChart: function() {
                const avgTemp = parseFloat(this.calcAvg(this.dataList.temp));
                const avgHumi = parseFloat(this.calcAvg(this.dataList.humi));
                const avgLight = parseFloat(this.calcAvg(this.dataList.light));
//
                $('#avg-temp').text(avgTemp);
                $('#avg-humi').text(avgHumi);
                $('#avg-light').text(avgLight);

                const series = this.chart.series[0];
                series.setData([
                    ['온도(°C)', avgTemp],
                    ['습도(%)', avgHumi],
                    ['조도(lux)', avgLight]
                ]);
            }
        };

        $(() => sseChart2.init());
    </script>
</div>
