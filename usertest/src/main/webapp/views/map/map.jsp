<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
    .map-page {
        display: flex;
        flex-direction: column;
        gap: 16px;
    }

    .map-header {
        background: #f5f6fa;
        border: 1px solid #e5e8ef;
        border-radius: 8px;
        padding: 16px 20px;
    }

    .map-header h2 {
        margin: 0;
        font-size: 20px;
        font-weight: 700;
        color: #333333;
    }

    .map-header p {
        margin: 8px 0 0;
        color: #555555;
        font-size: 14px;
        line-height: 1.5;
    }

    #map {
        width: 100%;
        height: 480px;
        border: 2px solid #ff5959;
        border-radius: 12px;
        overflow: hidden;
    }

    .marker-form-wrapper {
        display: none;
        border: 1px solid #e1e5ea;
        border-radius: 8px;
        background-color: #ffffff;
        padding: 20px;
    }

    .marker-form-wrapper.is-visible {
        display: block;
    }

    .marker-form__row {
        display: flex;
        flex-direction: column;
        gap: 8px;
        margin-bottom: 16px;
    }

    .marker-form__row label {
        font-weight: 600;
        color: #333333;
    }

    .marker-form__row input[type="text"],
    .marker-form__row textarea {
        border: 1px solid #d3d7dd;
        border-radius: 6px;
        padding: 10px 12px;
        font-size: 14px;
        resize: vertical;
    }

    .marker-form__row input[type="file"] {
        font-size: 14px;
    }

    .marker-form__row textarea {
        min-height: 80px;
    }

    .marker-form__actions {
        display: flex;
        gap: 12px;
        justify-content: flex-end;
    }

    .marker-form__actions button {
        border: none;
        border-radius: 6px;
        padding: 10px 18px;
        font-weight: 600;
        cursor: pointer;
        font-size: 14px;
    }

    .marker-form__actions .primary {
        background-color: #ff5959;
        color: #ffffff;
    }

    .marker-form__actions .secondary {
        background-color: #f1f3f5;
        color: #333333;
    }

    .marker-form__preview {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 13px;
        color: #666666;
    }

    .marker-form__preview img {
        width: 80px;
        height: 80px;
        object-fit: cover;
        border-radius: 6px;
        border: 1px solid #d7dbe3;
    }

    .marker-guide {
        font-size: 13px;
        color: #6b7280;
        line-height: 1.6;
    }

    .marker-guide strong {
        color: #ff5959;
    }

    .marker-guide ul {
        margin: 6px 0 0;
        padding-left: 18px;
    }

    .marker-guide li {
        margin-bottom: 4px;
    }

    .photo-marker {
        width: 180px;
        background-color: #ffffff;
        border: 1px solid rgba(0, 0, 0, 0.12);
        border-radius: 10px;
        box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
        overflow: hidden;
        transform: translateY(-6px);
        cursor: pointer;
        transition: box-shadow 0.2s ease;
    }

    .photo-marker:hover {
        box-shadow: 0 10px 22px rgba(0, 0, 0, 0.18);
    }

    .photo-marker__image {
        width: 100%;
        height: 110px;
        background-color: #f1f3f5;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
    }

    .photo-marker__image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .photo-marker__body {
        padding: 12px 14px;
    }

    .photo-marker__title {
        font-weight: 700;
        font-size: 15px;
        color: #222222;
        margin-bottom: 6px;
    }

    .photo-marker__description {
        font-size: 13px;
        color: #555555;
        line-height: 1.5;
        max-height: 0;
        overflow: hidden;
        transition: max-height 0.3s ease;
    }

    .photo-marker.is-expanded .photo-marker__description {
        max-height: 200px;
        margin-top: 8px;
    }

    .photo-marker__hint {
        margin-top: 10px;
        font-size: 12px;
        color: #9ca3af;
    }

    .photo-marker__placeholder {
        font-size: 13px;
        color: #888888;
    }

</style>

