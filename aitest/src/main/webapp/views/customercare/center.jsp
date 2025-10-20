<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script>
  let customerCare = {
    // ====== 상태/참조 캐시 ======
    form: null,
    feedbackInput: null,
    generateButton: null,
    alertBox: null,
    resultCard: null,
    sentimentEl: null,
    priorityEl: null,
    ownerEl: null,
    triggerEl: null,
    actionsEl: null,
    // ====== 초기화 ======
    init() {
      // DOM 요소 캐싱
      this.form = document.getElementById('customerCareForm');
      this.feedbackInput = document.getElementById('feedbackInput');
      this.generateButton = document.getElementById('generatePlanBtn');
      this.alertBox = document.getElementById('formAlert');
      this.resultCard = document.getElementById('planResult');
      this.sentimentEl = document.getElementById('planSentiment');
      this.priorityEl = document.getElementById('planPriority');
      this.ownerEl = document.getElementById('planOwner');
      this.triggerEl = document.getElementById('planTrigger');
      this.actionsEl = document.getElementById('planActions');

      // 폼 이벤트 바인딩
      this.form.addEventListener('submit', (e) => {
        e.preventDefault();
        this.handleSubmit();
      });
    },

    // ====== 유틸 ======
    showAlert(message, type = 'warning') {
      // Bootstrap alert 스타일 적용
      this.alertBox.className = 'mt-3 alert alert-' + type;
      this.alertBox.textContent = message;
      this.alertBox.classList.remove('d-none');
    },
    hideAlert() {
      this.alertBox.classList.add('d-none');
    },
    toggleButton(disabled) {
      this.generateButton.disabled = disabled;
      this.generateButton.innerText = disabled ? 'Generating…' : 'Generate Action Plan';
    },

    // ====== 제출 처리 ======
    handleSubmit() {
      const feedback = (this.feedbackInput.value || '').trim();
      if (!feedback) {
        this.showAlert('실행 계획을 생성하기 전에 피드백을 입력해주세요.', 'warning');
        return;
      }

      this.hideAlert();
      this.toggleButton(true);

      // GET 쿼리 전송 (필요 시 POST로 전환 가능)
      const url = '<c:url value="/customer-care/action-plan"/>?feedback=' + encodeURIComponent(feedback);

      fetch(url, { method: 'GET' })
              .then((res) => {
                if (!res.ok) throw new Error('Failed to generate action plan.');
                return res.json();
              })
              .then((plan) => this.renderPlan(plan))
              .catch((err) => {
                console.error(err);
                this.showAlert('Could not generate an action plan at this time. Please try again later.', 'danger');
                this.resultCard.classList.add('d-none');
              })
              .finally(() => this.toggleButton(false));
    },

    // ====== 렌더링 ======
    renderPlan(plan) {
      // 방어적 접근: plan 객체 필드가 없을 때 기본값 대입
      const sentiment = plan?.sentiment ?? 'N/A';
      const priority = plan?.priority ?? 'N/A';
      const owner = plan?.owner ?? 'N/A';
      const trigger = plan?.automationTrigger ?? 'N/A';
      const actions = Array.isArray(plan?.followUpActions) ? plan.followUpActions : [];

      this.sentimentEl.textContent = sentiment;
      this.priorityEl.textContent = priority;
      this.ownerEl.textContent = owner;
      this.triggerEl.textContent = trigger;

      // 액션 목록 렌더링
      this.actionsEl.innerHTML = '';
      if (actions.length) {
        actions.forEach((a) => {
          const li = document.createElement('li');
          li.textContent = a; // 서버에서 온 문자열 그대로 출력. (HTML 주입 방지: textContent 사용)
          this.actionsEl.appendChild(li);
        });
      } else {
        const li = document.createElement('li');
        li.textContent = 'No follow-up actions available.';
        this.actionsEl.appendChild(li);
      }

      // 결과 카드 표시
      this.resultCard.classList.remove('d-none');
    }
  };

  // DOM이 준비되면 init() 실행 (헤드에 넣어도 안전)
  window.addEventListener('DOMContentLoaded', () => customerCare.init());
</script>



<div class="col-sm-10">
<h2>고객 케어 실행 계획</h2>
<p class="text-muted">고객 피드백을 입력하면 자동으로 후속 조치 계획을 생성합니다.</p>

<form id="customerCareForm" class="mb-4">
  <div class="form-group">
    <label for="feedbackInput">고객 피드백</label>
    <textarea class="form-control" id="feedbackInput" rows="5" placeholder="분석할 고객 피드백을 입력하세요" required></textarea>
    <small class="form-text text-muted">입력된 피드백은 기존 리뷰 분류 AI 서비스를 통해 분석됩니다.</small>
  </div>
  <button type="submit" id="generatePlanBtn" class="btn btn-primary">실행 계획 생성</button>
  <div id="formAlert" class="mt-3 alert d-none" role="alert"></div>
</form>

<div id="planResult" class="card d-none">
  <div class="card-header">실행 계획</div>
  <div class="card-body">
    <p><strong>감정 분석:</strong> <span id="planSentiment"></span></p>
    <p><strong>우선순위:</strong> <span id="planPriority"></span></p>
    <p><strong>담당자:</strong> <span id="planOwner"></span></p>
    <p><strong>자동화 트리거:</strong> <span id="planTrigger"></span></p>
    <div>
      <strong>후속 조치:</strong>
      <ul id="planActions" class="mt-2"></ul>
    </div>
  </div>
</div>
</div>
