<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div id="operations-dashboard" class="container-fluid px-0">
  <style>
    #operations-dashboard {
      color: #1f2933;
    }
    #operations-dashboard .dashboard-header {
      display: flex;
      flex-direction: column;
      gap: 4px;
      margin-bottom: 20px;
    }
    #operations-dashboard .dashboard-header h2 {
      font-weight: 700;
      margin: 0;
    }
    #operations-dashboard .dashboard-header .meta {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      font-size: 0.9rem;
      color: #52606d;
    }
    #operations-dashboard .summary-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
      gap: 12px;
      margin-bottom: 20px;
    }
    #operations-dashboard .summary-card {
      background: linear-gradient(145deg, #f8fafc, #e5e9f2);
      border-radius: 12px;
      padding: 14px;
      box-shadow: inset 0 1px 0 rgba(255,255,255,0.6), 0 4px 10px rgba(15,23,42,0.08);
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    #operations-dashboard .summary-card .label {
      font-size: 0.85rem;
      color: #52606d;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    #operations-dashboard .summary-card .value {
      font-size: 1.4rem;
      font-weight: 700;
      color: #0b7285;
    }
    #operations-dashboard .summary-card .sub-value {
      font-size: 0.85rem;
      color: #7b8794;
    }
    #operations-dashboard .card-panel {
      background: #ffffff;
      border-radius: 16px;
      padding: 18px;
      margin-bottom: 20px;
      box-shadow: 0 12px 30px rgba(15,23,42,0.1);
    }
    #operations-dashboard #production-3d {
      height: 420px;
    }
    #operations-dashboard table {
      width: 100%;
      border-collapse: collapse;
    }
    #operations-dashboard table thead {
      background: #e2e8f0;
    }
    #operations-dashboard table th,
    #operations-dashboard table td {
      padding: 10px 12px;
      border-bottom: 1px solid #cbd5e1;
      font-size: 0.92rem;
    }
    #operations-dashboard .status-pill {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      border-radius: 999px;
      font-weight: 600;
      padding: 4px 10px;
      font-size: 0.8rem;
    }
    #operations-dashboard .status-pill.normal {
      background: rgba(34,197,94,0.12);
      color: #166534;
    }
    #operations-dashboard .status-pill.warning {
      background: rgba(250,204,21,0.18);
      color: #92400e;
    }
    #operations-dashboard .status-pill.critical {
      background: rgba(248,113,113,0.2);
      color: #991b1b;
    }
    #operations-dashboard .alerts-list {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    #operations-dashboard .alerts-list .alert-item {
      border-radius: 12px;
      padding: 12px 14px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 12px;
      font-size: 0.9rem;
    }
    #operations-dashboard .alerts-list .alert-item.warning {
      background: linear-gradient(120deg, rgba(251,191,36,0.15), rgba(253,224,71,0.25));
      color: #854d0e;
    }
    #operations-dashboard .alerts-list .alert-item.critical {
      background: linear-gradient(120deg, rgba(248,113,113,0.2), rgba(252,165,165,0.25));
      color: #7f1d1d;
    }
    #operations-dashboard .alerts-list .alert-item.info {
      background: linear-gradient(120deg, rgba(125,211,252,0.18), rgba(191,219,254,0.2));
      color: #0c4a6e;
    }
    #operations-dashboard .connection-chip {
      padding: 4px 10px;
      border-radius: 999px;
      font-weight: 600;
      font-size: 0.8rem;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }
    #operations-dashboard .connection-chip.connected {
      background: rgba(34,197,94,0.12);
      color: #047857;
    }
    #operations-dashboard .connection-chip.reconnecting {
      background: rgba(251,191,36,0.16);
      color: #92400e;
    }
    #operations-dashboard .connection-chip.disconnected {
      background: rgba(248,113,113,0.2);
      color: #991b1b;
    }
  </style>

  <div class="dashboard-header">
    <h2>운영 대시보드</h2>
    <div class="meta">
      <div>유저 서비스 SSE 스트림: <span id="connection-status" class="connection-chip disconnected">연결 대기</span></div>
      <div>최근 갱신: <span id="last-updated">-</span></div>
    </div>
  </div>

  <div class="summary-grid">
    <div class="summary-card" id="metric-throughput">
      <div class="label">총 처리량</div>
      <div class="value">-</div>
      <div class="sub-value">UPH</div>
    </div>
    <div class="summary-card" id="metric-availability">
      <div class="label">평균 가동률</div>
      <div class="value">-</div>
      <div class="sub-value">%</div>
    </div>
    <div class="summary-card" id="metric-quality">
      <div class="label">평균 품질</div>
      <div class="value">-</div>
      <div class="sub-value">%</div>
    </div>
    <div class="summary-card" id="metric-energy">
      <div class="label">에너지 사용량</div>
      <div class="value">-</div>
      <div class="sub-value">MWh</div>
    </div>
    <div class="summary-card" id="metric-downtime">
      <div class="label">다운타임</div>
      <div class="value">-</div>
      <div class="sub-value">분</div>
    </div>
    <div class="summary-card" id="metric-alerts">
      <div class="label">경보 현황</div>
      <div class="value">-</div>
      <div class="sub-value">Critical / Warning</div>
    </div>
  </div>

  <div class="card-panel">
    <h5 style="font-weight:600; margin-bottom:12px;">설비 처리량</h5>
    <div id="production-3d"></div>
  </div>

  <div class="card-panel">
    <h5 style="font-weight:600; margin-bottom:12px;">라인별 실적</h5>
    <div class="table-responsive">
      <table>
        <thead>
        <tr>
          <th>설비</th>
          <th>라인</th>
          <th>처리량(UPH)</th>
          <th>가동률(%)</th>
          <th>품질(%)</th>
          <th>온도(°C)</th>
          <th>상태</th>
        </tr>
        </thead>
        <tbody id="line-status-body">
        <tr><td colspan="7" style="text-align:center; padding:16px;">데이터 수신 대기 중...</td></tr>
        </tbody>
      </table>
    </div>
  </div>

  <div class="card-panel">
    <h5 style="font-weight:600; margin-bottom:12px;">실시간 경보</h5>
    <div id="alerts-list" class="alerts-list">
      <div class="alert-item info">경보 데이터 수신 대기 중...</div>
    </div>
  </div>

  <script>
    (function() {
      const baseUrl = (function() {
        const configured = '<c:out value="${dashboardSseUrl}"/>';
        if (configured && configured !== 'null' && configured !== '') {
          return configured;
        }
        return '<c:url value="/api/sse/dashboard"/>';
      })();

      const dashboard = {
        eventSource: null,
        clientId: null,
        reconnectDelay: 5000,
        productionChart: null,
        init: function() {
          this.initChart();
          this.connect();
        },
        initChart: function() {
          this.productionChart = Highcharts.chart('production-3d', {
            chart: {
              type: 'column',
              options3d: {
                enabled: true,
                alpha: 12,
                beta: 18,
                depth: 220,
                viewDistance: 35
              },
              backgroundColor: 'rgba(255,255,255,0.0)'
            },
            title: { text: null },
            xAxis: {
              categories: [],
              crosshair: true,
              labels: { style: { fontWeight: '600' } }
            },
            yAxis: {
              min: 0,
              title: { text: '처리량 (UPH)' }
            },
            tooltip: {
              useHTML: true,
              formatter: function() {
                const extra = this.point.custom || {};
                let html = '<strong>' + (this.point.name || this.x) + '</strong><br/>';
                html += '처리량: <b>' + Highcharts.numberFormat(this.y, 1) + '</b> UPH<br/>';
                if (extra.availability) {
                  html += '가동률: ' + Highcharts.numberFormat(extra.availability, 1) + '%<br/>';
                }
                if (extra.quality) {
                  html += '품질: ' + Highcharts.numberFormat(extra.quality, 1) + '%<br/>';
                }
                if (extra.temperature) {
                  html += '온도: ' + Highcharts.numberFormat(extra.temperature, 1) + '°C';
                }
                return html;
              }
            },
            plotOptions: {
              column: {
                depth: 60,
                dataLabels: {
                  enabled: true,
                  formatter: function() {
                    return Highcharts.numberFormat(this.y, 0);
                  }
                }
              }
            },
            drilldown: {
              allowPointDrilldown: true,
              series: []
            },
            series: [{
              name: '라인 처리량',
              colorByPoint: true,
              data: []
            }]
          });
        },
        connect: function() {
          if (this.eventSource) {
            this.eventSource.close();
          }
          this.updateConnectionStatus('연결 중...', 'reconnecting');

          const url = this.buildUrl();
          this.eventSource = new EventSource(url);

          this.eventSource.addEventListener('connected', (event) => {
            try {
              const payload = JSON.parse(event.data);
              this.clientId = payload.clientId;
            } catch (err) {
              console.warn('connected 이벤트 파싱 실패', err);
            }
            this.updateConnectionStatus('연결됨', 'connected');
          });

          this.eventSource.addEventListener('dashboard', (event) => {
            const data = JSON.parse(event.data);
            this.updateDashboard(data);
          });

          this.eventSource.onerror = () => {
            this.updateConnectionStatus('재시도 대기', 'reconnecting');
            if (this.eventSource) {
              this.eventSource.close();
            }
            setTimeout(() => this.connect(), this.reconnectDelay);
          };
        },
        buildUrl: function() {
          try {
            const url = new URL(baseUrl, window.location.origin);
            const id = this.clientId || ('dashboard-' + Date.now());
            url.searchParams.set('clientId', id);
            return url.toString();
          } catch (err) {
            return baseUrl;
          }
        },
        updateDashboard: function(payload) {
          if (!payload) {
            return;
          }
          if (payload.timestamp) {
            const date = new Date(payload.timestamp);
            $('#last-updated').text(date.toLocaleString());
          }
          if (payload.summary) {
            this.updateSummary(payload.summary);
          }
          if (payload.facilities) {
            this.updateProductionChart(payload.facilities);
            this.updateLineTable(payload.facilities);
          }
          if (payload.alerts) {
            this.updateAlerts(payload.alerts);
          }
        },
        updateSummary: function(summary) {
          $('#metric-throughput .value').text(Math.round(summary.totalThroughput).toLocaleString());
          $('#metric-availability .value').text(summary.averageAvailability.toFixed(1));
          $('#metric-quality .value').text(summary.averageQuality.toFixed(1));
          $('#metric-energy .value').text((summary.energyConsumption/1000).toFixed(2));
          $('#metric-downtime .value').text(summary.downtimeMinutes.toFixed(1));
          $('#metric-alerts .value').text(summary.criticalCount + ' / ' + summary.warningCount);
        },
        updateProductionChart: function(facilities) {
          if (!this.productionChart) {
            return;
          }
          const categories = [];
          const seriesData = [];
          const drilldownSeries = [];

          facilities.forEach((facility, idx) => {
            categories.push(facility.name);
            seriesData.push({
              name: facility.name,
              y: Number(facility.throughput.toFixed(2)),
              drilldown: facility.name,
              color: Highcharts.getOptions().colors[idx % Highcharts.getOptions().colors.length],
              custom: {
                availability: facility.availability,
                quality: facility.quality
              }
            });
            if (facility.lines) {
              drilldownSeries.push({
                id: facility.name,
                name: facility.name + ' 상세',
                data: facility.lines.map(line => ({
                  name: line.name,
                  y: Number(line.throughput.toFixed(2)),
                  color: this.colorByStatus(line.status),
                  custom: {
                    availability: line.availability,
                    quality: line.quality,
                    temperature: line.temperature
                  }
                }))
              });
            }
          });

          this.productionChart.xAxis[0].setCategories(categories, false);
          this.productionChart.series[0].setData(seriesData, false);
          this.productionChart.update({
            drilldown: { series: drilldownSeries }
          }, false);
          this.productionChart.redraw();
        },
        updateLineTable: function(facilities) {
          const rows = [];
          facilities.forEach(facility => {
            (facility.lines || []).forEach(line => {
              rows.push(
                      '<tr>' +
                      '<td>' + facility.name + '</td>' +
                      '<td>' + line.name + '</td>' +
                      '<td>' + line.throughput.toFixed(1) + '</td>' +
                      '<td>' + line.availability.toFixed(1) + '</td>' +
                      '<td>' + line.quality.toFixed(1) + '</td>' +
                      '<td>' + line.temperature.toFixed(1) + '</td>' +
                      '<td>' + this.renderStatusPill(line.status) + '</td>' +
                      '</tr>'
              );
            });
          });
          $('#line-status-body').html(rows.join('') || '<tr><td colspan="7" style="text-align:center; padding:16px;">표시할 데이터가 없습니다.</td></tr>');
        },
        updateAlerts: function(alerts) {
          if (!alerts.length) {
            $('#alerts-list').html('<div class="alert-item info">현재 경보가 없습니다.</div>');
            return;
          }
          const items = alerts.map(alert => {
            const level = alert.level ? alert.level.toLowerCase() : 'info';
            return '' +
                    '<div class="alert-item ' + level + '">' +
                    '<div>' +
                    '<strong>[' + alert.level + ']</strong> ' + alert.message +
                    '</div>' +
                    '<div>' + (alert.source || '') + '</div>' +
                    '</div>';
          });
          $('#alerts-list').html(items.join(''));
        },
        renderStatusPill: function(status) {
          const normalized = (status || 'NORMAL').toLowerCase();
          const classes = {
            normal: 'status-pill normal',
            warning: 'status-pill warning',
            critical: 'status-pill critical'
          };
          const label = {
            normal: '정상',
            warning: '주의',
            critical: '경고'
          };
          const cls = classes[normalized] || classes.normal;
          const text = label[normalized] || label.normal;
          return '<span class="' + cls + '">' + text + '</span>';
        },
        colorByStatus: function(status) {
          switch ((status || '').toUpperCase()) {
            case 'CRITICAL':
              return '#ef4444';
            case 'WARNING':
              return '#f59e0b';
            default:
              return '#22c55e';
          }
        },
        updateConnectionStatus: function(message, state) {
          const chip = $('#connection-status');
          chip.text(message);
          chip.removeClass('connected reconnecting disconnected');
          chip.addClass(state || 'connected');
        }
      };

      $(function() {
        if (typeof EventSource === 'undefined') {
          $('#connection-status').text('SSE 미지원').addClass('disconnected');
          $('#alerts-list').html('<div class="alert-item critical">이 브라우저는 SSE를 지원하지 않습니다.</div>');
          return;
        }
        dashboard.init();
      });
    })();
  </script>
</div>