<div class="map-page">
    <div class="map-header">
        <h2>내가 발견한 공간 기록하기</h2>
        <p>지도를 클릭해 제목, 설명, 사진을 남겨보세요.
            저장된 기록은 지도 위 카드 형태의 마커로 표시됩니다.</p>
    </div>

    <div id="map"></div>

    <div id="markerFormWrapper" class="marker-form-wrapper">
        <form id="markerForm">
            <div class="marker-form__row">
                <label for="markerTitle">제목</label>
                <input id="markerTitle" type="text" placeholder="예: 주말마다 가는 카페" required />
            </div>

            <div class="marker-form__row">
                <label for="markerDescription">설명</label>
                <textarea id="markerDescription" placeholder="이 장소에 대한 메모를 적어주세요."
                          maxlength="300"></textarea>
            </div>
            <div class="marker-form__row">
                <label for="markerImage">사진</label>
                <input id="markerImage" type="file" accept="image/*" />
                <div id="imagePreview" class="marker-form__preview"></div>
            </div>

            <div class="marker-form__row">
                <label>선택한 위치</label>
                <div id="selectedPosition" style="font-size: 13px; color: #444444;">지도에서 위치를 선택해주세요.</div>
            </div>
            <div class="marker-form__actions">
                <button type="button" id="cancelMarker" class="secondary">취소</button>

                <button type="submit" class="primary">기록 남기기</button>
            </div>
        </form>
    </div>

    <div class="marker-guide">
        <p><strong>사용 방법</strong></p>
        <ul>
            <li>지도 위 아무 곳이나 클릭하면 기록 입력창이 열립니다.</li>
            <li>사진은 JPG, PNG 등 이미지 파일을 선택하면 함께 저장됩니다.</li>

            <li>저장된 카드를 클릭하면 설명이 펼쳐집니다.</li>
        </ul>
    </div>
</div>

