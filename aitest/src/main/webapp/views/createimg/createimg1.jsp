<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="col-sm-10">
  <div class="container mt-4">
    <h3>AI 추천 옷입히기 (MVP)</h3>

    <div class="row">
      <!-- 좌: 업로드 -->
      <div class="col-sm-4">
        <div class="card">
          <div class="card-header">1) 셀피 업로드</div>
          <div class="card-body">
            <input type="file" id="selfie" accept="image/*" class="form-control mb-2">
            <img id="selfiePreview" class="img-fluid border" src="/image/assistant.png">
            <button id="btnAnalyze" class="btn btn-primary mt-2 w-100">분석 시작</button>
            <div id="analyzeStatus" class="small text-muted mt-2">대기 중</div>
          </div>
        </div>
      </div>

      <!-- 중: 분석/추천 -->
      <div class="col-sm-4">
        <div class="card mb-3">
          <div class="card-header">2) 분석 결과</div>
          <div class="card-body">
            <div>tone: <span id="tone">-</span></div>
            <div>contrast: <span id="contrast">-</span></div>
            <div>faceShape: <span id="faceShape">-</span></div>
            <div>mood: <span id="mood">-</span></div>
            <div class="mt-2">palette:</div>
            <div id="palette" class="d-flex gap-2"></div>
          </div>
        </div>

        <div class="card">
          <div class="card-header">3) 추천 (클릭 시 착장)</div>
          <div class="card-body" id="recoArea">
            <div class="text-muted small">아직 없음</div>
          </div>
        </div>
      </div>

      <!-- 우: 가상 착장 -->
      <div class="col-sm-4">
        <div class="card">
          <div class="card-header">4) 가상 착장 프리뷰</div>
          <div class="card-body">
            <img id="tryonImage" class="img-fluid border" src="/image/assistant.png">
            <div class="mt-2 d-flex gap-2">
              <input type="color" id="colorHex" value="#E6EEF7" class="form-control form-control-color">
              <input type="number" id="brightness" step="0.05" min="-1" max="1" value="0" class="form-control"
                     placeholder="brightness">
              <input type="number" id="saturation" step="0.05" min="-1" max="1" value="0" class="form-control"
                     placeholder="saturation">
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script>
  let analysis = null;
  let lastSelfieFile = null;

  $('#selfie').on('change', function(e){
    const f = e.target.files[0];
    lastSelfieFile = f;
    if (!f) return;
    const r = new FileReader();
    r.onload = ev => $('#selfiePreview').attr('src', ev.target.result);
    r.readAsDataURL(f);
  });

  $('#btnAnalyze').on('click', async function(){
    if (!lastSelfieFile) { alert('이미지를 선택하세요'); return; }
    $('#analyzeStatus').text('분석 중...');

    // 1) 분석
    const fd = new FormData();
    fd.append('selfie', lastSelfieFile);
    const ares = await fetch('/ai4/analyze', { method:'POST', body: fd });
    analysis = await ares.json();

    // 표시
    $('#tone').text(analysis.tone);
    $('#contrast').text(analysis.contrast);
    $('#faceShape').text(analysis.faceShape);
    $('#mood').text(analysis.mood);

    $('#palette').empty();
    (analysis.palette||[]).forEach(hex=>{
      $('#palette').append(`<div style="width:24px;height:24px;border:1px solid #ccc;background:${hex}"></div>`);
    });

    // 2) 추천
    const rres = await fetch('/ai4/recommend', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify(analysis)
    });
    const reco = await rres.json();
    renderRecommendation(reco);

    $('#analyzeStatus').text('완료');
  });

  function renderRecommendation(reco){
    const area = $('#recoArea').empty();

    ['tops','bottoms','outer','onepiece'].forEach(cat=>{
      if (!reco[cat] || !reco[cat].length) return;
      area.append(`<div class="fw-bold mt-2">${cat}</div>`);
      reco[cat].forEach(item=>{
        const card = $(`
        <div class="border rounded p-2 mt-2 d-flex justify-content-between align-items-center">
          <div>
            <div>${item.name}</div>
            <div class="small text-muted">${item.reason||''}</div>
          </div>
          <div class="d-flex align-items-center gap-2">
            <div style="width:24px;height:24px;border:1px solid #ccc;background:${item.hex}"></div>
            <button class="btn btn-sm btn-outline-primary">입어보기</button>
          </div>
        </div>
      `);
        card.find('button').on('click', ()=> doTryOn(item));
        area.append(card);
      });
    });
  }

  async function doTryOn(item){
    if (!lastSelfieFile) { alert('이미지를 선택하세요'); return; }

    const req = {
      garmentId: item.id,
      colorHex: $('#colorHex').val() || item.hex,
      brightness: parseFloat($('#brightness').val()||0),
      saturation: parseFloat($('#saturation').val()||0)
    };

    const fd = new FormData();
    fd.append('selfie', lastSelfieFile);
    fd.append('request', new Blob([JSON.stringify(req)], {type:'application/json'}));

    const res = await fetch('/ai4/tryon', { method:'POST', body: fd });
    const data = await res.json();
    if (data.status === 'done') {
      $('#tryonImage').attr('src', data.imageB64);
    } else {
      alert('합성 실패: ' + (data.message||''));
    }
  }
</script>
