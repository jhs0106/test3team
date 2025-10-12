<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 운영 대시보드 --%>
<script>
  const operationDashboard = {
    baseUrl: '<c:out value="${operationBaseUrl}"/>',
    sse: null,
    reconnectTimer: null,
    chart: null,
    init() {
      this.buildChart();
      if (!this.baseUrl) {
        $('#operation-warning').removeClass('d-none');
        return;
      }
      this.connect();
    },
    resolve(path) {
      if (!this.baseUrl) {
        return path;
      }
      return this.baseUrl.replace(/\/+$/, '') + path;
    },
    connect() {
      const streamUrl = this.resolve('/api/operations/metrics/stream/admin');
      if (this.sse) {
        this.sse.close();
      }
      try {
        this.sse = new EventSource(streamUrl);
      } catch (err) {
        console.error('SSE 초기화 실패', err);
        this.scheduleReconnect();
        return;
      }
      this.sse.addEventListener('metrics', (event) => {
        try {
          const payload = JSON.parse(event.data);
          this.update(payload);
        } catch (parseError) {
          console.error('메트릭 파싱 실패', parseError);
        }
      });
      this.sse.onerror = () => {
        console.warn('SSE 연결 오류 - 재연결 시도');
        this.scheduleReconnect();
      };
    },
    scheduleReconnect() {
      if (this.sse) {
        this.sse.close();
      }
      if (this.reconnectTimer) {
        return;
      }
      this.reconnectTimer = setTimeout(() => {
        this.reconnectTimer = null;
        this.connect();
      }, 5000);
    },
    buildChart() {
      this.chart = Highcharts.chart('operation-3d-chart', {
        chart: {
          type: 'column',
          options3d: {
            enabled: true,
            alpha: 15,
            beta: 20,
            depth: 60,
            viewDistance: 50
          }
        },
        title: { text: '서비스 운영 지표 요약' },
        subtitle: { text: 'Drilldown으로 세부 데이터 확인' },
        xAxis: { type: 'category' },
        yAxis: { title: { text: '누적 수치' } },
        legend: { enabled: false },
        plotOptions: {
          series: {
            dataLabels: {
              enabled: true,
              format: '{point.y:,.0f}'
            }
          },
          column: {
            depth: 40
          }
        },
        series: [{
          name: 'Overview',
          colorByPoint: true,
          data: []
        }],
        drilldown: {
          breadcrumbs: {
            position: { align: 'right' }
          },
          series: []
        }
      });
    },
    update(snapshot) {
      if (!snapshot) {
        return;
      }
      $('#operation-warning').addClass('d-none');
      $('#operation-last-updated').text(this.formatTimestamp(snapshot.timestamp));
      $('#metric-totalLogins').text(this.formatNumber(snapshot.totalLogins));
      $('#metric-activeUsers').text(this.formatNumber(snapshot.activeUsers));
      $('#metric-stockRequests').text(this.formatNumber(snapshot.stockRequests));
      $('#metric-chatMessages').text(this.formatNumber(snapshot.chatMessages));
      $('#metric-stockFailures').text(this.formatNumber(snapshot.stockFailures));
      const failureRate = snapshot.stockRequests === 0 ? 0 : (snapshot.stockFailures / snapshot.stockRequests * 100);
      $('#metric-failureRate').text(failureRate.toFixed(0) + '%');
      this.updateChart(snapshot);
      this.updateAlerts(snapshot.alerts || []);
      this.updateActiveUsers(snapshot.activeUserIds || []);
    },
    updateChart(snapshot) {
      if (!this.chart) {
        return;
      }
      const overview = (snapshot.overview || []).map(item => ({
        name: item.name,
        y: item.y,
        drilldown: item.drilldown || null
      }));
      const drilldownSeries = (snapshot.drilldown || []).map(series => ({
        id: series.id,
        name: series.name,
        data: (series.data || []).map(point => [point.name, point.y])
      }));
      this.chart.series[0].setData(overview, false);
      this.chart.update({ drilldown: { series: drilldownSeries } }, false);
      this.chart.redraw();
    },
    updateAlerts(alerts) {
      const container = $('#operation-alerts');
      container.empty();
      if (!alerts.length) {
        $('#operation-alert-empty').removeClass('d-none');
        return;
      }
      $('#operation-alert-empty').addClass('d-none');
      alerts.forEach(alert => {
        const badge = this.resolveBadge(alert.level);
        const item = $('<div/>', {
          class: 'list-group-item list-group-item-action flex-column align-items-start'
        });
        const header = $('<div/>', { class: 'd-flex w-100 justify-content-between' });
        header.append($('<h6/>', { class: 'mb-1', text: alert.message }));
        header.append($('<span/>', { class: `badge badge-${badge}`, text: alert.level.toUpperCase() }));
        const timestamp = $('<small/>', {
          class: 'text-muted',
          text: this.formatTimestamp(alert.timestamp)
        });
        item.append(header);
        item.append(timestamp);
        container.append(item);
      });
    },
    updateActiveUsers(users) {
      const container = $('#operation-active-users');
      container.empty();
      if (!users.length) {
        container.append('<li class="list-group-item">현재 접속 중인 사용자가 없습니다.</li>');
        return;
      }
      users.forEach(user => {
        container.append(`<li class="list-group-item"><i class="fas fa-user mr-2 text-primary"></i>${user}</li>`);
      });
    },
    formatNumber(value) {
      return (value ?? 0).toLocaleString();
    },
    formatTimestamp(value) {
      if (!value) {
        return '-';
      }
      try {
        return new Date(value).toLocaleString();
      } catch (err) {
        return value;
      }
    },
    resolveBadge(level) {
      switch ((level || '').toLowerCase()) {
        case 'danger':
          return 'danger';
        case 'warning':
          return 'warning';
        case 'info':
          return 'info';
        default:
          return 'secondary';
      }
    }
  };

  $(function () {
    operationDashboard.init();
  });
