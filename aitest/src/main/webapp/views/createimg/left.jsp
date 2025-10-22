<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  /* 좌측 안내 카드 전용(다른 페이지 영향 최소화) */
  .side-help {
    position: sticky;
    top: 70px;              /* 상단 네비와 간격 */
    z-index: 1;
  }
  .side-help .card {
    border: none;
    border-radius: 10px;
    box-shadow: 0 3px 8px rgba(0,0,0,.05);
  }
  .side-help .card-header {
    background: linear-gradient(135deg, #3b82f6, #2563eb);
    color: #fff;
    font-weight: 600;
    border-top-left-radius: 10px;
    border-top-right-radius: 10px;
  }
  .side-help .list-group-item {
    border: 0;
    padding: .6rem .75rem;
  }
  .side-help .badge-step {
    display: inline-block;
    min-width: 22px;
    height: 22px;
    line-height: 22px;
    text-align: center;
    border-radius: 6px;
    font-size: .75rem;
    font-weight: 700;
    color: #1e40af;
    background: #e0e7ff;
    margin-right: .35rem;
  }
  .side-help .hint {
    font-size: .85rem;
    color: #64748b;
  }
  .side-help .hr {
    border-top: 1px dashed #e2e8f0;
    margin: .5rem 0 .75rem;
  }
  .side-help .mini-chip {
    width: 18px; height: 18px; border-radius: 4px;
    border: 1px solid rgba(0,0,0,.15);
    display: inline-block; margin-right: 4px;
  }
</style>

<div class="col-sm-2">
  <div class="side-help">
    <div class="card mb-3">
      <div class="card-header">
        🎨 AI 추천 옷입히기 안내
      </div>
      <div class="card-body">
        <ul class="list-group list-group-flush">
          <li class="list-group-item">
            <span class="badge-step">1</span>
            <strong>셀피 업로드</strong><br>
            <span class="hint">정면이 또렷한 사진을 선택한 뒤 <em>분석 시작</em>을 눌러요.</span>
          </li>
          <li class="list-group-item">
            <span class="badge-step">2</span>
            <strong>분석 결과 확인</strong><br>
            <span class="hint">톤 · 대비 · 얼굴형 · 분위기와 함께 팔레트가 보여요.</span>
            <div class="mt-1">
              <span class="mini-chip" style="background:#e6eef7"></span>
              <span class="mini-chip" style="background:#cbd5e1"></span>
              <span class="mini-chip" style="background:#94a3b8"></span>
            </div>
          </li>
          <li class="list-group-item">
            <span class="badge-step">3</span>
            <strong>추천 아이템 선택</strong><br>
            <span class="hint">tops / bottoms / outer / onepiece 중에서 <em>입어보기</em>를 눌러요.</span>
          </li>
          <li class="list-group-item">
            <span class="badge-step">4</span>
            <strong>가상 착장 프리뷰</strong><br>
            <span class="hint">처리 중에는 버튼에 스피너가 보이고, 완료되면 결과가 우측에 표시돼요.</span>
          </li>
        </ul>

        <div class="hr"></div>

        <div class="hint">
          ▸ 카테고리에 따라 촬영 구도가 달라요:<br>
          <span class="d-block mt-1">• <b>tops</b> 상반신 / <b>outer</b> 반신</span>
          <span class="d-block">• <b>bottoms</b> 전신(신발까지) / <b>onepiece</b> 전신</span>
        </div>

        <div class="hr"></div>

        <div class="hint">
          ▸ 색상은 추천 카드의 칩 색을 그대로 사용해요.<br>
          ▸ 로그인 성별에 맞춰 모델(남/여)이 자동 반영됩니다.
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        ℹ️ 사용 팁
      </div>
      <div class="card-body">
        <div class="hint mb-2">• 사진은 밝은 곳에서, 얼굴/전신이 잘 보이게.</div>
        <div class="hint mb-2">• 결과가 어색하면 색상/밝기/채도를 살짝 조정해 보세요.</div>
        <div class="hint">• 오류가 계속되면 상담으로 연결해 드릴게요.</div>
      </div>
    </div>
  </div>
</div>
