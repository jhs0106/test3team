<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="col-sm-10">
  <div class="card shadow-sm mb-4">
    <div class="card-body">
      <h2 class="card-title mb-4">오늘의 책 추천 설문</h2>
      <p class="text-muted">몇 가지 질문에 답하면 오늘의 기분과 상황에 어울리는 책을 추천해 드릴게요.</p>
      <form id="bookSurveyForm" class="mt-4">
        <div class="mb-4">
          <h5 class="fw-semibold">1. 오늘 기분은 어떤가요?</h5>
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" name="mood" id="moodGood" value="좋음">
            <label class="form-check-label" for="moodGood">좋음</label>
          </div>
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" name="mood" id="moodNormal" value="보통">
            <label class="form-check-label" for="moodNormal">보통</label>
          </div>
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" name="mood" id="moodBad" value="나쁨">
            <label class="form-check-label" for="moodBad">나쁨</label>
          </div>
        </div>

        <div class="mb-4">
          <label for="reason" class="form-label">1-2. 그렇게 생각한 이유가 무엇인가요?</label>
          <textarea class="form-control" id="reason" name="reason" rows="3" placeholder="오늘의 기분을 결정한 사건이나 생각을 간단히 적어주세요."></textarea>
        </div>

        <div class="mb-4">
          <label for="readingTime" class="form-label">2. 하루에 독서 가능한 시간은?</label>
          <select class="form-select" id="readingTime" name="readingTime">
            <option value="">선택해 주세요</option>
            <option value="30분 미만">30분 미만</option>
            <option value="30분 - 1시간">30분 - 1시간</option>
            <option value="1시간 - 2시간">1시간 - 2시간</option>
            <option value="2시간 이상">2시간 이상</option>
          </select>
        </div>

        <div class="mb-4">
          <label for="concern" class="form-label">3. 요즘 고민거리가 있으신가요?</label>
          <textarea class="form-control" id="concern" name="concern" rows="3" placeholder="최근에 가장 신경 쓰이는 고민을 적어주세요."></textarea>
        </div>

        <button type="submit" id="recommendButton" class="btn btn-primary">책 추천받기</button>
      </form>

      <div id="errorMessage" class="alert alert-danger d-none mt-3" role="alert"></div>
    </div>
  </div>

  <div id="recommendationCard" class="card shadow-sm d-none">
    <div class="card-body">
      <h3 class="card-title">AI 추천 결과</h3>
      <p class="text-muted mb-3">아래 추천을 참고해 오늘의 독서를 시작해 보세요.</p>
      <div id="recommendationContent" style="white-space: pre-line;"></div>
    </div>
  </div>
</div>

<script>
  (() => {
    const form = document.getElementById('bookSurveyForm');
    const errorMessageEl = document.getElementById('errorMessage');
    const recommendationCard = document.getElementById('recommendationCard');
    const recommendationContent = document.getElementById('recommendationContent');
    const submitButton = document.getElementById('recommendButton');

    form.addEventListener('submit', async (event) => {
      event.preventDefault();
      errorMessageEl.classList.add('d-none');
      errorMessageEl.textContent = '';

      const selectedMood = form.querySelector('input[name="mood"]:checked');
      if (!selectedMood) {
        errorMessageEl.textContent = '오늘의 기분을 선택해 주세요.';
        errorMessageEl.classList.remove('d-none');
        return;
      }

      const formData = new FormData(form);
      const payload = {
        mood: selectedMood.value,
        reason: formData.get('reason') || '',
        readingTime: formData.get('readingTime') || '',
        concern: formData.get('concern') || ''
      };

      recommendationContent.textContent = '추천을 준비하고 있어요...';
      recommendationCard.classList.remove('d-none');
      submitButton.disabled = true;
      submitButton.textContent = '추천 생성 중...';

      try {
        const response = await fetch('/book/recommend', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          throw new Error(errorData.error || '추천을 가져오는 중 오류가 발생했어요.');
        }

        const data = await response.json();
        recommendationContent.textContent = data.recommendation || '추천 결과를 불러올 수 없어요.';
      } catch (error) {
        recommendationContent.textContent = '';
        recommendationCard.classList.add('d-none');
        errorMessageEl.textContent = error.message;
        errorMessageEl.classList.remove('d-none');
      } finally {
        submitButton.disabled = false;
        submitButton.textContent = '책 추천받기';
      }
    });
  })();
</script>