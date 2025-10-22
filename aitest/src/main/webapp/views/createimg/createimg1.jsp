<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%
  edu.sm.app.dto.Member m = (edu.sm.app.dto.Member) session.getAttribute("loginMember");
  String gender = (m != null && m.getGender() != null) ? m.getGender() : "";
  // JS 문자열로 안전하게 넣기 위한 간단 이스케이프
  gender = gender.replace("\\", "\\\\").replace("'", "\\'");
%>


<!-- Bootstrap4 기반 스타일 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

<style>
  body {
    background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
    font-family: 'Noto Sans KR', sans-serif;
  }

  h3 {
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 25px;
  }

  /* 카드 */
  .card {
    border: none;
    border-radius: 10px;
    box-shadow: 0 3px 8px rgba(0, 0, 0, 0.05);
    transition: all 0.25s ease;
  }
  .card:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 14px rgba(0, 0, 0, 0.08);
  }

  .card-header {
    background: linear-gradient(135deg, #3b82f6, #2563eb);
    color: #fff;
    font-weight: 600;
  }

  .card-body {
    background: #fff;
    border-top: 1px solid #f1f5f9;
    overflow: visible !important;
  }

  /* 업로드 이미지 */
  #selfiePreview, #tryonImage {
    border-radius: 8px;
    transition: all 0.3s ease;
  }
  #selfiePreview:hover, #tryonImage:hover {
    transform: scale(1.03);
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
  }

  /* 버튼 */
  .btn-primary {
    background-color: #2563eb;
    border-color: #2563eb;
    font-weight: 500;
  }
  .btn-primary:hover {
    background-color: #1d4ed8;
  }

  /* 팔레트 박스 */
  #palette {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    min-height: 36px;
    padding: 8px;
    border: 1px dashed #cbd5e1;
    border-radius: 8px;
    background: #f9fafb;
  }
  #palette .chip {
    width: 28px;
    height: 28px;
    border-radius: 6px;
    border: 1px solid #999;
    cursor: pointer;
    transition: transform .2s ease;
  }
  #palette .chip:hover {
    transform: scale(1.2);
  }

  /* 추천 카드 */
  .reco-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    background: #f8fafc;
    padding: 10px;
    margin-top: 10px;
    transition: all 0.2s ease;
  }
  .reco-card:hover {
    background: #f1f5f9;
    transform: scale(1.01);
  }
  .reco-thumb {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 6px;
    border: 1px solid #ccc;
  }
  .reco-name {
    font-weight: 600;
    color: #111827;
  }
  .reco-reason {
    color: #6b7280;
    font-size: 0.875rem;
  }
  .reco-chip {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    border: 1px solid #ccc;
  }
  .tryon-btn {
    font-size: 0.85rem;
    border-radius: 5px;
  }

  /* 입력 영역 */
  .form-control-color {
    width: 45px !important;
    height: 45px !important;
    padding: 2px;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
  }
  input[type=number] {
    border-radius: 6px;
    border: 1px solid #cbd5e1;
    padding: 4px 6px;
  }

  /* 부드러운 등장 효과 */
  .fade-in {
    animation: fadeIn 0.7s ease-in-out;
  }
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: translateY(0); }
  }
  .spinner-overlay {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    z-index: 10;
    background: rgba(255, 255, 255, 0.75);
    width: 100%;
    height: 100%;
    border-radius: 8px;
  }
</style>
<script>
  const SESSION_GENDER = '<%= gender %>';
  console.log('SESSION_GENDER =', SESSION_GENDER);