<script>
    (function () {
        var loadRetryCount = 0;
        var maxLoadRetries = 10;

        function bootstrap() {
            if (!window.kakao || !kakao.maps) {
                if (loadRetryCount < maxLoadRetries) {
                    loadRetryCount += 1;
                    setTimeout(bootstrap, 200);
                } else {
                    console.error('Kakao Maps SDK가 로드되지 않았습니다.');
                }
                return;
            }

            if (typeof kakao.maps.load === 'function') {
                kakao.maps.load(initializeMap);
            } else {
                initializeMap();
            }
        }

        function initializeMap() {
            var mapContainer = document.getElementById('map');
            if (!mapContainer) {
                return;
            }

            var map = new kakao.maps.Map(mapContainer, {
                center: new kakao.maps.LatLng(36.800209, 127.074968),
                level: 4
            });
            var markerFormWrapper = document.getElementById('markerFormWrapper');
            var markerForm = document.getElementById('markerForm');
            var markerTitleInput = document.getElementById('markerTitle');
            var markerDescriptionInput = document.getElementById('markerDescription');
            var markerImageInput = document.getElementById('markerImage');
            var selectedPositionLabel = document.getElementById('selectedPosition');
            var imagePreview = document.getElementById('imagePreview');
            var cancelButton = document.getElementById('cancelMarker');

            var selectedLatLng = null;
            var entries = [];
            var overlayHideLevel = 6;
            var markerImageCache = {};

            function formatLatLng(latLng) {
                if (!latLng) {
                    return '지도에서 위치를 선택해주세요.';
                }
                var lat = latLng.getLat().toFixed(6);
                var lng = latLng.getLng().toFixed(6);
                return '위도 ' + lat + ', 경도 ' + lng;
            }

            function resetForm(latLng) {
                markerForm.reset();
                imagePreview.innerHTML = '';
                selectedPositionLabel.textContent = formatLatLng(latLng);
                if (latLng) {
                    markerTitleInput.focus();
                }
            }

            function openForm(latLng) {
                selectedLatLng = latLng;
                markerFormWrapper.classList.add('is-visible');
                resetForm(latLng);
            }

            function closeForm() {
                markerFormWrapper.classList.remove('is-visible');
                selectedLatLng = null;
            }

            function handleImagePreview(file) {
                imagePreview.innerHTML = '';
                if (!file) {
                    return;
                }

                if (!file.type || !file.type.startsWith('image/')) {
                    imagePreview.textContent = '이미지 파일만 선택할 수 있습니다.';
                    return;
                }

                var reader = new FileReader();
                reader.onload = function (event) {
                    var img = document.createElement('img');
                    img.src = event.target.result;
                    img.alt = '선택한 이미지 미리보기';
                    imagePreview.innerHTML = '';
                    imagePreview.appendChild(img);
                };
                reader.readAsDataURL(file);
            }

            function createOverlayElement(title, description, imageSrc) {
                var container = document.createElement('div');
                container.className = 'photo-marker';

                var imageWrapper = document.createElement('div');
                imageWrapper.className = 'photo-marker__image';
                if (imageSrc) {
                    var image = document.createElement('img');
                    image.src = imageSrc;
                    image.alt = title;
                    imageWrapper.appendChild(image);
                } else {
                    var placeholder = document.createElement('span');
                    placeholder.className = 'photo-marker__placeholder';
                    placeholder.textContent = '이미지가 없습니다';
                    imageWrapper.appendChild(placeholder);
                }

                var body = document.createElement('div');
                body.className = 'photo-marker__body';

                var titleEl = document.createElement('div');
                titleEl.className = 'photo-marker__title';
                titleEl.textContent = title;
                body.appendChild(titleEl);
                if (description) {
                    var descriptionEl = document.createElement('div');
                    descriptionEl.className = 'photo-marker__description';
                    descriptionEl.textContent = description;
                    body.appendChild(descriptionEl);

                    var hintText = document.createElement('div');
                    hintText.className = 'photo-marker__hint';
                    hintText.textContent = '카드를 클릭하면 설명이 열립니다.';
                    body.appendChild(hintText);

                    container.addEventListener('click', function () {
                        container.classList.toggle('is-expanded');
                    });
                } else {
                    var emptyHint = document.createElement('div');
                    emptyHint.className = 'photo-marker__hint';
                    emptyHint.textContent = '설명이 등록되지 않았습니다.';
                    body.appendChild(emptyHint);
                }

                container.appendChild(imageWrapper);
                container.appendChild(body);

                return container;
            }

            function createOverlay(position, title, description, imageSrc) {
                var contentNode = createOverlayElement(title, description, imageSrc);
                var overlay = new kakao.maps.CustomOverlay({
                    position: position,
                    content: contentNode,
                    xAnchor: 0.5,
                    yAnchor: 1.1,

                    clickable: true
                });
                overlay.setMap(map);
                return {
                    overlay: overlay,
                    content: contentNode
                };
            }

            function getMarkerWidth(level) {
                if (level <= 3) {
                    return 52;
                }
                if (level === 4) {
                    return 46;
                }
                if (level === 5) {
                    return 38;
                }
                if (level === 6) {
                    return 30;
                }
                if (level === 7) {
                    return 24;
                }
                return 18;
            }

            function getMarkerSize(level) {
                var width = getMarkerWidth(level);
                var height = Math.round(width * 1.35);
                return {
                    width: width,
                    height: height
                };
            }

            function buildMarkerSvg(width, height) {
                var svg = '' +
                    '<svg xmlns="http://www.w3.org/2000/svg" width="' + width + '" height="' + height + '" viewBox="0 0 60 80">' +
                    '<defs>' +

                    '<linearGradient id="markerGradient" x1="50%" y1="0%" x2="50%" y2="100%">' +
                    '<stop offset="0%" stop-color="#ff7b7b" />' +
                    '<stop offset="100%" stop-color="#ff4040" />' +
                    '</linearGradient>' +

                    '</defs>' +
                    '<path d="M30 0C16 0 5 11.8 5 26.3c0 15.4 11.6 33 23.5 46.5a3.2 3.2 0 0 0 4.9 0C45.3 59.3 55 41.8 55 26.3 55 11.8 44 0 30 0z" fill="url(#markerGradient)" />' +
                    '<circle cx="30" cy="26" r="14" fill="#ffffff" opacity="0.85" />' +

                    '<circle cx="30" cy="26" r="8" fill="#ff5959" />' +
                    '</svg>';
                return 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg);
            }

            function getMarkerImage(level) {
                var size = getMarkerSize(level);
                var cacheKey = size.width + 'x' + size.height;
                if (!markerImageCache[cacheKey]) {
                    var src = buildMarkerSvg(size.width, size.height);
                    markerImageCache[cacheKey] = new kakao.maps.MarkerImage(
                        src,
                        new kakao.maps.Size(size.width, size.height),
                        {

                            offset: new kakao.maps.Point(Math.round(size.width / 2), size.height)
                        }
                    );
                }
                return markerImageCache[cacheKey];
            }

            function createBasicMarker(position, title) {
                var marker = new kakao.maps.Marker({
                    position: position,
                    image: getMarkerImage(map.getLevel()),
                    title: title,

                    clickable: true
                });
                marker.setMap(map);
                return marker;
            }

            function expandOverlay(entry) {
                if (entry.overlayContent) {
                    entry.overlayContent.classList.add('is-expanded');
                }
            }

            function collapseOverlay(entry) {
                if (entry.overlayContent) {
                    entry.overlayContent.classList.remove('is-expanded');
                }
            }

            function updateEntryForLevel(entry, level) {
                entry.marker.setImage(getMarkerImage(level));
                var shouldShowOverlay = level < overlayHideLevel || entry.forceVisible;
                var isShown = !!entry.overlay.getMap();
                if (shouldShowOverlay && !isShown) {
                    entry.overlay.setMap(map);
                } else if (!shouldShowOverlay && isShown) {
                    entry.overlay.setMap(null);
                }

                if (!shouldShowOverlay) {
                    collapseOverlay(entry);
                }
            }

            function updateAllEntries(level) {
                entries.forEach(function (entry) {
                    updateEntryForLevel(entry, level);
                });
            }

            function focusOnEntry(entry) {
                entries.forEach(function (item) {
                    if (item !== entry) {
                        item.forceVisible = false;

                        if (map.getLevel() >= overlayHideLevel) {
                            item.overlay.setMap(null);
                        }
                        collapseOverlay(item);

                    }
                });
                entry.forceVisible = true;
                updateEntryForLevel(entry, map.getLevel());
                expandOverlay(entry);
            }

            // =================================================================
            // 서버 통신 후 마커/오버레이 생성 로직 (로컬 표시)
            // 서버에 데이터 저장이 성공한 후에 호출됩니다.
            function finalize(imageSrc, title, description, selectedLatLng) {
                var overlayResult = createOverlay(selectedLatLng, title, description, imageSrc);
                var marker = createBasicMarker(selectedLatLng, title);

                var entry = {
                    position: selectedLatLng,
                    marker: marker,
                    overlay: overlayResult.overlay,
                    overlayContent: overlayResult.content,

                    forceVisible: false
                };
                kakao.maps.event.addListener(marker, 'click', function () {
                    if (map.getLevel() >= overlayHideLevel) {
                        if (entry.forceVisible) {
                            entry.forceVisible = false;

                            entry.overlay.setMap(null);
                            collapseOverlay(entry);
                        } else {
                            focusOnEntry(entry);

                        }
                    } else {
                        entry.overlay.setMap(map);
                        expandOverlay(entry);

                    }
                    map.panTo(entry.position);
                    updateEntryForLevel(entry, map.getLevel());
                });
                entries.push(entry);

                if (map.getLevel() >= overlayHideLevel) {
                    focusOnEntry(entry);
                }

                updateEntryForLevel(entry, map.getLevel());
                map.panTo(selectedLatLng);
                closeForm();
            }
            // =================================================================

            // [추가된 부분] DB에서 가져온 마커를 지도에 표시하는 로직
            function drawExistingMarkers(markers) {
                markers.forEach(function (markerData) {
                    var position = new kakao.maps.LatLng(markerData.lat, markerData.lng);

                    // [수정] 파일 저장 경로에 맞춰 웹 접근 경로를 /imgs/로 변경
                    var imageSrc = markerData.img ? '/imgs/' + markerData.img : null;

                    var overlayResult = createOverlay(position, markerData.title, markerData.description, imageSrc);
                    var marker = createBasicMarker(position, markerData.title);

                    var entry = {
                        position: position,
                        marker: marker,
                        overlay: overlayResult.overlay,
                        overlayContent: overlayResult.content,
                        forceVisible: false
                    };

                    // 마커 클릭 이벤트 리스너 설정
                    kakao.maps.event.addListener(marker, 'click', function () {
                        if (map.getLevel() >= overlayHideLevel) {
                            if (entry.forceVisible) {
                                entry.forceVisible = false;
                                entry.overlay.setMap(null);
                                collapseOverlay(entry);
                            } else {
                                focusOnEntry(entry);
                            }
                        } else {
                            entry.overlay.setMap(map);
                            expandOverlay(entry);
                        }
                        map.panTo(entry.position);
                        updateEntryForLevel(entry, map.getLevel());
                    });

                    entries.push(entry);
                    updateEntryForLevel(entry, map.getLevel());
                });
            }

            // [추가된 부분] 페이지 로드 시 기존 마커 데이터 로드 AJAX 호출
            $.ajax({
                url: '/getallmarkers',
                type: 'GET',
                dataType: 'json',
                success: function (markers) {
                    console.log('기존 마커 데이터 로드 성공:', markers.length + '개');
                    drawExistingMarkers(markers);
                },
                error: function (xhr, status, error) {
                    console.error('기존 마커 데이터 로드 실패:', error);
                }
            });

            // =================================================================
            // [기존 코드] 지도 클릭 이벤트 리스너
            kakao.maps.event.addListener(map, 'click', function (mouseEvent) {
                openForm(mouseEvent.latLng);
            });
            kakao.maps.event.addListener(map, 'zoom_changed', function () {
                var level = map.getLevel();
                if (level < overlayHideLevel) {
                    entries.forEach(function (entry) {
                        entry.forceVisible = false;

                    });
                }
                updateAllEntries(level);
            });
            markerImageInput.addEventListener('change', function (event) {
                var file = event.target.files && event.target.files[0];
                handleImagePreview(file);
            });
            cancelButton.addEventListener('click', function () {
                closeForm();
            });
            // =================================================================
            // [기존 코드] 폼 제출 시 AJAX를 통해 서버에 데이터와 파일 전송
            // =================================================================
            markerForm.addEventListener('submit', function (event) {
                event.preventDefault();

                if (!selectedLatLng) {

                    alert('먼저 지도에서 위치를 선택해주세요.');
                    return;
                }

                var title = markerTitleInput.value.trim();
                var description = markerDescriptionInput.value.trim();
                var
                    imageFile = markerImageInput.files && markerImageInput.files[0];

                if (!title) {
                    alert('제목을 입력해주세요.');
                    markerTitleInput.focus();
                    return;
                }


                // 파일 형식 체크
                if (imageFile && (!imageFile.type || !imageFile.type.startsWith('image/'))) {
                    alert('이미지 파일만 업로드할 수 있습니다.');
                    return;
                }

                // FormData를 사용하여 파일과 텍스트 데이터를 한번에 전송
                var formData = new FormData();
                formData.append('markerTitle', title);
                formData.append('markerDescription', description);
                // 파일이 없어도 서버에서 처리할 수 있도록 빈 Blob 또는 null 대신 File 객체 전달
                formData.append('markerImage', imageFile || new Blob([], {type: 'application/octet-stream'}), 'empty');
                formData.append('lat', selectedLatLng.getLat());
                formData.append('lng', selectedLatLng.getLng());

                // 로딩 중임을 사용자에게 알리는 UI (선택 사항)
                document.querySelector('.marker-form__actions .primary').disabled = true;
                // AJAX 통신
                $.ajax({
                    url: '/registermarker',
                    type: 'POST',
                    data: formData,

                    processData: false, // FormData 사용 시 필수: 데이터를 쿼리 문자열로 변환하지 않음
                    contentType: false, // FormData 사용 시 필수: 컨텐츠 타입을 설정하지 않음
                    success: function (response) {
                        document.querySelector('.marker-form__actions .primary').disabled = false;


                        if (response === 'success') {
                            alert('기록이 성공적으로 저장되었습니다!');

                            // DB 저장이 성공하면, 이미지 파일을 로컬에서 읽어 지도에 표시

                            if (imageFile) {
                                var reader = new FileReader();
                                reader.onload = function (loadEvent) {

                                    // 서버 성공 후 클라이언트의 지도 표시 로직 호출
                                    finalize(loadEvent.target.result, title, description, selectedLatLng);

                                };
                                reader.readAsDataURL(imageFile);
                            } else {
                                // 파일이 없는 경우, 파일 없이 지도 표시 로직 호출
                                finalize(null, title, description, selectedLatLng);
                            }

                        } else {
                            alert('기록 저장에 실패했습니다: ' + response);
                        }
                    },
                    error: function (xhr, status, error) {
                        document.querySelector('.marker-form__actions .primary').disabled = false;
                        alert('서버 통신 중 오류가 발생했습니다: ' + error);
                    }
                });
            });
            // =================================================================
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', bootstrap);
        } else {
            bootstrap();
        }
    })();
</script>