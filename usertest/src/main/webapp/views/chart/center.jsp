<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="true" %>

<style>
    #result {
        width: 400px;
        padding: 10px;
        margin-top: 15px;
        background: #fff;
        border: 2px solid #ddd;
        color: #000;
    }
</style>

<div class="col-sm-10">
    <h2>📈 실시간 주가 그래프</h2>
    <input id="symbol" value="005930" placeholder="예: 005930 (삼성전자)">
    <button id="get_btn">조회</button>

    <div id="result">
        <h4 id="name"></h4>
        <p id="price-info" style="font-size:1.5em;"></p>
        <div id="extra-info"></div>
    </div>

    <div id="chart-container" style="width:600px; height:400px; margin-top:20px;"></div>

    <script>
        let stockLive = {
            symbol: null,
            chart: null,
            timer: null,

            init: function() {
                $('#get_btn').click(() => {
                    const symbol = $('#symbol').val().trim();
                    if (symbol === '') {
                        alert('종목 코드를 입력하세요.');
                        return;
                    }
                    this.symbol = symbol;
                    this.start(symbol);
                });
            },

            start: function(symbol) {
                // ✅ 이전 차트와 타이머 제거
                if (this.timer) clearInterval(this.timer);
                if (this.chart) this.chart.destroy();

                this.createChart();
                this.updateData();
                // ✅ 5초마다 자동 갱신
                this.timer = setInterval(() => this.updateData(), 5000);
            },

            createChart: function() {
                this.chart = Highcharts.chart('chart-container', {
                    chart: { type: 'areaspline', animation: Highcharts.svg },
                    title: { text: '실시간 주가 변화' },
                    xAxis: { type: 'datetime' },
                    yAxis: { title: { text: '가격 (KRW)' } },
                    series: [{ name: '주가', data: [] }],
                    plotOptions: {
                        areaspline: {
                            color: '#32CD32',
                            fillColor: {
                                linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                                stops: [
                                    [0, '#32CD32'],
                                    [1, 'rgba(50,205,50,0)']
                                ]
                            },
                            threshold: null,
                            marker: {
                                lineWidth: 1,
                                lineColor: null,
                                fillColor: 'white'
                            }
                        }
                    }
                });
            },

            updateData: function() {
                // ✅ HTTPS로 고정된 요청 (Spring Boot HTTPS 환경)
                const apiUrl = `https://${window.location.host}/api/stocks/${this.symbol}`;

                $.getJSON(apiUrl, (data) => {
                    if (!data || data.error) {
                        $('#result').html("<div style='color:red;'>" + (data?.error || "데이터를 불러오지 못했습니다.") + "</div>");
                        return;
                    }

                    const now = (new Date()).getTime();
                    const price = data.regularMarketPrice || 0;
                    const change = data.regularMarketChangePercent || 0;
                    const volume = data.regularMarketVolume || '-';
                    const marketCap = data.marketCap || '-';
                    const range = data.fiftyTwoWeekRange || '-';
                    const name = data.longName || data.symbol;

                    const color = (change >= 0) ? 'red' : 'blue';
                    const sign = (change >= 0) ? '▲' : '▼';

                    // ✅ 안전한 HTML 갱신
                    $('#name').text(name);
                    $('#price-info').html(`<span style="color:${color}; font-weight:bold;">${price.toLocaleString()} KRW ${sign}${change.toFixed(2)}%</span>`);
                    $('#extra-info').html(`
            거래량: ${volume.toLocaleString()}<br>
            시가총액: ${marketCap.toLocaleString()}<br>
            52주 범위: ${range}
          `);

                    // ✅ 차트 갱신
                    if (this.chart) {
                        this.chart.series[0].addPoint([now, price], true, this.chart.series[0].data.length > 30);
                    }
                }).fail((err) => {
                    console.error("API 요청 실패:", err);
                    $('#result').html("<div style='color:red;'>API 요청 중 오류 발생</div>");
                });
            }
        };

        $(() => stockLive.init());
    </script>

    <!-- ===================================================== -->
    <!-- 📊 여러 종목 실시간 그래프 영역 -->
    <!-- ===================================================== -->

    <hr style="margin-top:50px;">
    <h3>📊 주요 종목 실시간 그래프</h3>

    <div class="row" id="multi-stocks"></div>

    <script>
        let stockMulti = {
            symbols: [
                { code: '005930', name: '삼성전자' },
                { code: '000660', name: 'SK하이닉스' },
                { code: '035420', name: 'NAVER' },
                { code: '068270', name: '셀트리온' }
            ],
            charts: {}, // ← 차트 객체 저장
            timer: null,

            init: function() {
                this.createLayout();   // HTML만 처음 한 번 생성
                this.loadAll();        // 데이터 불러오기
                this.timer = setInterval(() => this.loadAll(), 5000); // 데이터만 갱신
            },

            // ✅ HTML 레이아웃 1회만 생성
            createLayout: function() {
                const container = $('#multi-stocks');
                container.empty();

                this.symbols.forEach(stock => {
                    const chartId = 'chart-' + stock.code;
                    const infoId = 'info-' + stock.code;

                    container.append(`
        <div class="col-sm-6" style="margin-bottom:30px;">
          <div style="border:1px solid #ddd; padding:10px; background:#fff; border-radius:8px;">
            <h5 id="${infoId}-name" style="font-weight:bold;">${stock.name}</h5>
            <p id="${infoId}-price" style="font-size:1.2em;"></p>
            <div id="${infoId}-extra" style="margin-bottom:10px;"></div>
            <div id="${chartId}" style="height:300px;"></div>
          </div>
        </div>
      `);

                    // ✅ 차트 객체 생성 및 저장
                    this.charts[stock.code] = Highcharts.chart(chartId, {
                        chart: { type: 'areaspline' },
                        title: { text: null },
                        xAxis: { type: 'datetime', visible: false },
                        yAxis: { title: { text: null }, visible: false },
                        legend: { enabled: false },
                        series: [{ name: stock.name, data: [], color: '#32CD32' }],
                        credits: { enabled: false },
                        plotOptions: {
                            areaspline: { fillOpacity: 0.3, marker: { enabled: false } }
                        }
                    });
                });
            },

            // ✅ 데이터만 주기적으로 갱신
            loadAll: function() {
                this.symbols.forEach(stock => this.updateStock(stock));
            },

            updateStock: function(stock) {
                const apiUrl = `https://${window.location.host}/api/stocks/${stock.code}`;
                $.getJSON(apiUrl, (data) => {
                    if (!data || data.error) return;

                    const now = (new Date()).getTime();
                    const price = data.regularMarketPrice || 0;
                    const change = data.regularMarketChangePercent || 0;
                    const color = (change >= 0) ? 'red' : 'blue';
                    const sign = (change >= 0) ? '▲' : '▼';
                    const volume = data.regularMarketVolume?.toLocaleString() || '-';
                    const cap = data.marketCap?.toLocaleString() || '-';

                    $(`#info-${stock.code}-price`).html(
                        `<span style="color:${color}; font-weight:bold;">${price.toLocaleString()} KRW ${sign}${change.toFixed(2)}%</span>`
                    );
                    $(`#info-${stock.code}-extra`).html(`거래량: ${volume} | 시총: ${cap}`);

                    // ✅ 차트에 새로운 포인트 추가
                    const chart = this.charts[stock.code];
                    if (chart) {
                        chart.series[0].addPoint([now, price], true, chart.series[0].data.length > 30);
                    }
                });
            }
        };

        $(() => stockMulti.init());
    </script>
</div>
