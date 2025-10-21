<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script>
  const reviewCare = {
    form: null,
    feedbackInput: null,
    ratingButtons: [],
    selectedRating: 5,
    alertBox: null,
    resultCard: null,
    ratingSummaryEl: null,
    toneEl: null,
    responseEl: null,
    suggestionsEl: null,
    reviewList: null,
    loginAlert: null,
    isLoggedIn: false,

    init() {
      this.form = document.getElementById('reviewForm');
      this.feedbackInput = document.getElementById('feedbackInput');
      this.alertBox = document.getElementById('formAlert');
      this.resultCard = document.getElementById('planResult');
      this.ratingSummaryEl = document.getElementById('planRating');
      this.toneEl = document.getElementById('planTone');
      this.responseEl = document.getElementById('planResponse');
      this.suggestionsEl = document.getElementById('planSuggestions');
      this.reviewList = document.getElementById('reviewList');
      this.loginAlert = document.getElementById('loginAlert');
      this.ratingButtons = Array.from(document.querySelectorAll('[data-rating-value]'));

      const loggedInAttr = this.form && this.form.dataset ? this.form.dataset.loggedIn : 'false';
      this.isLoggedIn = String(loggedInAttr).toLowerCase() === 'true';

      this.ratingButtons.forEach((button) => {
        button.addEventListener('click', () => {
          const value = Number(button.dataset.ratingValue);
          this.setRating(Number.isFinite(value) ? value : 5);
        });
      });
      this.highlightRating(this.selectedRating);

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
        this.ratingButtons.forEach(button => button.disabled = true);
      } else {
        if (this.feedbackInput) this.feedbackInput.disabled = false;
        if (btn) btn.disabled = false;
        if (this.loginAlert) this.loginAlert.classList.add('d-none');
        this.ratingButtons.forEach(button => button.disabled = false);
      }
    },

    setRating(value) {
      const safeValue = Math.max(1, Math.min(5, Math.round(value)));
      this.selectedRating = safeValue;
      this.highlightRating(safeValue);
    },

    highlightRating(value) {
      this.ratingButtons.forEach((button) => {
        const buttonValue = Number(button.dataset.ratingValue);
        const isActive = buttonValue === value;
        button.classList.toggle('active', isActive);
        button.setAttribute('aria-pressed', String(isActive));
      });
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

    renderPlan(plan) {
      const rating = plan?.rating ?? this.selectedRating;
      const tone = plan?.careTone ?? '케어 응답 준비 중';
      const response = plan?.responseMessage ?? '';
      const suggestions = Array.isArray(plan?.followUpSuggestions) ? plan.followUpSuggestions : [];

      if (this.ratingSummaryEl) {
        this.ratingSummaryEl.textContent = this.starText(rating) + ' (' + rating + '점)';
      }
      if (this.toneEl) this.toneEl.textContent = tone;
      if (this.responseEl) this.responseEl.textContent = response;

      if (this.suggestionsEl) {
        this.suggestionsEl.innerHTML = '';
        if (suggestions.length === 0) {
          const li = document.createElement('li');
          li.textContent = '추가 제안이 없습니다.';
          this.suggestionsEl.appendChild(li);
        } else {
          suggestions.forEach((item) => {
            const li = document.createElement('li');
            li.textContent = item;
            this.suggestionsEl.appendChild(li);
          });
        }
      }

      if (this.resultCard) this.resultCard.classList.remove('d-none');
    },

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

      reviews.forEach((review) => {
        const name = review?.memberName || '익명 회원';
        const text = review?.review || '';
        const when = this.formatDate(review?.createdAt);
        const rating = Number.isFinite(Number(review?.rating)) ? Number(review.rating) : 0;
        const careResponse = review?.careResponse || '';

        const li = document.createElement('li');
        li.className = 'list-group-item';

        const top = document.createElement('div');
        top.className = 'd-flex justify-content-between align-items-center';

        const strong = document.createElement('strong');
        strong.textContent = name;

        const ratingEl = document.createElement('span');
        ratingEl.className = 'text-warning font-weight-bold';
        ratingEl.textContent = this.starText(rating);

        top.appendChild(strong);
        top.appendChild(ratingEl);

        const reviewText = document.createElement('p');
        reviewText.className = 'mb-1';
        reviewText.textContent = text;

        const responseText = document.createElement('p');
        responseText.className = 'mb-1 small text-primary';
        if (careResponse) {
          responseText.textContent = '케어 응답: ' + careResponse;
        } else {
          responseText.textContent = '케어 응답이 준비 중입니다.';
          responseText.classList.add('text-muted');
        }

        const whenEl = document.createElement('small');
        whenEl.className = 'text-muted';
        whenEl.textContent = when;

        li.appendChild(top);
        li.appendChild(reviewText);
        li.appendChild(responseText);
        li.appendChild(whenEl);

        this.reviewList.appendChild(li);
      });
    },

    formatDate(timestamp) {
      if (!timestamp) return '';
      return String(timestamp).replace('T', ' ');
    },

    starText(rating) {
      const safeRating = Math.max(0, Math.min(5, Math.round(rating)));
      const filled = '★'.repeat(safeRating);
      const empty = '☆'.repeat(5 - safeRating);
      return filled + empty;
    },

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
        body: JSON.stringify({ review: feedback, rating: String(this.selectedRating) })
      })
              .then((response) => {
                if (response.status === 401) {
                  throw new Error('후기를 남기려면 로그인해야 합니다.');
                }
                if (!response.ok) {
                  throw new Error('후기를 저장할 수 없습니다.');
                }
                return response.json();
              })
              .then((plan) => {
                this.renderPlan(plan);
                if (this.feedbackInput) this.feedbackInput.value = '';
                this.setRating(5);
                this.loadReviews();
                this.showAlert('후기가 등록되었습니다.', 'success');
              })
              .catch((error) => {
                console.error(error);
                this.showAlert(error.message || '후기 등록 중 문제가 발생했습니다.', 'danger');
              });
    },

    loadReviews() {
      fetch('<c:url value="/api/reviews"/>')
              .then((response) => response.json())
              .then((reviews) => this.renderReviews(reviews))
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
  <p class="text-muted">별점을 선택하고 케어 경험을 들려주시면, 상황에 맞는 AI 케어 응답과 후속 제안을 바로 받아보실 수 있습니다.</p>

  <div id="loginAlert" class="alert alert-info d-none" role="alert">
    로그인 후 후기를 작성하실 수 있습니다. <a href="<c:url value='/login'/>" class="alert-link">로그인 이동</a>
  </div>

  <form id="reviewForm" class="mb-4" data-logged-in="${not empty sessionScope.loginMember}">
    <div class="form-group">
      <label class="d-block">케어 만족도 별점</label>
      <div class="btn-group btn-group-sm mb-2" role="group" aria-label="별점 선택">
        <button type="button" class="btn btn-outline-warning rating-choice" data-rating-value="1">★☆☆☆☆</button>
        <button type="button" class="btn btn-outline-warning rating-choice" data-rating-value="2">★★☆☆☆</button>
        <button type="button" class="btn btn-outline-warning rating-choice" data-rating-value="3">★★★☆☆</button>
        <button type="button" class="btn btn-outline-warning rating-choice" data-rating-value="4">★★★★☆</button>
        <button type="button" class="btn btn-outline-warning rating-choice active" data-rating-value="5" aria-pressed="true">★★★★★</button>
      </div>
    </div>
    <div class="form-group">
      <label for="feedbackInput">사람다움 케어 서비스 이용 후기</label>
      <textarea class="form-control" id="feedbackInput" rows="5" placeholder="케어를 통해 느낀 변화, 함께한 코치, 일상에서의 실천 등을 자유롭게 나눠주세요."></textarea>
      <small class="form-text text-muted">후기와 별점을 보내주시면 상황에 맞는 케어 응답과 후속 제안을 드립니다.</small>
    </div>
    <button type="submit" id="generatePlanBtn" class="btn btn-primary">리뷰 등록 및 케어 응답 받기</button>
    <div id="formAlert" class="mt-3 alert d-none" role="alert"></div>
  </form>

  <div id="planResult" class="card d-none mb-4">
    <div class="card-header">AI 케어 응답</div>
    <div class="card-body">
      <p><strong>선택한 별점:</strong> <span id="planRating"></span></p>
      <p><strong>응답 메시지:</strong></p>
      <p id="planResponse" class="mb-2"></p>
      <div>
        <strong>추천 후속 제안:</strong>
        <ul id="planSuggestions" class="mt-2"></ul>
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