</script>
<div class="col-sm-10 fade-in">
  <div class="container mt-4 mb-5">
    <h3>👗 AI 추천 옷입히기 </h3>
    <div class="row">
      <!-- 좌: 업로드 -->
      <div class="col-sm-4 mb-3">
        <div class="card">
          <div class="card-header">1️⃣ 셀피 업로드</div>
          <div class="card-body text-center">
            <input type="file" id="selfie" accept="image/*" class="form-control mb-2">
            <img id="selfiePreview" class="img-fluid border" src="/image/assistant.jpg" alt="selfie preview">
            <button id="btnAnalyze" class="btn btn-primary mt-3 w-100">
              <span class="spinner-border spinner-border-sm d-none" id="analyzeSpinner"></span>
              <span id="analyzeText">분석 시작</span>
            </button>            <div id="analyzeStatus" class="small text-muted mt-2">대기 중</div>
          </div>
        </div>
      </div>

      <!-- 중: 분석/추천 -->
      <div class="col-sm-4 mb-3">
        <div class="card mb-3">
          <div class="card-header">2️⃣ 분석 결과</div>
          <div class="card-body">
            <div>톤: <span id="tone">-</span></div>
            <div>대비: <span id="contrast">-</span></div>
            <div>얼굴형: <span id="faceShape">-</span></div>
            <div>분위기: <span id="mood">-</span></div>
            <div class="mt-2">🎨 추천 색상:</div>
            <div id="palette"></div>
          </div>
        </div>

        <div class="card">
          <div class="card-header">3️⃣ 추천 (클릭 시 착장)</div>
          <div class="card-body" id="recoArea">
            <div class="text-muted small">아직 없음</div>
          </div>
        </div>
      </div>

      <!-- 우: 가상 착장 -->
      <div class="col-sm-4 mb-3">
        <div class="card">
          <div class="card-header">4️⃣ 가상 착장 프리뷰</div>
          <div class="card-body text-center position-relative">

            <!-- 스피너 오버레이 -->
            <div id="tryonSpinner" class="spinner-overlay d-none">
              <div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"></div>
              <div class="mt-2 text-primary font-weight-bold">착장 생성 중...</div>
            </div>

            <img id="tryonImage" class="img-fluid border" src="/image/assistant.jpg" alt="try-on preview">

          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  // ===== 한글 매핑 헬퍼 =====
  const toneMap = {
    "summer-light": "여름 · 라이트(쿨톤)",
    "summer-cool": "여름 · 쿨톤",
    "winter-bright": "겨울 · 브라이트(쿨톤)",
    "winter-cool": "겨울 · 쿨톤",
    "spring-light": "봄 · 라이트(웜톤)",
    "spring-warm": "봄 · 웜톤",
    "autumn-muted": "가을 · 뮤트(웜톤)",
    "autumn-warm": "가을 · 웜톤",
    "neutral": "뉴트럴"
  };
  const contrastMap = { low: "낮음", medium: "보통", high: "높음" };
  const faceMap = { oval:"계란형", square:"각진형", heart:"역삼각형", round:"둥근형", oblong:"긴형" };
  const moodMap = { neutral:"뉴트럴", "soft-cool":"소프트 쿨", "warm-bright":"웜 브라이트" };

  const koTone     = (t)=> toneMap[(t||"").toLowerCase()] || t || "-";
  const koContrast = (c)=> contrastMap[(c||"").toLowerCase()] || c || "-";
  const koFace     = (f)=> faceMap[(f||"").toLowerCase()] || f || "-";
  const koMood     = (m)=> moodMap[(m||"").toLowerCase()] || m || "-";

  let analysis = null;
  let lastSelfieFile = null;

  // 이미지 선택 프리뷰
  $('#selfie').on('change', function(e){
    const f = e.target.files[0];
    lastSelfieFile = f;
    if (!f) return;
    const r = new FileReader();
    r.onload = ev => $('#selfiePreview').attr('src', ev.target.result);
    r.readAsDataURL(f);
  });

  // 분석 시작
  $('#btnAnalyze').on('click', async function(){
    if (!lastSelfieFile) { alert('이미지를 선택하세요'); return; }
    $('#analyzeStatus').text('분석 중...');

    //  스피너 표시
    $('#analyzeSpinner').removeClass('d-none');
    $('#analyzeText').text('분석 중...');
    $('#btnAnalyze').prop('disabled', true);
    $('#analyzeStatus').text('분석 중...');

    // 분석 호출
    const fd = new FormData();
    fd.append('selfie', lastSelfieFile);
    const ares = await fetch('/ai4/analyze', { method:'POST', body: fd });
    analysis = await ares.json();

    $('#tone').text( koTone(analysis.tone) );
    $('#contrast').text( koContrast(analysis.contrast) );
    $('#faceShape').text( koFace(analysis.faceShape) );
    $('#mood').text( koMood(analysis.mood) );

    $('#palette').empty();
    const pal = Array.isArray(analysis.palette) ? analysis.palette : [];
    pal.forEach(hex => {
      const chip = $('<div class="chip" title="'+hex+'"></div>');
      chip.css('background', hex);
      chip.on('click', () => navigator.clipboard && navigator.clipboard.writeText(hex));
      $('#palette').append(chip);
    });

    try {
      const recoRes = await fetch('/ai4/recommend', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(analysis)
      });
      if (!recoRes.ok) throw new Error('HTTP ' + recoRes.status);
      const reco = await recoRes.json();
      window.__reco = reco;
      renderRecommendation(reco);
    } catch (e) {
      console.error('[RECOMMEND][ERROR]', e);
      $('#recoArea').html('<div class="text-danger small">추천 호출 실패: ' + e.message + '</div>');
    } finally {
      // 스피너 끔
      $('#analyzeSpinner').addClass('d-none');
      $('#analyzeText').text('분석 시작');
      $('#btnAnalyze').prop('disabled', false);
    }

    $('#analyzeStatus').text('완료');
  });

  // 추천 렌더링
  function renderRecommendation(recoRaw){
    const area = $('#recoArea').empty();
    const cats = ['tops','bottoms','outer','onepiece'];
    let any = false;

    cats.forEach(cat=>{
      const arr = Array.isArray(recoRaw?.[cat]) ? recoRaw[cat] : [];
      if (!arr.length) return;
      any = true;
      area.append(`<div class="fw-bold mt-2">${cat}</div>`);

      arr.forEach((item, idx) => {
        const name   = item?.name || item?.title || '(추천 아이템)';
        const hex    = item?.hex || item?.colorHex || item?.color || '#E6EEF7';
        const id     = item?.id || `${cat}-${idx}`;
        const reason = item?.reason || item?.desc || '';
        const thumb  = item?.thumbUrl || item?.thumbnail || item?.imageUrl || '';

        const thumbHtml  = thumb  ? `<img src="${thumb}" alt="thumb" class="reco-thumb">` : '';
        const reasonHtml = reason ? `<div class="reco-reason">${reason}</div>` : '';

        // ✅ 버튼 내부에 스피너와 텍스트를 함께 넣음
        const $card = $(`
          <div class="reco-card">
            <div class="reco-left">
              ${thumbHtml}
              <div class="reco-text">
                <span class="reco-name">${name}</span>
                ${reasonHtml}
              </div>
            </div>
            <div class="reco-right">
              <div class="reco-chip" style="background:${hex}"></div>
              <button type="button" class="btn btn-sm btn-outline-primary tryon-btn"
                      data-id="${id}" data-hex="${hex}" data-cat="${cat}">
                <span class="spinner-border spinner-border-sm d-none"></span>
                <span class="btn-text">입어보기</span>
              </button>
            </div>
          </div>
        `);
        area.append($card);
      });
    });

    if (!any) area.append('<div class="text-muted small">추천 결과가 없습니다.</div>');
  }

  // 입어보기 클릭
  $('#recoArea').on('click', 'button.tryon-btn', function(){
    const id  = $(this).data('id');
    const hex = $(this).data('hex');
    const cat = $(this).data('cat');
    doTryOn({ id, hex, category: cat }, this);
  });

  async function doTryOn(item, btn){
    if (!lastSelfieFile) { alert('이미지를 선택하세요'); return; }

    const $btn = $(btn);
    $btn.prop('disabled', true).text('처리중...');

    // ✅ 프리뷰 스피너 표시
    $('#tryonSpinner').removeClass('d-none');

    const req = {
      garmentId: item.id,
      colorHex: item.hex || $('#colorHex').val() || '#E6EEF7',
      brightness: parseFloat($('#brightness').val()||0),
      saturation: parseFloat($('#saturation').val()||0),
      category: item.category || item.cat,
      gender: SESSION_GENDER
    };

    try {
      const fd = new FormData();
      fd.append('selfie', lastSelfieFile);
      fd.append('request', new Blob([JSON.stringify(req)], {type:'application/json'}));

      const res = await fetch('/ai4/tryon', { method:'POST', body: fd });
      if (!res.ok) throw new Error('HTTP ' + res.status);
      const data = await res.json();

      if (data.status === 'done' && data.imageB64) {
        const src = data.imageB64.startsWith('data:')
                ? data.imageB64
                : `data:image/png;base64,${data.imageB64}`;
        $('#tryonImage').attr('src', src);
      } else {
        throw new Error(data.message || '합성 실패');
      }
    } catch (e) {
      console.error('[TRYON][ERROR]', e);
      alert('착장 합성 실패: ' + e.message);
    } finally {
      // ✅ 프리뷰 스피너 숨기기
      $('#tryonSpinner').addClass('d-none');
      $btn.prop('disabled', false).text('입어보기');
    }
  }

</script>
