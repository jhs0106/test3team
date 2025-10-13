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
                    chart: {
                        zoomType: 'x',
                        animation: Highcharts.svg,
                        backgroundColor: '#ffffff',
                        panning: true,
                        panKey: 'shift'
                    },
                    title: { text: '📈 실시간 주가 변화' },
                    subtitle: { text: '드래그로 확대 / Shift + 드래그로 이동' },
                    time: { timezone: 'Asia/Seoul' },

                    rangeSelector: {
                        enabled: true,
                        buttons: [
                            { type: 'minute', count: 1, text: '1분' },
                            { type: 'minute', count: 5, text: '5분' },
                            { type: 'hour', count: 1, text: '1시간' },
                            { type: 'day', count: 1, text: '1일' },
                            { type: 'all', text: '전체' }
                        ],
                        selected: 2
                    },

                    xAxis: {
                        type: 'datetime',
                        labels: {
                            formatter: function() {
                                return Highcharts.dateFormat('%H:%M:%S', this.value);
                            }
                        }
                    },

                    yAxis: [{
                        title: { text: '가격 (KRW)' },
                        labels: { format: '{value}원' },
                        opposite: false
                    }, {
                        title: { text: '거래량 (주)' },
                        labels: { format: '{value}' },
                        opposite: true,
                        gridLineWidth: 0
                    }],

                    tooltip: {
                        shared: true,
                        backgroundColor: 'rgba(255,255,255,0.9)',
                        borderColor: '#ccc',
                        borderRadius: 8,
                        formatter: function() {
                            const point = this.points[0];
                            const price = point.y.toLocaleString();
                            const volume = point.point.volume ? point.point.volume.toLocaleString() : '-';
                            const change = point.point.change ? point.point.change.toFixed(2) : 0;
                            const color = change >= 0 ? 'red' : 'blue';

                            return `
                    <b>${Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x)}</b><br/>
                    가격: <b style="color:${color};">${price} KRW</b><br/>
                    변동률: <b style="color:${color};">${change}%</b><br/>
                    거래량: <b>${volume}</b>
                `;
                        }
                    },

                    plotOptions: {
                        series: { animation: { duration: 400 }, lineWidth: 2 },
                        areaspline: {
                            color: '#32CD32',
                            fillColor: {
                                linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                                stops: [
                                    [0, 'rgba(50,205,50,0.7)'],
                                    [1, 'rgba(50,205,50,0)']
                                ]
                            },
                            threshold: null,
                            marker: { enabled: false }
                        },
                        column: {
                            color: 'rgba(30,144,255,0.5)',
                            borderWidth: 0,
                            yAxis: 1
                        }
                    },

                    series: [
                        {
                            name: '주가',
                            type: 'areaspline',
                            data: [],
                            tooltip: { valueSuffix: ' KRW' }
                        },
                        {
                            name: '거래량',
                            type: 'column',
                            data: [],
                            yAxis: 1,
                            tooltip: { valueSuffix: ' 주' }
                        }
                    ],

                    exporting: { enabled: false },
                    credits: { enabled: false }
                });
            },


            updateData: function() {
                const apiUrl = `${apiOrigin}/api/stocks/${this.symbol}`;
                $.getJSON(apiUrl, (data) => {
                    if (!data || data.error) return;

                    const now = (new Date()).getTime();
                    const price = data.regularMarketPrice || 0;
                    const change = data.regularMarketChangePercent || 0;
                    const volume = data.regularMarketVolume || 0;
                    const name = data.longName || data.symbol;

                    const color = (change >= 0) ? 'red' : 'blue';
                    const sign = (change >= 0) ? '▲' : '▼';

                    $('#name').text(name);
                    $('#price-info').html(`<span style="color:${color}; font-weight:bold;">${price.toLocaleString()} KRW ${sign}${change.toFixed(2)}%</span>`);
                    $('#extra-info').html(`거래량: ${volume.toLocaleString()}`);

                    if (this.chart) {
                        const priceSeries = this.chart.series[0];
                        const volumeSeries = this.chart.series[1];
                        const pointData = { x: now, y: price, volume, change };

                        if (priceSeries.data.length === 0) {
                            priceSeries.setData([pointData]);
                            volumeSeries.setData([[now, volume]]);
                        } else {
                            priceSeries.addPoint(pointData, true, priceSeries.data.length > 50);
                            volumeSeries.addPoint([now, volume], true, volumeSeries.data.length > 50);
                        }
                    }
                }).fail(err => console.error("API 요청 실패:", err));
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
