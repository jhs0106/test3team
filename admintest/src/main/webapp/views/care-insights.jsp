<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script>
    (function () {
        const careInsightsPage = {
            limitSelect: null,
            errorBox: null,
            state: {
                isLoading: false
            },

            init() {
                // 요소 캐시
                this.limitSelect = document.getElementById('reviewLimit');
                this.errorBox    = document.getElementById('insightError');

                // 셀렉트 변경 → 재조회
                if (this.limitSelect) {
                    this.limitSelect.addEventListener('change', () => this.load());
                }

                // 최초 로딩
                this.load();
            },

            async load() {
                if (!this.limitSelect) return;

                this.showLoading();
                const limit = this.limitSelect.value;

                try {

                    const url = '/api/care-insights?limit=' + encodeURIComponent(limit);

                    const response = await fetch(url, {
                        method: 'GET',
                        headers: {
                            // Spring Security CSRF를 안 쓰거나 GET만 호출하면 불필요.
                            // 'Content-Type': 'application/json'
                        }
                    });

                    if (!response.ok) {
                        // 서버에서 메시지를 내려주면 우선 사용, 없으면 기본 메시지
                        let msg = '케어 인사이트를 불러오지 못했습니다.';
                        try {
                            const maybe = await response.json();
                            if (maybe && maybe.message) msg = maybe.message;
                        } catch (e) { /* ignore parse error */ }
                        throw new Error(msg + ' (HTTP ' + response.status + ')');
                    }

                    const data = await response.json();
                    this.render(data);
                } catch (error) {
                    console.error('[care-insights] load error:', error);
                    this.showError(error.message || '케어 인사이트를 불러오는 중 문제가 발생했습니다.');
                } finally {
                    this.state.isLoading = false;
                }
            },

            showLoading() {
                this.state.isLoading = true;
                this.hideError();
                this.renderActionItems(null); // 로딩 메시지로 초기화
                this.renderReviewList(null);  // 로딩 메시지로 초기화
            },

            showError(message) {
                if (!this.errorBox) return;
                this.errorBox.textContent = message;
                this.errorBox.classList.remove('d-none');
            },

            hideError() {
                if (!this.errorBox) return;
                this.errorBox.classList.add('d-none');
            },

            render(data) {
                if (!data) {
                    this.showError('데이터가 비어 있습니다.');
                    return;
                }

                this.setText('reviewCount', data.reviewCount ?? 0);
                this.setText('averageRating', this.formatAverageRating(data.averageRating));
                this.setText('positiveCount', data.positiveCount ?? 0);
                this.setText('neutralCount', '중립 ' + (data.neutralCount ?? 0));
                this.setText('negativeCount', data.negativeCount ?? 0);
                this.setText('summaryText', data.summary || '요약 정보가 없습니다.');
                this.setText('careFocusText', data.careFocus || '집중해야 할 케어 포인트를 찾을 수 없습니다.');
                this.setText('encouragementText', data.encouragement || '케어 팀에게 전할 메시지가 없습니다.');

                this.renderActionItems(data.actionItems);
                this.renderReviewList(data.recentReviews);
            },

            setText(id, text) {
                const el = document.getElementById(id);
                if (el) el.textContent = String(text);
            },

            renderActionItems(items) {
                const container = document.getElementById('actionItems');
                if (!container) return;

                container.innerHTML = '';
                const list = Array.isArray(items) ? items : [];

                if (list.length === 0) {
                    const li = document.createElement('li');
                    li.className = 'list-group-item text-muted';
                    li.textContent = this.state.isLoading ? '데이터를 불러오는 중입니다…' : '추천 실행 과제가 없습니다.';
                    container.appendChild(li);
                    return;
                }

                list.forEach((item) => {
                    const li = document.createElement('li');
                    li.className = 'list-group-item';
                    li.textContent = item;
                    container.appendChild(li);
                });
            },

            renderReviewList(reviews) {
                const container = document.getElementById('reviewList');
                if (!container) return;

                container.innerHTML = '';
                const list = Array.isArray(reviews) ? reviews : [];

                if (list.length === 0) {
                    const empty = document.createElement('div');
                    empty.className = 'list-group-item text-muted';
                    empty.textContent = this.state.isLoading ? '데이터를 불러오는 중입니다…' : '리뷰가 없습니다.';
                    container.appendChild(empty);
                    return;
                }

                list.forEach((review) => {
                    const item = document.createElement('div');
                    item.className = 'list-group-item';

                    const header = document.createElement('div');
                    header.className = 'd-flex justify-content-between align-items-center';

                    const title = document.createElement('strong');
                    title.textContent = review?.memberName || '익명 회원';

                    const mood = (review?.sentiment || 'UNKNOWN').toString().toUpperCase();
                    const sentimentBadge = document.createElement('span');
                    sentimentBadge.className = 'badge badge-' + this.sentimentBadgeClass(mood);
                    sentimentBadge.textContent = mood;

                    header.appendChild(title);
                    header.appendChild(sentimentBadge);

                    const rating = Number.isFinite(Number(review?.rating)) ? Number(review.rating) : 0;
                    const ratingInfo = document.createElement('div');
                    ratingInfo.className = 'small text-warning font-weight-bold mt-1';
                    ratingInfo.textContent = this.starText(rating) + ' (' + rating + '점)';

                    const text = document.createElement('p');
                    text.className = 'mb-1 text-gray-800';
                    text.textContent = review?.review || '';

                    const careResponse = review?.careResponse || '';
                    const response = document.createElement('p');
                    response.className = 'mb-1';
                    if (careResponse) {
                        response.classList.add('text-primary');
                        response.textContent = '케어 응답: ' + careResponse;
                    } else {
                        response.classList.add('text-muted');
                        response.textContent = '케어 응답 기록 없음';
                    }

                    const when = document.createElement('small');
                    when.className = 'text-muted';
                    when.textContent = this.formatDate(review?.createdAt);

                    item.appendChild(header);
                    item.appendChild(ratingInfo);
                    item.appendChild(text);
                    item.appendChild(response);
                    item.appendChild(when);
                    container.appendChild(item);
                });
            },

            formatDate(value) {
                if (!value) return '작성일 미상';
                // ISO8601(YYYY-MM-DDTHH:mm:ss) → 'YYYY-MM-DD HH:mm' 형태로 자르기
                return String(value).replace('T', ' ').substring(0, 16);
            },

            formatAverageRating(value) {
                const numeric = Number.isFinite(Number(value)) ? Number(value) : 0;
                const rounded = Math.round(numeric * 10) / 10;
                return this.starText(rounded) + ' (' + rounded.toFixed(1) + '점)';
            },


            sentimentBadgeClass(sentiment) {
                switch (sentiment) {
                    case 'POSITIVE':
                        return 'success';
                    case 'NEGATIVE':
                        return 'danger';
                    case 'NEUTRAL':
                        return 'secondary';
                    default:
                        return 'light';
                }
            },

            starText(value) {
                const safe = Math.max(0, Math.min(5, Math.round(value)));
                const filled = '★'.repeat(safe);
                const empty = '☆'.repeat(5 - safe);
                return filled + empty;
            }

        };

        // 페이지가 DOM을 그리기 시작할 때 등록 (스크립트가 상단이므로 필수)
        document.addEventListener('DOMContentLoaded', () => careInsightsPage.init());
    })();
