<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script>
  const reviewCare= {
    form: null,
    feedbackInput: null,
    alertBox: null,
    resultCard: null,
    sentimentEl: null,
    priorityEl: null,
    ownerEl: null,
    triggerEl: null,
    conciergeNoteEl: null,
    actionsEl: null,
    reviewList: null,
    loginAlert: null,
    isLoggedIn: false,

    init() {
      this.form = document.getElementById('reviewForm');
      this.feedbackInput = document.getElementById('feedbackInput');
      this.alertBox = document.getElementById('formAlert');
      this.resultCard = document.getElementById('planResult');
      this.sentimentEl = document.getElementById('planSentiment');
      this.priorityEl = document.getElementById('planPriority');
      this.ownerEl = document.getElementById('planOwner');
      this.triggerEl = document.getElementById('planTrigger');
      this.conciergeNoteEl = document.getElementById('planConciergeNote');
      this.actionsEl = document.getElementById('planActions');
      this.reviewList = document.getElementById('reviewList');
      this.loginAlert = document.getElementById('loginAlert');

      const loggedInAttr = this.form && this.form.dataset ? this.form.dataset.loggedIn : 'false';
      this.isLoggedIn = String(loggedInAttr).toLowerCase() === 'true';

      if (this.form) {
        this.form.addEventListener('submit', (event) => {
          event.preventDefault();
          this.submitReview();
        });
      }
      this.toggleForm();
      this.loadReviews();
    },

    toggleForm() {
      const btn = document.getElementById('generatePlanBtn');
      if (!this.isLoggedIn) {
        if (this.feedbackInput) this.feedbackInput.disabled = true;
        if (btn) btn.disabled = true;
        if (this.loginAlert) this.loginAlert.classList.remove('d-none');
      } else {
        if (this.feedbackInput) this.feedbackInput.disabled = false;
        if (btn) btn.disabled = false;
        if (this.loginAlert) this.loginAlert.classList.add('d-none');
      }
    },

    showAlert(message, type = 'warning') {
      if (!this.alertBox) return;
      this.alertBox.className = 'mt-3 alert alert-' + type;
      this.alertBox.textContent = message;
      this.alertBox.classList.remove('d-none');
    },

    hideAlert() {
      if (!this.alertBox) return;
      this.alertBox.classList.add('d-none');
    },

    // ====== 분석 결과 카드 렌더 ======
    renderPlan(plan) {
      const sentiment = plan?.sentiment ?? '분석 불가';
      const priority = plan?.priority ?? '정보 없음';
      const owner = plan?.owner ?? '담당 코치 확인 필요';
      const trigger = plan?.automationTrigger ?? '자동 케어 없음';
      const conciergeNote = plan?.conciergeNote ?? '';
      const actions = Array.isArray(plan?.followUpActions) ? plan.followUpActions : [];

      if (this.sentimentEl) this.sentimentEl.textContent = sentiment;
      if (this.priorityEl) this.priorityEl.textContent = priority;
      if (this.ownerEl) this.ownerEl.textContent = owner;
      if (this.triggerEl) this.triggerEl.textContent = trigger;
      if (this.conciergeNoteEl) this.conciergeNoteEl.textContent = conciergeNote;

      if (this.actionsEl) {
        this.actionsEl.innerHTML = '';
        if (actions.length === 0) {
          const li = document.createElement('li');
          li.textContent = '추천 후속 조치가 없습니다.';
          this.actionsEl.appendChild(li);
        } else {
          actions.forEach(action => {
            const li = document.createElement('li');
            li.textContent = action;
            this.actionsEl.appendChild(li);
          });
        }
      }
      if (this.resultCard) this.resultCard.classList.remove('d-none');
    },

    // ====== 후기 목록 렌더 (EL 충돌 없는 DOM 조립) ======
    renderReviews(reviews) {
      if (!this.reviewList) return;

      if (!Array.isArray(reviews) || reviews.length === 0) {
        this.reviewList.innerHTML = '';
        const li = document.createElement('li');
        li.className = 'list-group-item text-muted';
        li.textContent = '아직 등록된 후기가 없습니다.';
        this.reviewList.appendChild(li);
        return;
      }

      this.reviewList.innerHTML = '';

      reviews.forEach(review => {
        // 값 가공 (null/undefined 방어)
        const name = (review && review.memberName) ? review.memberName : '익명 회원';
        const sentiment = (review && review.sentiment) ? review.sentiment : 'UNKNOWN';
        const badge = this.badgeClass(sentiment);
        const text = (review && review.review) ? review.review : '';
        const when = this.formatDate(review && review.createdAt);

        // li
        const li = document.createElement('li');
        li.className = 'list-group-item';

        // 상단 행
        const top = document.createElement('div');
        top.className = 'd-flex justify-content-between';

        const strong = document.createElement('strong');
        strong.textContent = name;

        const badgeEl = document.createElement('span');
        badgeEl.className = 'badge badge-' + badge;
        badgeEl.textContent = sentiment;

        top.appendChild(strong);
        top.appendChild(badgeEl);

        // 본문 (XSS 방지: textContent 사용)
        const p = document.createElement('p');
        p.className = 'mb-1';
        p.textContent = text;

        // 날짜
        const small = document.createElement('small');
        small.className = 'text-muted';
        small.textContent = when;

        // 조립
        li.appendChild(top);
        li.appendChild(p);
        li.appendChild(small);

        this.reviewList.appendChild(li);
      });
    },

    // ====== 유틸 ======
    formatDate(timestamp) {
      if (!timestamp) return '';
      // ISO '2025-10-21T10:28:00' -> '2025-10-21 10:28:00'
      return String(timestamp).replace('T', ' ');
    },

    badgeClass(sentiment) {
      switch (String(sentiment).toUpperCase()) {
        case 'POSITIVE': return 'success';
        case 'NEGATIVE': return 'danger';
        case 'NEUTRAL':  return 'secondary';
        default:         return 'secondary';
      }
    },

    // ====== 후기 등록 ======
    submitReview() {
      const feedback = (this.feedbackInput?.value || '').trim();
      if (!feedback) {
        this.showAlert('사람다움 케어 경험을 들려주세요.');
        return;
      }
      this.hideAlert();

      fetch('<c:url value="/api/reviews"/>', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ review: feedback })
      })
              .then(response => {
                if (response.status === 401) {
                  throw new Error('후기를 남기려면 로그인해야 합니다.');
                }
                if (!response.ok) {
                  throw new Error('후기를 저장할 수 없습니다.');
                }
                return response.json();
              })
              .then(plan => {
                this.renderPlan(plan);
                if (this.feedbackInput) this.feedbackInput.value = '';
                this.loadReviews();
                this.showAlert('후기가 등록되었습니다.', 'success');
              })
              .catch(error => {
                console.error(error);
                this.showAlert(error.message || '후기 등록 중 문제가 발생했습니다.', 'danger');
              });
    },

    // ====== 후기 목록 로드 ======
    loadReviews() {
      fetch('<c:url value="/api/reviews"/>')
              .then(response => response.json())
              .then(reviews => this.renderReviews(reviews))
              .catch(() => {
                if (!this.reviewList) return;
                this.reviewList.innerHTML = '';
                const li = document.createElement('li');
                li.className = 'list-group-item text-danger';
                li.textContent = '후기를 불러올 수 없습니다.';
                this.reviewList.appendChild(li);
              });
    }
  };

  window.addEventListener('DOMContentLoaded', () => reviewCare.init());

