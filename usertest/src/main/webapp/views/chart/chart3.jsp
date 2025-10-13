<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="true" %>

<div class="col-sm-10 text-center">
    <h2 class="mt-3">🌐 실시간 글로벌 증시 변동률 (3D Globe View)</h2>
    <p class="text-muted mb-4">전 세계 주요 증시(KOSPI, NASDAQ, NIKKEI, DAX, SSE 등)의 실시간 변동률을 시각적으로 표현한 대시보드</p>

    <div id="globe-container" style="width:90%; height:600px; margin:0 auto;"></div>
    <button id="refreshBtn" class="btn btn-primary mt-4">수동 새로고침</button>
</div>

<script>
    const apiOrigin = window.location.origin || (window.location.protocol + '//' + window.location.host);

    $(function() {
        //  world 지도 데이터를 먼저 로드
        Highcharts.getJSON('https://code.highcharts.com/mapdata/custom/world.geo.json', function (worldData) {

            let chart = Highcharts.mapChart('globe-container', {
                chart: {
                    map: worldData,
                    backgroundColor: '#ffffff',
                    projection: { name: 'Orthographic' },
                    animation: true
                },
                title: { text: ' 세계 주요 증시 변동률 (실시간)' },
                subtitle: { text: '데이터 출처: Yahoo Finance API via RapidAPI' },
                mapNavigation: { enabled: true, enableDoubleClickZoomTo: true },
                legend: { layout: 'horizontal', verticalAlign: 'bottom' },

                colorAxis: {
                    min: -3,
                    max: 3,
                    stops: [
                        [0, '#2f7ed8'],  // 하락: 파랑
                        [0.5, '#cccccc'], // 보합
                        [1, '#d9534f']   // 상승: 빨강
                    ],
                    labels: { format: '{value}%' }
                },

                tooltip: {
                    pointFormat: '<b>{point.name}</b><br/>변동률: <b>{point.value}%</b>'
                },

                series: [{
                    data: [],
                    mapData: worldData,
                    joinBy: 'hc-key',
                    name: '변동률 (%)',
                    borderColor: '#ffffff',
                    borderWidth: 0.5,
                    states: { hover: { color: '#BADA55' } }
                }],

                credits: { enabled: false }
            });

            //  심볼 → 국가 코드 매핑 함수
            function mapSymbolToCountry(symbol) {
                const map = {
                    "^KS11": "KR",
                    "^N225": "JP",
                    "^DJI": "US",
                    "^IXIC": "US",
                    "^GSPC": "US",
                    "^GDAXI": "DE",
                    "000001.SS": "CN",
                    "^BSESN": "IN"
                };
                return map[symbol] || "US";
            }

            //  데이터 업데이트 함수
            function updateData() {
                console.log("🌐 글로벌 증시 데이터 갱신 중...");

                fetch(`${apiOrigin}/api/stocks/global`)
                    .then(res => res.json())
                    .then(data => {
                        if (!data.quoteResponse || !data.quoteResponse.result) return;

                        const results = data.quoteResponse.result.map(item => ({
                            country: mapSymbolToCountry(item.symbol).toLowerCase(),
                            change: parseFloat(item.regularMarketChangePercent || 0)
                        }));

                        const formatted = results.map(r => ({
                            'hc-key': r.country.toLowerCase(),  //  국가 코드 key
                            'value': r.change                   //  변동률
                        }));
                        console.log("📊 최신 데이터:", formatted);
                        chart.series[0].setData(formatted);
                    })
                    .catch(err => console.error("데이터 갱신 오류:", err));
            }

            //  초기 및 주기적 갱신
            updateData();
            setInterval(updateData, 10000);
            $('#refreshBtn').click(updateData);
        });
    });
</script>
