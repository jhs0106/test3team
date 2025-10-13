<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    :root{
        --brand:#ff5959;
        --text:#222;
        --muted:#6b7280;
        --border:#e5e8ef;
        --bg:#f7f8fb;
        --card:#fff;
        --radius:14px;
        --shadow:0 10px 24px rgba(0,0,0,.08);
    }

    .map-page{
        max-width:1200px;
        margin: 24px auto 64px;
        padding: 0 20px;
        display:flex;
        flex-direction:column;
        gap:20px;
    }

    .map-header{
        background:var(--bg);
        border:1px solid var(--border);
        border-radius:var(--radius);
        padding:20px 24px;
    }
    .map-header h2{
        margin:0 0 8px 0;
        font-size: clamp(20px, 2.4vw, 28px);
        font-weight:800;
        color:var(--text);
        letter-spacing:-.2px;
    }
    .map-header p{
        margin:0;
        color:#555;
        font-size:clamp(14px, 1.6vw, 16px);
        line-height:1.6;
    }

    .map-card{
        background:var(--card);
        border:1px solid var(--border);
        border-radius:var(--radius);
        box-shadow: var(--shadow);
        overflow:hidden;
    }

    #map{
        width:100%;
        height: 500px;
        min-height: 360px;
        outline: none;
        display:block;
    }
    .map-frame{
        border:2px solid var(--brand);
        border-radius:12px;
        overflow:hidden;
    }

    .marker-form-wrapper{
        background:var(--card);
        border:1px solid var(--border);
        border-radius:var(--radius);
        box-shadow: var(--shadow);
        padding: 20px;
    }
    .marker-form-wrapper.is-visible{ display:block; }
    .marker-form-wrapper:not(.is-visible){ display:block; }

    .marker-form{
        display:grid;
        grid-template-columns: 1fr;
        gap:16px;
    }
    @media (min-width: 900px){
        .marker-form{
            grid-template-columns: 1fr 1fr;
            gap:20px;
        }
        .marker-form__row--full{
            grid-column: 1 / -1;
        }
    }
    .marker-form__row{
        display:flex;
        flex-direction:column;
        gap:8px;
    }
    .marker-form__row label{
        font-weight:700;
        color:var(--text);
        font-size:14px;
    }
    .marker-form__row input[type="text"],
    .marker-form__row textarea,
    .marker-form__row input[type="file"]{
        border:1px solid #d3d7dd;
        border-radius:10px;
        padding:12px 14px;
        font-size:15px;
        background:#fff;
        transition: box-shadow .15s ease, border-color .15s ease;
    }
    .marker-form__row input[type="text"]:focus,
    .marker-form__row textarea:focus{
        border-color: var(--brand);
        box-shadow: 0 0 0 3px rgba(255,89,89,.15);
        outline:none;
    }
    .marker-form__row textarea{ min-height: 120px; resize: vertical; }

    .marker-form__preview{
        display:flex; align-items:center; gap:12px;
        font-size:13px; color:#666;
    }
    .marker-form__preview img{
        width: 100px; height: 100px; object-fit:cover;
        border-radius:10px; border:1px solid #e1e5ea;
    }

    .marker-form__actions{
        display:flex; gap:12px; justify-content:flex-end;
        margin-top: 6px;
    }
    .btn{
        appearance:none; border:none; cursor:pointer;
        padding:12px 18px; border-radius:10px; font-weight:800; font-size:15px;
        transition: transform .05s ease, box-shadow .15s ease, background .15s ease;
    }
    .btn:active{ transform: translateY(1px); }
    .btn.primary{ background:var(--brand); color:#fff; }
    .btn.primary:hover{ filter:brightness(1.03); box-shadow:0 8px 20px rgba(255,89,89,.28); }
    .btn.secondary{ background:#f1f3f5; color:#333; }
    .btn.secondary:hover{ filter:brightness(1.02); }

    .marker-guide{
        font-size:14px; color:var(--muted); line-height:1.7;
        background: var(--card);
        border:1px solid var(--border);
        border-radius: var(--radius);
        padding:16px 20px;
    }
    .marker-guide strong{ color:var(--brand); }
    .marker-guide ul{ margin:8px 0 0; padding-left:20px; }
    .marker-guide li{ margin: 4px 0; }

    .photo-marker{
        width: clamp(190px, 22vw, 260px);
        background: var(--card);
        border:1px solid rgba(0,0,0,.12);
        border-radius: 12px;
        box-shadow: 0 10px 26px rgba(0,0,0,.16);
        overflow:hidden;
        transform: translateY(-6px);
        cursor:pointer;
        transition: box-shadow .2s ease, transform .12s ease;
    }
    .photo-marker:hover{ box-shadow:0 14px 28px rgba(0,0,0,.20); transform: translateY(-8px); }

    .photo-marker__image{
        width:100%; height: clamp(120px, 16vh, 180px);
        background:#f1f3f5; display:flex; align-items:center; justify-content:center; overflow:hidden;
    }
    .photo-marker__image img{ width:100%; height:100%; object-fit:cover; }

    .photo-marker__body{ padding:14px 15px 16px; }
    .photo-marker__title{ font-weight:800; font-size:15px; color:#111; margin-bottom:6px; letter-spacing:-.2px; }
    .photo-marker__description{
        font-size:13px; color:#444; line-height:1.55;
        max-height:0; overflow:hidden; transition:max-height .28s ease;
    }
    .photo-marker.is-expanded .photo-marker__description{ max-height: 260px; margin-top:8px; }
    .photo-marker__hint{ margin-top:10px; font-size:12px; color:#9aa1a9; }
    .photo-marker__placeholder{ font-size:13px; color:#888; }

    @media (max-width: 480px){
        .btn{ width:100%; }
        .marker-form__actions{ flex-direction: column; align-items: stretch; }
    }
</style>

<div class="map-page">
    <div class="map-header">
        <h2>공간 기록하기</h2>
        <p>지도를 클릭해 <b>제목, 설명, 사진</b>을 남겨보세요. 저장된 기록은 지도 위 <b>카드 형태</b>의 마커로 표시됩니다.</p>
    </div>

    <div class="map-card">
        <div class="map-frame">
            <div id="map" aria-label="카카오 지도"></div>
        </div>
    </div>

    <div id="markerFormWrapper" class="marker-form-wrapper">
        <form id="markerForm" class="marker-form">
            <div class="marker-form__row">
                <label for="markerTitle">제목</label>
                <input id="markerTitle" type="text" placeholder="예: 주말마다 가는 카페" required />
            </div>

            <div class="marker-form__row">
                <label for="markerImage">사진</label>
                <input id="markerImage" type="file" accept="image/*" />
                <div id="imagePreview" class="marker-form__preview"></div>
            </div>

            <div class="marker-form__row marker-form__row--full">
                <label for="markerDescription">설명</label>
                <textarea id="markerDescription" placeholder="이 장소에 대한 메모를 적어주세요." maxlength="500"></textarea>
            </div>

            <div class="marker-form__row marker-form__row--full">
                <label>선택한 위치</label>
                <div id="selectedPosition" style="font-size: 14px; color: #333;">지도에서 위치를 선택해주세요.</div>
            </div>

            <div class="marker-form__row marker-form__row--full marker-form__actions">
                <button type="button" id="cancelMarker" class="btn secondary">취소</button>
                <button type="submit" class="btn primary">기록 남기기</button>
            </div>
        </form>
    </div>

    <div class="marker-guide">
        <p><strong>사용 방법</strong></p>
        <ul>
            <li>지도 위 아무 곳이나 클릭하면 기록 입력창이 열립니다.</li>
            <li>사진은 JPG, PNG 등 이미지 파일을 선택하면 함께 저장됩니다.</li>
            <li>저장된 카드를 클릭하면 설명이 펼쳐집니다.</li>
            <li>화면 크기를 바꿔도 지도가 자동으로 맞춰집니다.</li>
        </ul>
    </div>
</div>

<script>
    (function () {
        var map, mapContainer, selectedLatLng = null;
        var markerFormWrapper, markerForm, markerTitleInput, markerDescriptionInput, markerImageInput, selectedPositionLabel, imagePreview, cancelButton;
        var entries = [], overlayHideLevel = 6, markerImageCache = {};

        function formatLatLng(latLng){
            if (!latLng) return '지도에서 위치를 선택해주세요.';
            return '위도 ' + latLng.getLat().toFixed(6) + ', 경도 ' + latLng.getLng().toFixed(6);
        }
        function escapeHtml(v){
            var s = v == null ? '' : String(v);
            return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
        }
        function debounce(fn, wait){
            var t; return function(){ clearTimeout(t); t = setTimeout(fn, wait); };
        }

        function createOverlayElement(title, description, imageSrc){
            var container = document.createElement('div');
            container.className = 'photo-marker';

            var imageWrap = document.createElement('div');
            imageWrap.className = 'photo-marker__image';
            if (imageSrc){
                var img = document.createElement('img');
                img.src = imageSrc; img.alt = title;
                imageWrap.appendChild(img);
            }else{
                var ph = document.createElement('span');
                ph.className = 'photo-marker__placeholder';
                ph.textContent = '이미지가 없습니다';
                imageWrap.appendChild(ph);
            }

            var body = document.createElement('div');
            body.className = 'photo-marker__body';

            var titleEl = document.createElement('div');
            titleEl.className = 'photo-marker__title';
            titleEl.textContent = title;
            body.appendChild(titleEl);

            if (description){
                var descEl = document.createElement('div');
                descEl.className = 'photo-marker__description';
                descEl.textContent = description;
                body.appendChild(descEl);

                var hint = document.createElement('div');
                hint.className = 'photo-marker__hint';
                hint.textContent = '카드를 클릭하면 설명이 열립니다.';
                body.appendChild(hint);

                container.addEventListener('click', function(){
                    container.classList.toggle('is-expanded');
                });
            }else{
                var empty = document.createElement('div');
                empty.className = 'photo-marker__hint';
                empty.textContent = '설명이 등록되지 않았습니다.';
                body.appendChild(empty);
            }

            container.appendChild(imageWrap);
            container.appendChild(body);
            return container;
        }
        function createOverlay(position, title, description, imageSrc){
            var node = createOverlayElement(title, description, imageSrc);
            var overlay = new kakao.maps.CustomOverlay({
                position: position,
                content: node,
                xAnchor: 0.5, yAnchor: 1.1,
                clickable: true
            });
            overlay.setMap(map);
            return { overlay: overlay, content: node };
        }

        function getMarkerWidth(level){
            if (level <= 3) return 56;
            if (level === 4) return 48;
            if (level === 5) return 40;
            if (level === 6) return 32;
            if (level === 7) return 26;
            return 20;
        }
        function getMarkerSize(level){
            var w = getMarkerWidth(level), h = Math.round(w * 1.35);
            return {width:w, height:h};
        }
        function buildMarkerSvg(width, height){
            var svg = ''
                + '<svg xmlns="http://www.w3.org/2000/svg" width="'+width+'" height="'+height+'" viewBox="0 0 60 80">'
                + '<defs><linearGradient id="g" x1="50%" y1="0%" x2="50%" y2="100%"><stop offset="0%" stop-color="#ff7b7b"/><stop offset="100%" stop-color="#ff4040"/></linearGradient></defs>'
                + '<path d="M30 0C16 0 5 11.8 5 26.3c0 15.4 11.6 33 23.5 46.5a3.2 3.2 0 0 0 4.9 0C45.3 59.3 55 41.8 55 26.3 55 11.8 44 0 30 0z" fill="url(#g)"/>'
                + '<circle cx="30" cy="26" r="14" fill="#fff" opacity=".9"/>'
                + '<circle cx="30" cy="26" r="8" fill="#ff5959"/></svg>';
            return 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg);
        }
        function getMarkerImage(level){
            var s = getMarkerSize(level);
            var key = s.width + 'x' + s.height;
            if (!markerImageCache[key]){
                var src = buildMarkerSvg(s.width, s.height);
                markerImageCache[key] = new kakao.maps.MarkerImage(
                    src,
                    new kakao.maps.Size(s.width, s.height),
                    { offset: new kakao.maps.Point(Math.round(s.width/2), s.height) }
                );
            }
            return markerImageCache[key];
        }
        function createBasicMarker(position, title){
            var marker = new kakao.maps.Marker({
                position: position,
                image: getMarkerImage(map.getLevel()),
                title: title,
                clickable: true
            });
            marker.setMap(map);
            return marker;
        }

        function expandOverlay(entry){ if (entry.overlayContent) entry.overlayContent.classList.add('is-expanded'); }
        function collapseOverlay(entry){ if (entry.overlayContent) entry.overlayContent.classList.remove('is-expanded'); }

        function updateEntryForLevel(entry, level){
            entry.marker.setImage( getMarkerImage(level) );
            var showOverlay = level < overlayHideLevel || entry.forceVisible;
            var shown = !!entry.overlay.getMap();
            if (showOverlay && !shown) entry.overlay.setMap(map);
            else if (!showOverlay && shown) entry.overlay.setMap(null);
            if (!showOverlay) collapseOverlay(entry);
        }
        function updateAll(level){ entries.forEach(function(e){ updateEntryForLevel(e, level); }); }
        function focusEntry(entry){
            entries.forEach(function(e){
                if (e !== entry){
                    e.forceVisible = false;
                    if (map.getLevel() >= overlayHideLevel) e.overlay.setMap(null);
                    collapseOverlay(e);
                }
            });
            entry.forceVisible = true;
            updateEntryForLevel(entry, map.getLevel());
            expandOverlay(entry);
        }

        function handleImagePreview(file){
            imagePreview.innerHTML = '';
            if (!file) return;
            if (!file.type || !file.type.startsWith('image/')){
                imagePreview.textContent = '이미지 파일만 선택할 수 있습니다.';
                return;
            }
            var r = new FileReader();
            r.onload = function(e){
                var img = document.createElement('img');
                img.src = e.target.result;
                img.alt = '선택한 이미지 미리보기';
                imagePreview.innerHTML = ''; imagePreview.appendChild(img);
            };
            r.readAsDataURL(file);
        }

        function openForm(latLng){
            selectedLatLng = latLng;
            markerFormWrapper.classList.add('is-visible');
            markerForm.reset();
            imagePreview.innerHTML = '';
            selectedPositionLabel.textContent = formatLatLng(latLng);
            markerTitleInput.focus();
        }
        function closeForm(){
            markerFormWrapper.classList.remove('is-visible');
            selectedLatLng = null;
        }

        function initializeMap(){
            mapContainer = document.getElementById('map');
            if (!mapContainer) return;

            map = new kakao.maps.Map(mapContainer, {
                center: new kakao.maps.LatLng(36.800209, 127.074968),
                level: 4
            });

            markerFormWrapper = document.getElementById('markerFormWrapper');
            markerForm = document.getElementById('markerForm');
            markerTitleInput = document.getElementById('markerTitle');
            markerDescriptionInput = document.getElementById('markerDescription');
            markerImageInput = document.getElementById('markerImage');
            selectedPositionLabel = document.getElementById('selectedPosition');
            imagePreview = document.getElementById('imagePreview');
            cancelButton = document.getElementById('cancelMarker');

            kakao.maps.event.addListener(map, 'click', function (evt) {
                openForm(evt.latLng);
            });
            kakao.maps.event.addListener(map, 'zoom_changed', function () {
                var lv = map.getLevel();
                if (lv < overlayHideLevel) entries.forEach(function(e){ e.forceVisible = false; });
                updateAll(lv);
            });

            markerImageInput.addEventListener('change', function (e) {
                var file = e.target.files && e.target.files[0];
                handleImagePreview(file);
            });
            cancelButton.addEventListener('click', function(){ closeForm(); });

            markerForm.addEventListener('submit', function(e){
                e.preventDefault();
                if (!selectedLatLng){ alert('먼저 지도에서 위치를 선택해주세요.'); return; }

                var title = markerTitleInput.value.trim();
                var desc  = markerDescriptionInput.value.trim();
                if (!title){ alert('제목을 입력해주세요.'); markerTitleInput.focus(); return; }

                var file = markerImageInput.files && markerImageInput.files[0];

                function finalize(imgSrc){
                    var ov = createOverlay(selectedLatLng, title, desc, imgSrc);
                    var mk = createBasicMarker(selectedLatLng, title);
                    var entry = {
                        position: selectedLatLng,
                        marker: mk,
                        overlay: ov.overlay,
                        overlayContent: ov.content,
                        forceVisible: false
                    };
                    kakao.maps.event.addListener(mk
