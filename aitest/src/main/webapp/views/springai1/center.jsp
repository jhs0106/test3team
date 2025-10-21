<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .hero-section {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 80px 20px;
        text-align: center;
        border-radius: 10px;
        margin-bottom: 40px;
    }
    .hero-section h1 {
        font-size: 3rem;
        font-weight: bold;
        margin-bottom: 20px;
    }
    .hero-section p {
        font-size: 1.3rem;
        margin-bottom: 30px;
    }
    .feature-card {
        padding: 30px;
        border: 2px solid #e9ecef;
        border-radius: 10px;
        text-align: center;
        transition: all 0.3s;
        margin-bottom: 20px;
        background: white;
    }
    .feature-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        border-color: #667eea;
    }
    .feature-icon {
        font-size: 3rem;
        margin-bottom: 20px;
        color: #667eea;
    }
    .cta-button {
        padding: 15px 40px;
        font-size: 1.2rem;
        border-radius: 50px;
        margin: 10px;
    }
</style>

<div class="col-sm-10">
    <!-- Hero Section -->
    <div class="hero-section">
        <h1>💑 결정사</h1>
        <p>AI가 찾아주는 완벽한 인연</p>
        <div>
            <c:choose>
                <c:when test="${not empty sessionScope.loginMember}">
                    <a href="<c:url value='/members'/>" class="btn btn-light btn-lg cta-button">회원 매칭 보기</a>
                    <a href="<c:url value='/websocket/inquiry'/>" class="btn btn-outline-light btn-lg cta-button">AI 상담 시작</a>
                </c:when>
                <c:otherwise>
                    <a href="<c:url value='/register'/>" class="btn btn-light btn-lg cta-button">무료 가입하기</a>
                    <a href="<c:url value='/login'/>" class="btn btn-outline-light btn-lg cta-button">로그인</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Features Section -->
    <h2 class="text-center mb-4">결정사만의 특별한 서비스</h2>
    <div class="row">
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">🤖</div>
                <h4>AI 기반 매칭</h4>
                <p>인공지능이 당신의 이상형을 정확하게 분석하여 최적의 파트너를 추천합니다.</p>
                <c:if test="${not empty sessionScope.loginMember}">
                    <a href="<c:url value='/members'/>" class="btn btn-primary">시작하기</a>
                </c:if>
            </div>
        </div>
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">💄</div>
                <h4>외모 컨설팅</h4>
                <p>AI가 얼굴과 의상을 분석하여 맞춤형 스타일링을 제안해드립니다.</p>
                <a href="<c:url value='/appearance'/>" class="btn btn-primary">분석하기</a>
            </div>
        </div>
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">💬</div>
                <h4>24시간 AI 상담</h4>
                <p>언제든지 AI 상담원과 연애 고민, 매칭 문의를 상담할 수 있습니다.</p>
                <c:if test="${not empty sessionScope.loginMember}">
                    <a href="<c:url value='/websocket/inquiry'/>" class="btn btn-primary">상담하기</a>
                </c:if>
            </div>
        </div>
    </div>

    <div class="row mt-4">
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">🎤</div>
                <h4>음성 프로필</h4>
                <p>음성으로 자기소개를 녹음하면 AI가 매력적인 프로필로 자동 정리합니다.</p>
                <a href="<c:url value='/voice-profile/create'/>" class="btn btn-primary">만들기</a>
            </div>
        </div>
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">📅</div>
                <h4>일정 관리</h4>
                <p>자연어로 일정을 입력하면 AI가 자동으로 캘린더에 추가합니다.</p>
                <a href="<c:url value='springai1/schedule'/>" class="btn btn-primary">관리하기</a>
            </div>
        </div>
        <div class="col-md-4">
            <div class="feature-card">
                <div class="feature-icon">⭐</div>
                <h4>고객 케어</h4>
                <p>후기를 남기면 AI가 감정을 분석하고 맞춤형 케어를 제공합니다.</p>
                <a href="<c:url value='/customer-care'/>" class="btn btn-primary">후기 남기기</a>
            </div>
        </div>
    </div>

    <!-- Stats Section -->
    <div class="text-center mt-5 mb-5">
        <h3 class="mb-4">결정사의 성과</h3>
        <div class="row">
            <div class="col-md-3">
                <h2 class="text-primary">1,234+</h2>
                <p>등록 회원</p>
            </div>
            <div class="col-md-3">
                <h2 class="text-success">567+</h2>
                <p>성공한 커플</p>
            </div>
            <div class="col-md-3">
                <h2 class="text-info">89%</h2>
                <p>만족도</p>
            </div>
            <div class="col-md-3">
                <h2 class="text-warning">24/7</h2>
                <p>AI 상담 운영</p>
            </div>
        </div>
    </div>
</div>