</script>

<div class="container-fluid">
  <div class="d-sm-flex align-items-center justify-content-between mb-4">
    <h1 class="h3 mb-0 text-gray-800">운영 대시보드</h1>
    <span class="text-muted small">마지막 갱신: <span id="operation-last-updated">-</span></span>
  </div>

  <div id="operation-warning" class="alert alert-warning d-none">
    운영 데이터 엔드포인트가 설정되지 않았습니다. <code>app.url.operationbase</code> 값을 확인해주세요.
  </div>

  <div class="row">
    <div class="col-xl-3 col-md-6 mb-4">
      <div class="card border-left-primary shadow h-100 py-2">
        <div class="card-body">
          <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">누적 로그인</div>
          <div id="metric-totalLogins" class="h5 mb-0 font-weight-bold text-gray-800">0</div>
        </div>
      </div>
    </div>
    <div class="col-xl-3 col-md-6 mb-4">
      <div class="card border-left-success shadow h-100 py-2">
        <div class="card-body">
          <div class="text-xs font-weight-bold text-success text-uppercase mb-1">동시 접속자</div>
          <div id="metric-activeUsers" class="h5 mb-0 font-weight-bold text-gray-800">0</div>
        </div>
      </div>
    </div>
    <div class="col-xl-3 col-md-6 mb-4">
      <div class="card border-left-info shadow h-100 py-2">
        <div class="card-body">
          <div class="text-xs font-weight-bold text-info text-uppercase mb-1">주가 조회</div>
          <div id="metric-stockRequests" class="h5 mb-0 font-weight-bold text-gray-800">0</div>
          <div class="small text-muted">실패 <span id="metric-stockFailures">0</span> / 실패율 <span id="metric-failureRate">0%</span></div>
        </div>
      </div>
    </div>
    <div class="col-xl-3 col-md-6 mb-4">
      <div class="card border-left-warning shadow h-100 py-2">
        <div class="card-body">
          <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">채팅 메시지</div>
          <div id="metric-chatMessages" class="h5 mb-0 font-weight-bold text-gray-800">0</div>
        </div>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-xl-8 col-lg-7">
      <div class="card shadow mb-4">
        <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
          <h6 class="m-0 font-weight-bold text-primary">3D 드릴다운 운영 지표</h6>
        </div>
        <div class="card-body">
          <div id="operation-3d-chart" style="height: 420px;"></div>
        </div>
      </div>
    </div>
    <div class="col-xl-4 col-lg-5">
      <div class="card shadow mb-4">
        <div class="card-header py-3">
          <h6 class="m-0 font-weight-bold text-primary">실시간 경보</h6>
        </div>
        <div class="card-body">
          <div id="operation-alert-empty" class="text-muted">현재 경보가 없습니다.</div>
          <div id="operation-alerts" class="list-group list-group-flush"></div>
        </div>
      </div>
      <div class="card shadow mb-4">
        <div class="card-header py-3">
          <h6 class="m-0 font-weight-bold text-primary">실시간 접속자</h6>
        </div>
        <ul id="operation-active-users" class="list-group list-group-flush"></ul>
      </div>
    </div>
  </div>
</div>