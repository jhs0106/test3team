<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 운영 대시보드 --%>
<script>
  const operationDashboard = {
    baseUrl: '<c:out value="${operationBaseUrl}"/>',
    sse: null,
    reconnectTimer: null,
    chart: null,
    alertHashes: new Set(),
    initialized: false,
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

      const handleMetrics = event => {
        if (!event || !event.data) {
          return;
        }
        try {
          const snapshot = JSON.parse(event.data);
          this.update(snapshot);
        } catch (err) {
          console.error('데이터 파싱 실패', err);
        }
      };

      this.sse.addEventListener('metrics', handleMetrics);
      this.sse.addEventListener('connect', event => {
        if (event && event.data) {
          console.debug('SSE 연결 상태:', event.data);
        }
      });
      this.sse.onmessage = handleMetrics;
      this.sse.onerror = err => {
        console.error('SSE 오류', err);
        this.scheduleReconnect();
      };
    },
    scheduleReconnect() {
      if (this.reconnectTimer) return;
      this.reconnectTimer = setTimeout(() => {
        this.reconnectTimer = null;
        this.connect();
      }, 5000);
    },
    buildChart() {
      this.chart = Highcharts.chart('operation-3d-chart', {
        chart: {
          type: 'column',
          options3d: { enabled: true, alpha: 10, beta: 15, depth: 50 },
          backgroundColor: 'transparent'
        },
        title: { text: '' },
        xAxis: { type: 'category' },
        yAxis: { title: { text: null } },
        legend: { enabled: false },
        plotOptions: { column: { depth: 25 } },
        series: [{ name: '운영 지표', colorByPoint: true, data: [] }],
        drilldown: { breadcrumbs: { position: { align: 'right' } }, series: [] }
      });
    },
    update(snapshot) {
      if (!snapshot) return;
      $('#operation-warning').addClass('d-none');
      $('#operation-last-updated').text(this.formatTimestamp(snapshot.timestamp));
      $('#metric-totalLogins').text(this.formatNumber(snapshot.totalLogins));
      $('#metric-activeUsers').text(this.formatNumber(snapshot.activeUsers));
      $('#metric-chartRequests').text(this.formatNumber(snapshot.chartRequests));
      $('#metric-chatMessages').text(this.formatNumber(snapshot.chatMessages));
      $('#metric-chartFailures').text(this.formatNumber(snapshot.chartFailures));
      const failureRate = snapshot.chartRequests === 0 ? 0 : (snapshot.chartFailures / snapshot.chartRequests * 100);
      this.updateFailureStatus(failureRate);
      this.updateChart(snapshot);
      this.updateAlerts(snapshot.alerts || []);
      this.updateActiveUsers(snapshot.activeUserIds || []);
      this.updateInsights(snapshot, failureRate);;
      this.initialized = true;
    },
    updateChart(snapshot) {
      if (!this.chart) return;
      const overview = (snapshot.overview || []).map(item => ({
        name: item.name, y: item.y, drilldown: item.drilldown || null
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
      const nextHashes = new Set();
      alerts.forEach(alert => {
        const signature = this.alertSignature(alert);
        nextHashes.add(signature);
        if (this.initialized && !this.alertHashes.has(signature)) {
          this.pushAlertToast(alert);
        }
        const badge = this.resolveBadge(alert.level);
        const item = $('<div/>', { class: 'list-group-item list-group-item-action flex-column align-items-start' });
        const header = $('<div/>', { class: 'd-flex w-100 justify-content-between' });
        header.append($('<h6/>', { class: 'mb-1', text: alert.message }));
        header.append($('<span/>', { class: 'badge badge-' + badge, text: alert.level.toUpperCase() }));
        const timestamp = $('<small/>', { class: 'text-muted', text: this.formatTimestamp(alert.timestamp) });
        item.append(header);
        item.append(timestamp);
        container.append(item);
      });
      this.alertHashes = nextHashes;
    },
    updateActiveUsers(users) {
      const container = $('#operation-active-users');
      container.empty();
      if (!users.length) {
        container.append('<li class="list-group-item">현재 접속 중인 사용자가 없습니다.</li>');
        return;
      }
      users.forEach(user => {
        container.append('<li class="list-group-item"><i class="fas fa-user mr-2 text-primary"></i>' + user + '</li>');
      });
    },
    updateInsights(snapshot, failureRate) {
      const drilldownIndex = this.buildDrilldownIndex(snapshot.drilldown || []);
      this.updateLoginTrend(drilldownIndex);
      this.updateChartHighlights(snapshot.chartHighlights || [], drilldownIndex);
      this.updateRankedList('operation-top-chats', drilldownIndex, ['chats', 'chat', '채팅', '메시지'], '채팅 메시지가 아직 없습니다.', '건');
      this.updateInsightSummary(snapshot, drilldownIndex, failureRate);
    },
    updateLoginTrend(drilldownIndex) {
      const series = this.findSeries(drilldownIndex, ['logins', 'login', '접속', '시간대별 접속자']);
      const list = $('#operation-login-trend');
      list.empty();
      if (!series) {
        this.renderEmptyState(list, '접속 추세 데이터가 없습니다.');
        this.updateLoginTrendSummary();
        return;
      }
      const points = this.normalizePoints(series).slice(-5);
      if (!points.length) {
        this.renderEmptyState(list, '접속 추세 데이터가 없습니다.');
        this.updateLoginTrendSummary();
        return;
      }
      const latest = points[points.length - 1];
      const previous = points.length > 1 ? points[points.length - 2] : null;
      this.updateLoginTrendSummary(latest, previous);
      points.slice().reverse().forEach(point => {
        const item = $('<li/>', { class: 'list-group-item d-flex justify-content-between align-items-center' });
        item.append($('<span/>', { text: point.name }));
        item.append($('<span/>', { class: 'font-weight-bold', text: this.formatNumber(point.y) }));
        list.append(item);
      });
    },
    updateLoginTrendSummary(latest, previous) {
      const latestValue = latest ? latest.y : 0;
      const delta = latest && previous ? latest.y - previous.y : 0;
      $('#operation-login-latest').text(this.formatNumber(latestValue));
      const deltaEl = $('#operation-login-delta');
      let deltaClass = 'text-muted';
      if (delta > 0) deltaClass = 'text-success';
      else if (delta < 0) deltaClass = 'text-danger';
      deltaEl.removeClass('text-success text-danger text-muted').addClass(deltaClass);
      const formattedDelta = (delta >= 0 ? '+' : '') + this.formatNumber(delta);
      deltaEl.text(formattedDelta);
    },
    updateRankedList(elementId, drilldownIndex, keys, emptyMessage, unit) {
      const series = this.findSeries(drilldownIndex, keys);
      const list = $('#' + elementId);
      list.empty();
      if (!series) {
        this.renderEmptyState(list, emptyMessage);
        return;
      }
      const points = this.normalizePoints(series).filter(point => point.y > 0);
      if (!points.length) {
        this.renderEmptyState(list, emptyMessage);
        return;
      }
      points
              .sort((a, b) => b.y - a.y)
              .slice(0, 5)
              .forEach((point, index) => {
                const item = $('<li/>', { class: 'list-group-item d-flex justify-content-between align-items-center' });
                item.append($('<span/>')
                        .append($('<span/>', { class: 'badge badge-secondary badge-pill mr-2', text: (index + 1) }))
                        .append(document.createTextNode(point.name)));
                item.append($('<span/>', { class: 'font-weight-bold', text: this.formatNumber(point.y) + unit }));
                list.append(item);
              });
    },
    updateChartHighlights(highlights, drilldownIndex) {
      const list = $('#operation-top-charts');
      list.empty();
      const hasHighlights = Array.isArray(highlights) && highlights.length > 0;
      if (!hasHighlights) {
        const fallback = this.findSeries(drilldownIndex, ['charts', 'stocks', 'stock', '종목', '주가']);
        if (!fallback) {
          this.renderEmptyState(list, '차트 조회 데이터가 없습니다.');
          return;
        }
        const points = this.normalizePoints(fallback).filter(point => point.y > 0);
        if (!points.length) {
          this.renderEmptyState(list, '차트 조회 데이터가 없습니다.');
          return;
        }
        points
                .sort((a, b) => b.y - a.y)
                .slice(0, 5)
                .forEach((point, index) => {
                  const item = $('<li/>', { class: 'list-group-item d-flex justify-content-between align-items-center' });
                  item.append($('<span/>')
                          .append($('<span/>', { class: 'badge badge-secondary badge-pill mr-2', text: (index + 1) }))
                          .append(document.createTextNode(point.name)));
                  item.append($('<span/>', { class: 'font-weight-bold', text: this.formatNumber(point.y) + '회' }));
                  list.append(item);
                });
        return;
      }

      highlights.slice(0, 5).forEach((item, index) => {
        const listItem = $('<li/>', { class: 'list-group-item' });
        const header = $('<div/>', { class: 'd-flex justify-content-between align-items-center' });
        const title = $('<div/>', { class: 'd-flex align-items-center' });
        title.append($('<span/>', { class: 'badge badge-secondary badge-pill mr-2', text: index + 1 }));
        title.append($('<strong/>', { text: item.name || item.symbol }));
        title.append($('<small/>', { class: 'text-muted ml-2', text: item.symbol }));

        const changeValue = Number(item.changePercent || 0);
        const changeClass = changeValue > 0 ? 'text-danger' : changeValue < 0 ? 'text-primary' : 'text-muted';
        const changeIcon = changeValue > 0 ? 'fa-arrow-up' : changeValue < 0 ? 'fa-arrow-down' : 'fa-minus';
        const changeText = (changeValue > 0 ? '+' : changeValue < 0 ? '' : '') + changeValue.toFixed(2) + '%';

        const changeContainer = $('<div/>', { class: 'text-right' });
        changeContainer.append($('<span/>', {
          class: 'font-weight-bold ' + changeClass,
          html: '<i class="fas ' + changeIcon + ' mr-1"></i>' + changeText
        }));
        changeContainer.append($('<div/>', {
          class: 'small text-muted',
          text: '요청 ' + this.formatNumber(item.requestCount || 0)
        }));

        header.append(title);
        header.append(changeContainer);
        listItem.append(header);

        const metricsRow = $('<div/>', { class: 'd-flex justify-content-between text-muted small mt-2 flex-wrap', style: 'gap: .5rem;' });
        metricsRow.append($('<span/>', { text: '가격 ' + this.formatNumber(item.lastPrice, 2) + ' KRW' }));
        metricsRow.append($('<span/>', { text: '거래량 ' + this.formatNumber(item.volume || 0) }));
        metricsRow.append($('<span/>', { text: '시총 ' + this.formatNumber(item.marketCap || 0) }));
        listItem.append(metricsRow);

        const updatedAt = item.updatedAt ? this.formatTimestamp(item.updatedAt) : '-';
        listItem.append($('<div/>', { class: 'text-muted small mt-1', text: '업데이트 ' + updatedAt }));

        list.append(listItem);
      });
    },
    renderEmptyState(container, message) {
      container.append($('<li/>', { class: 'list-group-item text-muted', text: message }));
    },
    buildDrilldownIndex(seriesList) {
      const index = {};
      seriesList.forEach(series => {
        const keyCandidates = [series.id, series.name]
                .filter(Boolean)
                .map(value => value.toString().toLowerCase());
        keyCandidates.forEach(key => { index[key] = series; });
      });
      return index;
    },
    findSeries(index, keys) {
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        if (!key) continue;
        const normalized = key.toString().toLowerCase();
        if (index[normalized]) return index[normalized];
      }
      return null;
    },
    normalizePoints(series) {
      if (!series || !Array.isArray(series.data)) return [];
      return series.data.map(point => {
        if (Array.isArray(point)) {
          return { name: point[0], y: Number(point[1] || 0) };
        }
        return { name: point.name, y: Number(point.y || 0) };
      });
    },
    updateFailureStatus(failureRate) {
      const state = this.resolveFailureState(failureRate);
      const normalized = this.clampRate(failureRate);
      const statusEl = $('#operation-failure-status');
      if (statusEl.length) {
        statusEl.removeClass('text-success text-warning text-danger')
                .addClass(state.textClass)
                .text(state.label);
      }
      const rateEl = $('#metric-failureRate');
      if (rateEl.length) {
        rateEl.removeClass('text-success text-warning text-danger')
                .addClass(state.textClass)
                .text(normalized.toFixed(1) + '%');
      }
      const progressEl = $('#operation-failure-progress');
      if (progressEl.length) {
        progressEl.attr('aria-valuenow', normalized.toFixed(0))
                .css('width', normalized.toFixed(0) + '%')
                .removeClass('bg-success bg-warning bg-danger')
                .addClass(state.progressClass);
      }
    },
    updateInsightSummary(snapshot, drilldownIndex, failureRate) {
      const list = $('#operation-insights');
      if (!list.length) return;
      list.empty();

      const insights = [];
      const totalLogins = Number(snapshot.totalLogins || 0);
      insights.push({ icon: 'sign-in-alt', text: '누적 로그인 ' + this.formatNumber(totalLogins) + '회' });

      const activeUsers = Number(snapshot.activeUsers || 0);
      const loginSeries = this.findSeries(drilldownIndex, ['logins', 'login', '접속', '시간대별 접속자']);
      const loginPoints = this.normalizePoints(loginSeries);
      if (loginPoints.length) {
        const latest = loginPoints[loginPoints.length - 1];
        const previous = loginPoints.length > 1 ? loginPoints[loginPoints.length - 2] : null;
        let text = '동시 접속자 ' + this.formatNumber(activeUsers) + '명';
        if (previous) {
          const delta = latest.y - previous.y;
          if (delta > 0) {
            text += ' (최근 +' + this.formatNumber(delta) + '명 증가)';
          } else if (delta < 0) {
            text += ' (최근 ' + this.formatNumber(Math.abs(delta)) + '명 감소)';
          } else {
            text += ' (변동 없음)';
          }
        }
        insights.push({ icon: 'users', text: text });
      }

      const topStock = this.pickTopPoint(drilldownIndex, ['stocks', 'stock', '종목', '주가']);
      if (topStock) {
        insights.push({ icon: 'chart-line', text: '가장 많이 조회된 종목: ' + topStock.name + ' (' + this.formatNumber(topStock.y) + '회)' });
      }

      const topChat = this.pickTopPoint(drilldownIndex, ['chats', 'chat', '채팅', '메시지']);
      if (topChat) {
        insights.push({ icon: 'comments', text: '가장 활발한 채팅방: ' + topChat.name + ' (' + this.formatNumber(topChat.y) + '건)' });
      }

      const failureState = this.resolveFailureState(failureRate);
      insights.push({
        icon: 'heartbeat',
        text: '주가 API 상태: ' + failureState.label + ' (실패율 ' + this.clampRate(failureRate).toFixed(1) + '%)',
        className: failureState.textClass
      });

      if (!insights.length) {
        list.append($('<li/>', { class: 'text-muted', text: '데이터를 수집 중입니다.' }));
        return;
      }

      insights.forEach(insight => {
        const item = $('<li/>', { class: 'd-flex align-items-center mb-2' });
        item.append($('<i/>', { class: 'fas fa-' + insight.icon + ' text-primary mr-2' }));
        const text = $('<span/>', { text: insight.text });
        if (insight.className) {
          text.addClass(insight.className);
        }
        item.append(text);
        list.append(item);
      });
    },
    pickTopPoint(drilldownIndex, keys) {
      const series = this.findSeries(drilldownIndex, keys);
      if (!series) return null;
      const points = this.normalizePoints(series).filter(point => point.y > 0);
      if (!points.length) return null;
      return points.reduce((best, current) => current.y > best.y ? current : best, points[0]);
    },
    resolveFailureState(rate) {
      const value = this.clampRate(rate);
      if (value >= 30) {
        return { label: '위험', textClass: 'text-danger', progressClass: 'bg-danger' };
      }
      if (value >= 15) {
        return { label: '주의', textClass: 'text-warning', progressClass: 'bg-warning' };
      }
      return { label: '안정', textClass: 'text-success', progressClass: 'bg-success' };
    },
    clampRate(value) {
      if (!Number.isFinite(value)) {
        return 0;
      }
      return Math.max(0, Math.min(100, value));
    },
    formatNumber(value, fractionDigits) {
      const number = Number(value ?? 0);
      if (Number.isNaN(number)) return '0';
      if (typeof fractionDigits === 'number') {
        return number.toLocaleString(undefined, { minimumFractionDigits: 0, maximumFractionDigits: fractionDigits });
      }
      return number.toLocaleString();
    },
    formatTimestamp(value) {
      if (!value) return '-';
      try { return new Date(value).toLocaleString(); }
      catch (err) { return value; }
    },
    resolveBadge(level) {
      switch ((level || '').toLowerCase()) {
        case 'danger': return 'danger';
        case 'warning': return 'warning';
        case 'info': return 'info';
        default: return 'secondary';
      }
    },
    alertSignature(alert) {
      return [alert.level, alert.message, alert.timestamp].join('|');
    },
    pushAlertToast(alert) {
      const container = $('#operation-alert-toasts');
      if (!container.length) return;
      const badge = this.resolveBadge(alert.level);

      // 문자열 연결 방식으로 생성 (JSP EL 충돌 방지)
      const html =
              '<div class="toast" role="alert" aria-live="assertive" aria-atomic="true" data-delay="6000">' +
              '<div class="toast-header">' +
              '<span class="badge badge-' + badge + ' mr-2">&nbsp;</span>' +
              '<strong class="mr-auto">운영 알림</strong>' +
              '<small>' + this.formatTimestamp(alert.timestamp) + '</small>' +
              '<button type="button" class="ml-2 mb-1 close" data-dismiss="toast" aria-label="Close">' +
              '<span aria-hidden="true">&times;</span>' +
              '</button>' +
              '</div>' +
              '<div class="toast-body">' + alert.message + '</div>' +
              '</div>';

      const toast = $(html);
      container.append(toast);

      if (typeof toast.toast === 'function') {
        toast.toast({ autohide: true, delay: 6000 });
        toast.on('hidden.bs.toast', function () { $(this).remove(); });
        toast.toast('show');
      } else {
        container.append($('<div/>', {
          class: 'alert alert-' + badge + ' alert-dismissible fade show mt-2',
          role: 'alert',
          html: alert.message + '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>'
        }));
      }
    }
  };

  $(function () {
    operationDashboard.init();
  });
</script>


<div class="container-fluid">
  <div aria-live="polite" aria-atomic="true" class="position-fixed" style="top: 1rem; right: 1rem; z-index: 1080;">
    <div id="operation-alert-toasts"></div>
  </div>

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
          <div class="text-xs font-weight-bold text-info text-uppercase mb-1">차트 조회</div>
          <div id="metric-chartRequests" class="h5 mb-0 font-weight-bold text-gray-800">0</div>
          <div class="text-xs text-muted mt-2">
            실패 <span id="metric-chartFailures">0</span>건 · 실패율 <span id="metric-failureRate">0%</span>
          </div>
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
    <div class="col-xl-3 col-md-6 mb-4">
      <div class="card border-left-danger shadow h-100 py-2">
        <div class="card-body">
          <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">주가 요청 실패</div>
          <div class="d-flex justify-content-between align-items-baseline">
            <div id="metric-stockFailures" class="h5 mb-0 font-weight-bold text-gray-800">0</div>
            <div id="operation-failure-status" class="small font-weight-bold text-success">안정</div>
          </div>
          <div class="text-xs text-muted mt-2">실패율 <span id="metric-failureRate" class="font-weight-bold">0%</span></div>
          <div class="progress progress-sm mt-2">
            <div id="operation-failure-progress" class="progress-bar bg-success" role="progressbar" style="width: 0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-xl-9 col-md-6 mb-4">
      <div class="card shadow h-100">
        <div class="card-header py-3 d-flex align-items-center justify-content-between">
          <h6 class="m-0 font-weight-bold text-primary">운영 인사이트</h6>
          <span class="text-xs text-muted">실시간 데이터 기반 주요 지표</span>
        </div>
        <div class="card-body">
          <ul id="operation-insights" class="list-unstyled mb-0">
            <li class="text-muted">데이터를 수집 중입니다.</li>
          </ul>
        </div>
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-xl-8 col-lg-7">
      <div class="card shadow mb-4">
        <div class="card-header py-3">
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

  <div class="row">
    <div class="col-xl-4 col-lg-6">
      <div class="card shadow mb-4 h-100">
        <div class="card-header py-3">
          <h6 class="m-0 font-weight-bold text-primary">실시간 접속 추세</h6>
        </div>
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center">
            <div>
              <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">현재 동시 접속</div>
              <div id="operation-login-latest" class="h4 mb-0 font-weight-bold text-gray-800">0</div>
            </div>
            <div class="text-right">
              <div class="text-xs font-weight-bold text-muted text-uppercase mb-1">증감</div>
              <div id="operation-login-delta" class="h5 mb-0 font-weight-bold text-muted">+0</div>
            </div>
          </div>
        </div>
        <ul id="operation-login-trend" class="list-group list-group-flush small"></ul>
      </div>
    </div>
    <div class="col-xl-4 col-lg-6">
      <div class="card shadow mb-4 h-100">
        <div class="card-header py-3">
          <h6 class="m-0 font-weight-bold text-primary">차트 조회 TOP 5</h6>
        </div>
        <ul id="operation-top-charts" class="list-group list-group-flush"></ul>
      </div>
    </div>
    <div class="col-xl-4 col-lg-6">
      <div class="card shadow mb-4 h-100">
        <div class="card-header py-3">
          <h6 class="m-0 font-weight-bold text-primary">활발한 채팅방</h6>
        </div>
        <ul id="operation-top-chats" class="list-group list-group-flush"></ul>
      </div>
    </div>
  </div>
</div>
