<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- ✅ Highcharts 라이브러리 -->
<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/exporting.js"></script>

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
</div>

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
      if (this.timer) clearInterval(this.timer); // 이전 타이머 중지
      this.createChart();                        // 차트 생성
      this.updateData();                         // 첫 데이터 즉시 가져오기
      this.timer = setInterval(() => this.updateData(), 5000); // 5초마다 갱신
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
      $.getJSON(`/api/stocks/${this.symbol}`, (data) => {
        if (data.error) {
          $('#result').html("<div style='color:red;'>" + data.error + "</div>");
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

        // ✅ 차트에 새 데이터 추가
        this.chart.series[0].addPoint([now, price], true, this.chart.series[0].data.length > 20);
      });
    }
  };

  $(() => stockLive.init());
</script>
