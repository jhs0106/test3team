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
    <select id="symbol" style="padding:6px 10px; border:1px solid #ccc; border-radius:6px;">
        <option value="005930">삼성전자 </option>
        <option value="000660">SK하이닉스 </option>
        <option value="035420">NAVER </option>
        <option value="068270">셀트리온 </option>
        <option value="051910">LG화학 </option>
        <option value="005380">현대차 </option>
    </select>

    <button id="get_btn" style="margin-left:8px;">조회</button>

    <div id="result">
        <h4 id="name"></h4>
        <p id="price-info" style="font-size:1.5em;"></p>
        <div id="extra-info"></div>
    </div>

    <div id="chart-container" style="width:600px; height:400px; margin-top:20px;"></div>

    <!--  단일 종목용 그래프 -->
    <script>
        const apiOrigin = window.location.origin || (window.location.protocol + '//' + window.location.host);
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
                if (this.timer) clearInterval(this.timer);
                if (this.chart) this.chart.destroy();
                this.createChart();
                this.updateData();
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
                            marker: { lineWidth: 1, fillColor: 'white' }
                        }
                    }
                });
            },

            updateData: function() {
                const apiUrl = `${apiOrigin}/api/stocks/${this.symbol}`;
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

                    $('#name').text(name);
                    $('#price-info').html(`<span style="color:${color}; font-weight:bold;">${price.toLocaleString()} KRW ${sign}${change.toFixed(2)}%</span>`);
                    $('#extra-info').html(`
            거래량: ${volume.toLocaleString()}<br>
            시가총액: ${marketCap.toLocaleString()}<br>
            52주 범위: ${range}
          `);

                    if (this.chart) {
                        if (this.chart.series[0].data.length === 0) {
                            this.chart.series[0].setData([[now, price]]);
                        } else {
                            this.chart.series[0].addPoint([now, price], true, this.chart.series[0].data.length > 30);
                        }
                    }
                }).fail((err) => {
                    console.error("API 요청 실패:", err);
                    $('#result').html("<div style='color:red;'>API 요청 중 오류 발생</div>");
                });
            }
        };
        $(() => stockLive.init());
    </script>

    <!-- ============================================== -->
    <!-- 여러 종목 실시간   -->
    <!-- ============================================== -->
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
            charts: {},
            timers: {},

            init: function() {
                this.createLayout();
                this.startAll();
            },

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


                    this.charts[stock.code] = Highcharts.chart(chartId, {
                        chart: { type: 'areaspline', animation: Highcharts.svg },
                        title: { text: '실시간 주가 변화' },
                        xAxis: { type: 'datetime' },
                        yAxis: { title: { text: '가격 (KRW)' } },
                        series: [{ name: stock.name, data: [] }],
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
                                marker: { lineWidth: 1, fillColor: 'white' }
                            }
                        }
                    });
                });
            },

            startAll: function() {
                this.symbols.forEach(stock => {
                    this.updateStock(stock);
                    this.timers[stock.code] = setInterval(() => this.updateStock(stock), 5000);
                });
            },

            updateStock: function(stock) {
                const apiUrl = `${apiOrigin}/api/stocks/${stock.code}`;
                $.getJSON(apiUrl, (data) => {
                    if (!data || data.error) return;

                    const now = (new Date()).getTime();
                    const price = data.regularMarketPrice || 0;
                    const change = data.regularMarketChangePercent || 0;
                    const volume = data.regularMarketVolume?.toLocaleString() || '-';
                    const cap = data.marketCap?.toLocaleString() || '-';
                    const color = (change >= 0) ? 'red' : 'blue';
                    const sign = (change >= 0) ? '▲' : '▼';

                    $(`#info-${stock.code}-price`).html(
                        `<span style="color:${color}; font-weight:bold;">${price.toLocaleString()} KRW ${sign}${change.toFixed(2)}%</span>`
                    );
                    $(`#info-${stock.code}-extra`).html(`거래량: ${volume} | 시총: ${cap}`);

                    const chart = this.charts[stock.code];
                    if (chart && chart.series && chart.series[0]) {
                        if (chart.series[0].data.length === 0) {
                            chart.series[0].setData([[now, price]]);
                        } else {
                            chart.series[0].addPoint([now, price], true, chart.series[0].data.length > 30);
                        }
                    }
                }).fail(err => console.error(stock.name + " API 오류", err));
            }
        };
        $(() => stockMulti.init());
    </script>
</div>