</script>

<div class="container-fluid" id="careInsightsRoot">
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">사람다움 케어 인사이트</h1>

        <div class="form-inline">
            <label for="reviewLimit" class="mr-2 text-gray-600">최근 리뷰 수</label>
            <select id="reviewLimit" class="custom-select custom-select-sm shadow-sm" aria-label="최근 리뷰 수 선택">
                <option value="5">5개</option>
                <option value="10" selected>10개</option>
                <option value="20">20개</option>
            </select>
        </div>
    </div>

    <div id="insightError" class="alert alert-danger d-none" role="alert"></div>

    <div class="row">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-primary shadow h-100 py-2">
                <div class="card-body">
                    <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">전체 리뷰</div>
                    <div id="reviewCount" class="h5 mb-0 font-weight-bold text-gray-800">0</div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-warning shadow h-100 py-2">
                <div class="card-body">
                    <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">평균 별점</div>
                    <div id="averageRating" class="h5 mb-0 font-weight-bold text-gray-800">☆☆☆☆☆ (0.0점)</div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-success shadow h-100 py-2">
                <div class="card-body">
                    <div class="text-xs font-weight-bold text-success text-uppercase mb-1">긍정 반응</div>
                    <div id="positiveCount" class="h5 mb-0 font-weight-bold text-gray-800">0</div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-danger shadow h-100 py-2">
                <div class="card-body">
                    <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">주의 필요</div>
                    <div class="d-flex justify-content-between align-items-center">
                        <span id="negativeCount" class="h5 mb-0 font-weight-bold text-gray-800">0</span>
                        <span id="neutralCount" class="badge badge-secondary">중립 0</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <!-- 좌측: 요약/응원 -->
        <div class="col-lg-6 mb-4">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex justify-content-between align-items-center">
                    <h6 class="m-0 font-weight-bold text-primary">AI 요약</h6>
                </div>
                <div class="card-body">
                    <p id="summaryText" class="text-gray-800 mb-3"></p>
                    <div class="border-left-primary pl-3">
                        <h6 class="font-weight-bold text-primary">집중 케어 포인트</h6>
                        <p id="careFocusText" class="text-gray-800 mb-0"></p>
                    </div>
                </div>
            </div>

            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">케어 팀 응원</h6>
                </div>
                <div class="card-body">
                    <p id="encouragementText" class="text-gray-800 mb-0"></p>
                </div>
            </div>
        </div>

        <!-- 우측: 실행 과제 / 최근 리뷰 -->
        <div class="col-lg-6 mb-4">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">실행 과제</h6>
                </div>
                <div class="card-body">
                    <ul id="actionItems" class="list-group list-group-flush">
                        <li class="list-group-item text-muted">데이터를 불러오는 중입니다…</li>
                    </ul>
                </div>
            </div>

            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">최근 리뷰</h6>
                </div>
                <div class="card-body p-0">
                    <div id="reviewList" class="list-group list-group-flush small">
                        <div class="list-group-item text-muted">데이터를 불러오는 중입니다…</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
