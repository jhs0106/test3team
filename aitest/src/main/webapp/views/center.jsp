<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* 메인 히어로 섹션 - 은은한 회색 톤 */
    .hero-section {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        color: #495057;
        padding: 60px 20px;
        text-align: center;
        border-radius: 12px;
        margin-bottom: 40px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }
    .hero-section h1 {
        font-size: 2.5rem;
        font-weight: 700;
        margin-bottom: 15px;
        color: #212529;
    }
    .hero-section p {
        font-size: 1.1rem;
        margin-bottom: 20px;
        color: #6c757d;
    }

    /* 기능 카드 */
    .feature-card {
        padding: 30px;
        border: 1px solid #dee2e6;
        border-radius: 12px;
        text-align: center;
        transition: all 0.3s ease;
        margin-bottom: 20px;
        background: white;
        height: 100%;
    }
    .feature-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 16px rgba(0,0,0,0.12);
        border-color: #adb5bd;
    }
    .feature-icon {
        font-size: 2.5rem;
        margin-bottom: 15px;
        color: #495057;
    }
    .feature-card h4 {
        font-size: 1.25rem;
        font-weight: 600;
        margin-bottom: 12px;
        color: #212529;
    }
    .feature-card p {
        font-size: 0.95rem;
        color: #6c757d;
        line-height: 1.6;
        margin-bottom: 15px;
    }

    /* 명언 관련 스타일 - 서학적 분위기 */
    .quote-section {
        background: linear-gradient(135deg, #f1f3f5 0%, #e9ecef 100%);
        border-left: 4px solid #495057;
        padding: 30px;
        margin: 30px 0;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    }

    .quote-button {
        background-color: #495057;
        color: white;
        border: none;
        padding: 14px 28px;
        font-size: 15px;
        border-radius: 6px;
        cursor: pointer;
        margin: 15px 0;
        transition: all 0.3s ease;
        font-weight: 500;
    }
    .quote-button:hover {
        background-color: #343a40;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    }
    .quote-button:disabled {
        background-color: #adb5bd;
        cursor: not-allowed;
        transform: none;
    }

    .quote-container {
        background-color: #ffffff;
        border: 1px solid #dee2e6;
        padding: 25px;
        margin: 20px 0;
        border-radius: 8px;
        display: none;
        box-shadow: 0 2px 6px rgba(0,0,0,0.05);
    }

    .quote-text {
        font-size: 1.1rem;
        line-height: 1.8;
        color: #212529;
        white-space: pre-line;
        font-family: 'Noto Serif KR', serif;
    }

    .already-checked {
        font-size: 14px;
        color: #6c757d;
        margin-top: 10px;
        padding: 10px;
        background: #f8f9fa;
        border-radius: 4px;
        text-align: center;
    }

    .login-required {
        background-color: #fff3cd;
        color: #856404;
        border: 1px solid #ffeeba;
        padding: 15px;
        border-radius: 6px;
        margin: 20px 0;
        text-align: center;
    }

    /* 섹션 타이틀 */
    .section-title {
        text-align: center;
        margin-bottom: 40px;
        font-size: 2rem;
        font-weight: 700;
        color: #212529;
    }

    /* 버튼 스타일 */
    .btn-primary {
        background-color: #495057;
        border-color: #495057;
        padding: 10px 20px;
        border-radius: 6px;
        transition: all 0.3s ease;
    }
    .btn-primary:hover {
        background-color: #343a40;
        border-color: #343a40;
        transform: translateY(-2px);
    }

    /* 반응형 */
    @media (max-width: 768px) {
        .hero-section h1 {
            font-size: 2rem;
        }
        .hero-section p {
            font-size: 1rem;
        }
        .feature-card {
            margin-bottom: 15px;
        }
    }
</style>

<script>
    let quoteModule = {
        userId: null,
        hasCheckedToday: false,
        todayQuote: "",
        isLoggedIn: false,

        init: function() {
            // 로그인 상태 확인
            <c:choose>
            <c:when test="${not empty sessionScope.loginMember}">
            this.isLoggedIn = true;
            this.userId = '${sessionScope.loginMember.loginId}';
            </c:when>
            <c:otherwise>
            this.isLoggedIn = false;
            return;
            </c:otherwise>
            </c:choose>

            const today = new Date().toISOString().slice(0, 16);
            const userQuoteKey = 'quote_' + this.userId;
            const userDateKey = 'quoteDate_' + this.userId;

            const lastCheckDate = localStorage.getItem(userDateKey);
            const savedQuote = localStorage.getItem(userQuoteKey);

            if (lastCheckDate === today && savedQuote) {
                this.hasCheckedToday = true;
                this.todayQuote = savedQuote;
                $('#quoteContainer').show();
                $('#quoteText').html(savedQuote);
                $('#quoteBtn').hide();
            }

            $('#quoteBtn').click(() => {
                this.handleQuoteClick();
            });
        },

        handleQuoteClick: function() {
            if (this.hasCheckedToday && this.todayQuote) {
                $('#alreadyChecked').fadeIn();
                setTimeout(() => {
                    $('#alreadyChecked').fadeOut();
                }, 3000);
                return;
            }

            $('#quoteBtn').prop('disabled', true).text('명언을 가져오는 중...');
            this.fetchQuote();
        },

        fetchQuote: async function() {
            try {
                const response = await fetch('/ai3/daily-quote', {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/x-ndjson'
                    }
                });

                if (!response.ok) {
                    throw new Error('명언을 가져오는데 실패했습니다.');
                }

                const reader = response.body.getReader();
                const decoder = new TextDecoder('utf-8');
                let fullQuote = '';

                while (true) {
                    const {value, done} = await reader.read();
                    if (done) break;
                    const chunk = decoder.decode(value);
                    fullQuote += chunk;
                }

                $('#quoteContainer').slideDown();
                await this.playQuoteTTSWithTyping(fullQuote, 30);

                this.todayQuote = fullQuote;
                const today = new Date().toISOString().slice(0, 16);
                const userQuoteKey = 'quote_' + this.userId;
                const userDateKey = 'quoteDate_' + this.userId;

                localStorage.setItem(userDateKey, today);
                localStorage.setItem(userQuoteKey, fullQuote);
                this.hasCheckedToday = true;

                $('#quoteBtn').fadeOut();

            } catch (error) {
                console.error('Error:', error);
                alert('명언을 가져오는데 실패했습니다: ' + error.message);
                $('#quoteBtn').prop('disabled', false).text('📖 오늘의 나를 위한 명언');
            }
        },

        playQuoteTTSWithTyping: async function(text, typingSpeed) {
            try {
                const response = await fetch('/ai3/quote-tts', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: new URLSearchParams({ text: text })
                });

                if (!response.ok) {
                    throw new Error('TTS 생성 실패: ' + response.status);
                }

                const data = await response.json();

                if (!data.audio) {
                    throw new Error('오디오 데이터가 없습니다.');
                }

                const base64Audio = data.audio;
                const binaryString = atob(base64Audio);
                const bytes = new Uint8Array(binaryString.length);
                for (let i = 0; i < binaryString.length; i++) {
                    bytes[i] = binaryString.charCodeAt(i);
                }
                const blob = new Blob([bytes], { type: 'audio/mpeg' });
                const audioUrl = URL.createObjectURL(blob);

                const audioPlayer = document.getElementById('quoteAudioPlayer');
                audioPlayer.src = audioUrl;

                audioPlayer.onplay = async () => {
                    let displayText = '';
                    for (let i = 0; i < text.length; i++) {
                        displayText += text[i];
                        $('#quoteText').html(displayText);
                        await new Promise(resolve => setTimeout(resolve, typingSpeed));
                    }
                };

                const playPromise = audioPlayer.play();
                if (playPromise !== undefined) {
                    await playPromise;
                }

            } catch (error) {
                console.error('TTS 오류:', error);
                $('#quoteText').html(text);
            }
        }
    };

    $(function() {
        quoteModule.init();
    });
