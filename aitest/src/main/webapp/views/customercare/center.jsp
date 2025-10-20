<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script>
  let customerCare = {
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
              this.form = document.getElementById('customerCareForm');
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
              this.isLoggedIn = this.form?.dataset.loggedIn === 'true';

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
              if (!this.isLoggedIn) {
                this.feedbackInput.disabled = true;
                document.getElementById('generatePlanBtn').disabled = true;
                this.loginAlert.classList.remove('d-none');
              } else {
                this.feedbackInput.disabled = false;
                document.getElementById('generatePlanBtn').disabled = false;
                this.loginAlert.classList.add('d-none');
              }
            },
            showAlert(message, type = 'warning') {
              this.alertBox.className = 'mt-3 alert alert-' + type;
              this.alertBox.textContent = message;
              this.alertBox.classList.remove('d-none');
            },
            hideAlert() {
              this.alertBox.classList.add('d-none');
            },
    renderPlan(plan) {
      const sentiment = plan?.sentiment ?? '분석 불가';
      const priority = plan?.priority ?? '정보 없음';
      const owner = plan?.owner ?? '담당 부서 확인 필요';
      const trigger = plan?.automationTrigger ?? '자동 조치 없음';
      const conciergeNote = plan?.conciergeNote ?? '';
      const actions = Array.isArray(plan?.followUpActions) ? plan.followUpActions : [];

      this.sentimentEl.textContent = sentiment;
      this.priorityEl.textContent = priority;
      this.ownerEl.textContent = owner;
      this.triggerEl.textContent = trigger;
      if (this.conciergeNoteEl) {
        this.conciergeNoteEl.textContent = conciergeNote;
      }

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
      this.resultCard.classList.remove('d-none');
    },
    renderReviews(reviews) {
      if (!Array.isArray(reviews) || reviews.length === 0) {
        this.reviewList.innerHTML = '<li class="list-group-item text-muted">아직 등록된 후기가 없습니다.</li>';
        return;
      }
      this.reviewList.innerHTML = '';
      reviews.forEach(review => {
        const li = document.createElement('li');
        li.className = 'list-group-item';
        li.innerHTML = `<div class="d-flex justify-content-between">
          <strong>${empty review.memberName ? '익명 회원' : review.memberName}</strong>
          <span class="badge badge-${this.badgeClass(review.sentiment)}">${review.sentiment}</span>
        </div>
        <p class="mb-1">${review.review}</p>
        <small class="text-muted">${this.formatDate(review.createdAt)}</small>`;
        this.reviewList.appendChild(li);
      });
    },
    formatDate(timestamp) {
      if (!timestamp) {
        return '';
      }
      return timestamp.replace('T', ' ');
    },
    badgeClass(sentiment) {
      switch (sentiment) {
        case 'POSITIVE':
          return 'success';
        case 'NEGATIVE':
          return 'danger';
        default:
          return 'secondary';
      }
    },
    submitReview() {
      const feedback = (this.feedbackInput.value || '').trim();
      if (!feedback) {
        this.showAlert('결정사 서비스 후기를 입력해주세요.');
        return;
      }
      this.hideAlert();
      fetch('<c:url value="/customer-care/reviews"/>', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
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
                this.feedbackInput.value = '';
                this.loadReviews();
                this.showAlert('후기가 등록되었습니다.', 'success');
              })
              .catch(error => {
                console.error(error);
                this.showAlert(error.message || '후기 등록 중 문제가 발생했습니다.', 'danger');
              });
    },
    loadReviews() {
      fetch('<c:url value="/customer-care/reviews"/>')
              .then(response => response.json())
              .then(reviews => this.renderReviews(reviews))
              .catch(() => {
                this.reviewList.innerHTML = '<li class="list-group-item text-danger">후기를 불러올 수 없습니다.</li>';
              });
    }
  };

  window.addEventListener('DOMContentLoaded', () => customerCare.init());
</script>

<div class="col-sm-10">
  <h2>결정사 고객 케어 센터</h2>
  <p class="text-muted">결혼 정보사 결정사 회원들의 생생한 후기를 수집하고, AI가 맞춤형 케어 전략을 제안합니다.</p>

  <div id="loginAlert" class="alert alert-info d-none" role="alert">
    로그인 후 후기를 작성하실 수 있습니다. <a href="<c:url value='/login'/>" class="alert-link">로그인 이동</a>
  </div>

  <form id="customerCareForm" class="mb-4" data-logged-in="${not empty sessionScope.loginMember}">
    <div class="form-group">
      <label for="feedbackInput">결정사 서비스 이용 후기</label>
      <textarea class="form-control" id="feedbackInput" rows="5" placeholder="담당 매니저, 맞춤 소개, 상담 분위기 등에 대한 의견을 남겨주세요"></textarea>
      <small class="form-text text-muted">입력한 후기는 AI가 감정과 케어 우선순위를 분석하고, 결정사 운영팀 대응 전략에 활용됩니다.</small>
    </div>
    <button type="submit" id="generatePlanBtn" class="btn btn-primary">후기 등록 및 분석</button>
    <div id="formAlert" class="mt-3 alert d-none" role="alert"></div>
  </form>

  <div id="planResult" class="card d-none mb-4">
    <div class="card-header">AI 케어 전략</div>
    <div class="card-body">
      <p><strong>감정 분석:</strong> <span id="planSentiment"></span></p>
      <p><strong>케어 우선순위:</strong> <span id="planPriority"></span></p>
      <p><strong>담당 매니저:</strong> <span id="planOwner"></span></p>
      <p><strong>자동 케어 트리거:</strong> <span id="planTrigger"></span></p>
      <p><strong>케어 노트:</strong> <span id="planConciergeNote"></span></p>
      <div>
        <strong>제안된 후속 조치:</strong>
        <ul id="planActions" class="mt-2"></ul>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
      <span>최근 후기</span>
      <a href="<c:url value='/register'/>" class="btn btn-sm btn-outline-secondary">결정사 회원 가입</a>
    </div>
    <ul class="list-group list-group-flush" id="reviewList">
      <li class="list-group-item text-muted">후기를 불러오는 중입니다…</li>
    </ul>
  </div>
</div>