</script>

<div class="col-sm-10">
  <h2>사람다움 케어 후기 작성</h2>
  <p class="text-muted">사람이 사람답게 살아갈 수 있도록 돕는 케어 경험을 기록하고, AI 코치에게 맞춤 케어 전략을 받아보세요.</p>

  <div id="loginAlert" class="alert alert-info d-none" role="alert">
    로그인 후 후기를 작성하실 수 있습니다. <a href="<c:url value='/login'/>" class="alert-link">로그인 이동</a>
  </div>

  <form id="reviewForm" class="mb-4" data-logged-in="${not empty sessionScope.loginMember}">
    <div class="form-group">
      <label for="feedbackInput">사람다움 케어 서비스 이용 후기</label>
      <textarea class="form-control" id="feedbackInput" rows="5" placeholder="케어를 통해 느낀 변화, 함께한 코치, 일상에서의 실천 등을 자유롭게 나눠주세요."></textarea>
      <small class="form-text text-muted">작성된 리뷰는 AI가 감정과 케어 우선순위를 분석하여 사람다움 케어 플랜을 제안합니다.</small>
    </div>
    <button type="submit" id="generatePlanBtn" class="btn btn-primary">리뷰 등록 및 케어 분석</button>
    <div id="formAlert" class="mt-3 alert d-none" role="alert"></div>
  </form>

  <div id="planResult" class="card d-none mb-4">
    <div class="card-header">AI 케어 전략</div>
    <div class="card-body">
      <p><strong>감정 분석:</strong> <span id="planSentiment"></span></p>
      <p><strong>케어 우선순위:</strong> <span id="planPriority"></span></p>
      <p><strong>담당 케어 코치:</strong> <span id="planOwner"></span></p>
      <p><strong>자동 케어 트리거:</strong> <span id="planTrigger"></span></p>
      <p><strong>케어 노트:</strong> <span id="planConciergeNote"></span></p>
      <div>
        <strong>제안된 실천 과제:</strong>
        <ul id="planActions" class="mt-2"></ul>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
      <span>최근 후기</span>
      <c:choose>
        <c:when test="${empty sessionScope.loginMember}">
          <a href="<c:url value='/register'/>" class="btn btn-sm btn-outline-secondary">사람다움 케어 함께하기</a>
        </c:when>
        <c:otherwise>
          <span class="small text-muted">함께해 주셔서 감사합니다.</span>
        </c:otherwise>
      </c:choose>
    </div>
    <ul class="list-group list-group-flush" id="reviewList">
      <li class="list-group-item text-muted">후기를 불러오는 중입니다…</li>
    </ul>
  </div>
</div>