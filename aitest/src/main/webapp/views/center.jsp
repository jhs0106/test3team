<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .quote-button {
        background-color: #4e73df;
        color: white;
        border: none;
        padding: 15px 30px;
        font-size: 16px;
        border-radius: 8px;
        cursor: pointer;
        margin: 20px 0;
        transition: all 0.3s;
    }
    .quote-button:hover {
        background-color: #2e59d9;
        transform: translateY(-2px);
    }
    .quote-button:disabled {
        background-color: #858796;
        cursor: not-allowed;
    }
    .quote-container {
        background-color: #f8f9fc;
        border-left: 4px solid #4e73df;
        padding: 20px;
        margin: 20px 0;
        border-radius: 4px;
        display: none;
    }
    .quote-text {
        font-size: 18px;
        line-height: 1.8;
        color: #5a5c69;
        white-space: pre-line;
    }
    .already-checked {
        font-size: 14px;
        color: #858796;
        margin-top: 10px;
    }
    .login-required {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
        padding: 15px;
        border-radius: 4px;
        margin: 20px 0;
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
            return; // 로그인 안 되어 있으면 여기서 종료
            </c:otherwise>
            </c:choose>

            // 사용자별 로컬스토리지 키 생성
            // const today = new Date().toDateString();
            const today = new Date().toISOString().slice(0, 16); // 분 단위까지 (1분마다 리셋)
            const userQuoteKey = 'quote_' + this.userId;
            const userDateKey = 'quoteDate_' + this.userId;

            const lastCheckDate = localStorage.getItem(userDateKey);
            const savedQuote = localStorage.getItem(userQuoteKey);

            // 오늘 이미 확인했는지 체크
            if (lastCheckDate === today && savedQuote) {
                this.hasCheckedToday = true;
                this.todayQuote = savedQuote;

                // 저장된 명언을 화면에 표시
                $('#quoteContainer').show();
                $('#quoteText').html(savedQuote);
                $('#quoteBtn').hide(); // 버튼 숨기기
            }

            // 버튼 클릭 이벤트
            $('#quoteBtn').click(() => {
                this.handleQuoteClick();
            });

            console.log('사용자 ID:', this.userId);
        },

        handleQuoteClick: function() {
            // 이미 확인한 경우
            if (this.hasCheckedToday && this.todayQuote) {
                $('#alreadyChecked').fadeIn();
                setTimeout(() => {
                    $('#alreadyChecked').fadeOut();
                }, 3000);
                return;
            }

            // 버튼 비활성화
            $('#quoteBtn').prop('disabled', true).text('명언을 가져오는 중...');

            // 명언 가져오기
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

                // 1단계: 전체 텍스트를 먼저 다 받기
                const reader = response.body.getReader();
                const decoder = new TextDecoder('utf-8');
                let fullQuote = '';

                while (true) {
                    const {value, done} = await reader.read();
                    if (done) break;
                    const chunk = decoder.decode(value);
                    fullQuote += chunk;
                }

                console.log('명언 수신 완료:', fullQuote.substring(0, 50) + '...');

                // 2단계: 명언 컨테이너 먼저 표시
                $('#quoteContainer').slideDown();

                // 3단계: TTS 재생과 타이핑 효과를 동시에 시작
                await this.playQuoteTTSWithTyping(fullQuote, 30);

                // 명언 저장 (사용자별로)
                this.todayQuote = fullQuote;
                // const today = new Date().toDateString();
                const today = new Date().toISOString().slice(0, 16); // 분 단위까지 (1분마다 리셋)
                const userQuoteKey = 'quote_' + this.userId;
                const userDateKey = 'quoteDate_' + this.userId;

                localStorage.setItem(userDateKey, today);
                localStorage.setItem(userQuoteKey, fullQuote);
                this.hasCheckedToday = true;

                // 버튼 숨기기
                $('#quoteBtn').fadeOut();

            } catch (error) {
                console.error('Error:', error);
                alert('명언을 가져오는데 실패했습니다: ' + error.message);
                $('#quoteBtn').prop('disabled', false).text('📖 오늘의 나를 위한 명언');
            }
        },

        playQuoteTTSWithTyping: async function(text, typingSpeed) {
            try {
                console.log('TTS 요청 시작 (텍스트 길이:', text.length, ')');

                // TTS 요청
                const response = await fetch('/ai3/quote-tts', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: new URLSearchParams({ text: text })
                });

                console.log('TTS 응답 상태:', response.status, response.statusText);

                if (!response.ok) {
                    throw new Error('TTS 생성 실패: ' + response.status);
                }

                const data = await response.json();
                console.log('TTS 데이터 수신 완료');

                if (!data.audio) {
                    throw new Error('오디오 데이터가 없습니다.');
                }

                const base64Audio = data.audio;
                console.log('Base64 오디오 길이:', base64Audio.length);

                // Base64를 Blob으로 변환
                const binaryString = atob(base64Audio);
                const bytes = new Uint8Array(binaryString.length);
                for (let i = 0; i < binaryString.length; i++) {
                    bytes[i] = binaryString.charCodeAt(i);
                }
                const blob = new Blob([bytes], { type: 'audio/mpeg' });
                const audioUrl = URL.createObjectURL(blob);

                console.log('오디오 URL 생성:', audioUrl);

                // 오디오 플레이어 설정
                const audioPlayer = document.getElementById('quoteAudioPlayer');
                audioPlayer.src = audioUrl;

                // 재생 시작 시 타이핑 효과 시작
                audioPlayer.onplay = async () => {
                    console.log('오디오 재생 시작 - 타이핑 효과 시작');

                    // 타이핑 효과
                    let displayText = '';
                    for (let i = 0; i < text.length; i++) {
                        displayText += text[i];
                        $('#quoteText').html(displayText);
                        await new Promise(resolve => setTimeout(resolve, typingSpeed));
                    }
                };

                audioPlayer.onloadeddata = function() {
                    console.log('오디오 로드 완료, 재생 시간:', audioPlayer.duration, '초');
                };

                audioPlayer.onended = function() {
                    console.log('오디오 재생 완료');
                };

                audioPlayer.onerror = function(e) {
                    console.error('오디오 재생 오류:', e);
                    console.error('오디오 에러 코드:', audioPlayer.error ? audioPlayer.error.code : 'unknown');
                };

                // 재생 시작
                const playPromise = audioPlayer.play();

                if (playPromise !== undefined) {
                    await playPromise;
                    console.log('명언 TTS 재생 시작 완료');
                }

            } catch (error) {
                console.error('TTS 오류:', error);
                // TTS 실패해도 명언은 바로 표시
                $('#quoteText').html(text);
            }
        }
    };

    // 페이지 로드 시 초기화
    $(function() {
        quoteModule.init();
    });
</script>

<div class="col-sm-10">
    <h2>오늘의 사자성어 / 명언 / 속담</h2>

    <!-- 로그인 필요 메시지 -->
    <c:if test="${empty sessionScope.loginMember}">
        <div class="login-required">
            명언 기능을 사용하려면 <a href="<c:url value='/login'/>">로그인</a>이 필요합니다.
        </div>
    </c:if>

    <!-- 로그인한 경우에만 명언 버튼 표시 -->
    <c:if test="${not empty sessionScope.loginMember}">
        <!-- 명언 버튼 -->
        <button id="quoteBtn" class="quote-button">📖 오늘의 나를 위한 명언</button>

        <!-- 명언 표시 영역 -->
        <div id="quoteContainer" class="quote-container">
            <div id="quoteText" class="quote-text"></div>
        </div>

        <!-- 이미 확인했다는 메시지 -->
        <div id="alreadyChecked" class="already-checked" style="display: none;">
            오늘은 이미 명언을 확인하셨어요.
        </div>

        <!-- 오디오 플레이어 (숨김) -->
        <audio id="quoteAudioPlayer" style="display: none;"></audio>
    </c:if>
</div>