</script>

<div class="col-sm-12">
    <!-- 명언 섹션 -->
    <div class="quote-section">
        <h2 style="font-size: 1.5rem; font-weight: 600; margin-bottom: 20px; color: #212529;">오늘의 지혜</h2>

        <c:if test="${empty sessionScope.loginMember}">
            <div class="login-required">
                명언 기능을 사용하려면 <a href="<c:url value='/login'/>" style="color: #856404; font-weight: 600;">로그인</a>이 필요합니다.
            </div>
        </c:if>

        <c:if test="${not empty sessionScope.loginMember}">
            <button id="quoteBtn" class="quote-button">📖 오늘의 나를 위한 명언</button>

            <div id="quoteContainer" class="quote-container">
                <div id="quoteText" class="quote-text"></div>
            </div>

            <div id="alreadyChecked" class="already-checked" style="display: none;">
                오늘은 이미 명언을 확인하셨어요.
            </div>

            <audio id="quoteAudioPlayer" style="display: none;"></audio>
        </c:if>
    </div>

    <!-- Features Section -->
    <h2 class="section-title">사람다움 케어 서비스</h2>

    <div class="row">
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">💄</div>
                <h4>외모 분석</h4>
                <p>AI가 얼굴을 5가지 각도에서 분석하여 맞춤형 스타일링을 제안해드립니다.</p>
                <a href="<c:url value='/appearance'/>" class="btn btn-primary">분석하기</a>
            </div>
        </div>
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">💬</div>
                <h4>AI 상담</h4>
                <p>AI 상담사와 대화하거나 사람 상담사와 연결할 수 있습니다.</p>
                <c:if test="${not empty sessionScope.loginMember}">
                    <a href="<c:url value='/websocket/inquiry'/>" class="btn btn-primary">상담하기</a>
                </c:if>
                <c:if test="${empty sessionScope.loginMember}">
                    <a href="<c:url value='/login'/>" class="btn btn-primary">로그인 필요</a>
                </c:if>
            </div>
        </div>
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">⭐</div>
                <h4>리뷰 작성</h4>
                <p>후기를 남기면 AI가 감정을 분석하고 맞춤형 케어를 제공합니다.</p>
                <a href="<c:url value='/reviews'/>" class="btn btn-primary">리뷰 작성</a>
            </div>
        </div>
    </div>

    <div class="row mt-3">
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">📅</div>
                <h4>일정 관리</h4>
                <p>자연어로 일정을 입력하면 AI가 자동으로 캘린더에 추가합니다.</p>
                <a href="<c:url value='/springai1/schedule'/>" class="btn btn-primary">관리하기</a>
            </div>
        </div>
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">📚</div>
                <h4>오늘의 책</h4>
                <p>AI가 추천하는 오늘의 책을 확인해보세요.</p>
                <a href="<c:url value='/book'/>" class="btn btn-primary">보러가기</a>
            </div>
        </div>
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">📝</div>
                <h4>일기 작성</h4>
                <p>오늘 하루를 기록하고 AI의 따뜻한 피드백을 받아보세요.</p>
                <a href="<c:url value='/diary'/>" class="btn btn-primary">작성하기</a>
            </div>
        </div>
    </div>

    <div class="row mt-3 mb-4">
        <div class="col-md-6">
            <div class="feature-card">
                <div class="feature-icon">🎨</div>
                <h4>이미지 생성</h4>
                <p>AI를 활용한 이미지 생성 기능을 체험해보세요.</p>
                <a href="<c:url value='/createimg/createimg1'/>" class="btn btn-primary">생성하기</a>
            </div>
        </div>
        <div class="col-md-6">
            <div class="feature-card">
                <div class="feature-icon">✅</div>
                <h4>습관 트래커</h4>
                <p>매일의 습관을 기록하고 성장하는 나를 확인하세요.</p>
                <a href="<c:url value='/springai1/ai2'/>" class="btn btn-primary">기록하기</a>
            </div>
        </div>
    </div>
</div>
