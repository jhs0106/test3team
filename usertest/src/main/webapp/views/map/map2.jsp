<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  #map2 {
    width: 100%;
    height: 500px;
    border: 2px solid #5a5a5a;
    border-radius: 8px;
    overflow: hidden;
  }
  .user-marker {
    width: 24px;
    height: 24px;
    background-color: #ff5959;
    border-radius: 50%;
    border: 3px solid white;
    box-shadow: 0 0 5px rgba(0, 0, 0, 0.5);
  }
  #facilityModal .modal-body img {
    width: 100%;
    height: auto;
  }
</style>

<div class="col-sm-10">
  <div class="map-page">
    <h2>실시간 위치 기반 시설 안내</h2>
    <p>브라우저의 위치 추적 기능으로 특정 구역 진입 시 안내 모달이 뜹니다.
      (지오펜스: 학교 중심 반경 1km 구역)
    </p>
    <div id="map2"></div>
    <div id="status">위치 추적을 시작합니다...</div>
  </div>
</div>

<div class="modal fade" id="facilityModal" tabindex="-1" aria-labelledby="facilityModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalTitle">시설 안내</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body text-center">
        <p id="modalDescription" class="mb-3"></p>
        <img id="modalImage" src="" alt="시설 안내도" class="img-fluid border rounded" />
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
      </div>
    </div>
  </div>
</div>

<script>
  (function () {
    var map = null;
    var userMarker = null;
    var geofences = [];
    var statusElement = document.getElementById('status');
    var loadRetryCount = 0;
    var maxLoadRetries = 10;
    var isModalActive = false;

    const GEOFENCE_DATA = [
      {
        id: 'school_center',
        title: '학교 중심 1km 반경',
        description: '학교 중심 반경 1km 구역에 진입하셨습니다. 시설 안내도를 확인하시겠습니까?',
        lat: 36.798801,
        lng: 127.075831,
        radius: 1000,
        img: '/imgs/map02.jpg',
        isInside: false,
        modalTitle: '학교 시설 안내',
        modalDescriptionText: '선문대학교 주요 시설 안내도'
      }
    ];

    function haversineDistance(lat1, lon1, lat2, lon2) {
      const R = 6371e3;
      const φ1 = lat1 * Math.PI / 180;
      const φ2 = lat2 * Math.PI / 180;
      const Δφ = (lat2 - lat1) * Math.PI / 180;
      const Δλ = (lon2 - lon1) * Math.PI / 180;
      const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      return R * c;
    }

    function updateStatus(message, color = 'black') {
      if (statusElement) {
        statusElement.textContent = message;
        statusElement.style.color = color;
      }
    }

    function initializeMap() {
      var mapContainer = document.getElementById('map2');
      if (!mapContainer) {
        updateStatus('ERROR: Map container not found.', 'red');
        return;
      }
      var initialCenter = new kakao.maps.LatLng(36.798801, 127.075831);
      var mapOption = {
        center: initialCenter,
        level: 5
      };
      map = new kakao.maps.Map(mapContainer, mapOption);

      GEOFENCE_DATA.forEach(data => {
        data.center = new kakao.maps.LatLng(data.lat, data.lng);
        var circle = new kakao.maps.Circle({
          center: data.center,
          radius: data.radius,
          strokeWeight: 2,
          strokeColor: '#FF0000',
          strokeOpacity: 0.5,
          strokeStyle: 'solid',
          fillColor: '#FF0000',
          fillOpacity: 0.2
        });
        circle.setMap(map);
        geofences.push({ ...data, circle: circle });
      });

      $('#facilityModal').on('hidden.bs.modal', function () {
        isModalActive = false;
      });

      startGeolocation();
    }

    function startGeolocation() {
      if (navigator.geolocation) {
        updateStatus('Geolocation API를 사용하여 위치 추적 중...', 'green');

        var userMarkerImage = new kakao.maps.CustomOverlay({
          content: '<div class="user-marker"></div>',
          yAnchor: 1
        });
        userMarker = userMarkerImage;

        navigator.geolocation.watchPosition(
                function (position) {
                  var lat = position.coords.latitude;
                  var lng = position.coords.longitude;
                  var latLng = new kakao.maps.LatLng(lat, lng);
                  var accuracy = position.coords.accuracy;

                  updateStatus('현재 위치: 위도 ' + lat.toFixed(6) + ', 경도 ' + lng.toFixed(6) + ' (정확도: ' + Math.round(accuracy) + 'm)', 'green');

                  userMarker.setPosition(latLng);
                  userMarker.setMap(map);

                  if (map.getLevel() > 5) {
                    map.setLevel(4);
                  }
                  map.panTo(latLng);

                  checkGeofence(lat, lng);
                },
                function (error) {
                  var msg = '';
                  switch (error.code) {
                    case error.PERMISSION_DENIED:
                      msg = 'ERROR: 위치 정보 사용 권한이 거부되었습니다.';
                      break;
                    case error.POSITION_UNAVAILABLE:
                      msg = 'ERROR: 사용 가능한 위치 정보가 없습니다.';
                      break;
                    case error.TIMEOUT:
                      msg = 'ERROR: 위치 정보를 가져오는 시간이 초과되었습니다.';
                      break;
                    default:
                      msg = 'ERROR: 알 수 없는 오류가 발생했습니다. (' + error.code + ')';
                      break;
                  }
                  updateStatus(msg, 'red');
                }, {
                  enableHighAccuracy: true,
                  timeout: 5000,
                  maximumAge: 0
                }
        );
      } else {
        updateStatus('ERROR: 이 브라우저는 Geolocation API를 지원하지 않습니다.', 'red');
      }
    }

    function checkGeofence(lat, lng) {
      geofences.forEach(geofence => {
        const distance = haversineDistance(lat, lng, geofence.center.getLat(), geofence.center.getLng());
        const isNowInside = distance <= geofence.radius;

        if (isNowInside && !geofence.isInside) {
          geofence.isInside = true;
          handleGeofenceEntry(geofence);
        } else if (!isNowInside && geofence.isInside) {
          geofence.isInside = false;
        }
      });
    }

    function handleGeofenceEntry(geofence) {
      if (isModalActive) {
        return;
      }
      if (confirm(geofence.description)) {
        $('#modalTitle').text(geofence.modalTitle);
        $('#modalDescription').text(geofence.modalDescriptionText);
        $('#modalImage').attr('src', geofence.img);
        $('#facilityModal').modal('show');
        isModalActive = true;
        map.panTo(geofence.center);
      } else {
        updateStatus(geofence.title + ' 안내를 취소했습니다. 다시 진입하면 알림이 뜹니다.', 'blue');
      }
    }

    function bootstrap() {
      if (!window.kakao || !kakao.maps) {
        if (loadRetryCount < maxLoadRetries) {
          loadRetryCount += 1;
          setTimeout(bootstrap, 200);
        } else {
          updateStatus('Kakao Maps SDK가 로드되지 않았습니다.', 'red');
        }
        return;
      }

      if (typeof kakao.maps.load === 'function') {
        kakao.maps.load(initializeMap);
      } else {
        initializeMap();
      }
    }

    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', bootstrap);
    } else {
      bootstrap();
    }
  })();
</script>
