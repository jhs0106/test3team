<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="true" %>

<style>
  #result {
    width: 400px;
    border: 2px solid red;
    padding: 10px;
    margin-top: 15px;
    background: #fff;
    color: #000;
    position: relative;
    z-index: 9999;
  }
</style>

<script>
  let stock1 = {
    init:function() {
      $('#get_btn').click(()=>{
        let symbol = $('#symbol').val().trim();
        if(symbol === ''){
          alert('종목 코드를 입력하세요. (예: 005930)');
          return;
        }
        this.getData(symbol);
      });
    },

    getData:function(symbol) {
      $.ajax({
        url: '<c:url value="/api/stocks/"/>' + symbol,
        method: 'GET',
        success:(data)=>{
          console.log("API 응답:", data);

          if (data.quoteResponse && data.quoteResponse.result) {
            data = data.quoteResponse.result[0];
          }

          this.display(data);
        },
        error:(xhr, status, err)=>{
          console.error("API 요청 오류:", err);
          $('#result').html("<div style='color:red;'>데이터를 불러오는 중 오류가 발생했습니다.</div>");
        }
      });
    },

    display:function(data) {
      if(!data || data.error){
        $('#result').html("<div style='color:red;'>데이터가 없습니다.</div>");
        return;
      }

      const safeNumber = v => (typeof v === 'number' ? v : parseFloat(v));

      let name = data.longName || data.shortName || data.symbol;
      let price = data.regularMarketPrice ? safeNumber(data.regularMarketPrice).toLocaleString() : '-';
      let change = data.regularMarketChangePercent ? safeNumber(data.regularMarketChangePercent).toFixed(2) : '0.00';
      let volume = data.regularMarketVolume ? safeNumber(data.regularMarketVolume).toLocaleString() : '-';
      let marketCap = data.marketCap ? safeNumber(data.marketCap).toLocaleString() : '-';
      let range = data.fiftyTwoWeekRange || '-';

      let color = (parseFloat(change) >= 0) ? 'red' : 'blue';
      let sign = (parseFloat(change) >= 0) ? '▲' : '▼';

      // ✅ 이제 진짜 자바스크립트 템플릿 리터럴
      let html = `
        <h4 style="color:black;">${name}</h4>
        <p style="font-size:1.5em; color:${color}; font-weight:bold;">
          ${price} KRW ${sign}${change}%
        </p>
        <table border="1" width="100%" style="text-align:center; border-collapse:collapse; color:black;">
          <tr><th>거래량</th><td>${volume}</td></tr>
          <tr><th>시가총액</th><td>${marketCap}</td></tr>
          <tr><th>52주 범위</th><td>${range}</td></tr>
        </table>
      `;
      $('#result').html(html);
    }
  }

  $(function() {
    stock1.init();
  });
</script>

<div class="col-sm-10">
  <h2>📈 실시간 주가 정보</h2>
  <input id="symbol" value="005930" placeholder="예: 005930">
  <button id="get_btn">조회</button>
  <div id="result">결과가 여기에 표시됩니다.</div>
</div>
