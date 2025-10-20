<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
  const clothesCoach = {
    videoElement: null,
    statusElement: null,
    startButton: null,
    resultContainer: null,
    thumbnailContainer: null,
    countdownElement: null,
    stream: null,
    isScanning: false,
    capturedBlobs: {},
    steps: [
      { key: 'front', label: '정면', message: '정면에서 상반신 전체가 보이도록 서주세요.' },
      { key: 'left', label: '좌측', message: '몸을 왼쪽으로 90도 돌려 측면 실루엣을 보여주세요.' },
      { key: 'right', label: '우측', message: '몸을 오른쪽으로 돌려 반대쪽 실루엣을 보여주세요.' }
    ],
    analysisEndpoint: '<c:url value="/aidaon/clothes/analyze"/>',

    init() {
      this.videoElement = document.getElementById('clothesCamera');
      this.statusElement = document.getElementById('clothesStatus');
      this.startButton = document.getElementById('clothesScanButton');
      this.resultContainer = document.getElementById('clothesAnalysisResult');
      this.thumbnailContainer = document.getElementById('clothesCapturedThumbnails');
      this.countdownElement = document.getElementById('clothesScanCountdown');

      this.startButton.addEventListener('click', () => this.startScan());
      this.prepareCamera();
    },

    async prepareCamera() {
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        this.updateStatus('이 브라우저에서는 카메라 접근을 지원하지 않습니다.');
        this.startButton.disabled = true;
        return;
      }

      try {
        this.updateStatus('카메라를 준비하는 중입니다...');
        this.stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
        this.videoElement.srcObject = this.stream;
        await this.videoElement.play();
        this.updateStatus('카메라가 준비되었습니다. "스캔 시작" 버튼을 눌러주세요.');
      } catch (error) {
        console.error('카메라 접근 실패', error);
        this.updateStatus('카메라를 사용할 수 없습니다. 권한을 확인해주세요.');
        this.startButton.disabled = true;
      }
    },

    async startScan() {
      if (this.isScanning) {
        return;
      }
      this.isScanning = true;
      this.capturedBlobs = {};
      this.startButton.disabled = true;
      this.clearResults();

      for (const step of this.steps) {
        const captured = await this.captureStep(step);
        if (!captured) {
          this.updateStatus(step.label + ' 촬영에 실패했습니다. 다시 시도해주세요.');
          this.isScanning = false;
          this.startButton.disabled = false;
          return;
        }
        this.capturedBlobs[step.key] = captured;
      }

      await this.sendForAnalysis();
      this.isScanning = false;
      this.startButton.disabled = false;
    },

    async captureStep(step) {
      this.updateStatus(step.message);
      await this.showCountdown(3);
      const frame = await this.captureFrame();
      if (!frame) {
        return null;
      }
      this.renderThumbnail(step, frame);
      return frame;
    },

    showCountdown(seconds) {
      return new Promise((resolve) => {
        let remaining = seconds;
        this.countdownElement.textContent = String(remaining);
        this.countdownElement.classList.remove('d-none');

        const timer = setInterval(() => {
          remaining -= 1;
          if (remaining <= 0) {
            clearInterval(timer);
            this.countdownElement.textContent = '';
            this.countdownElement.classList.add('d-none');
            resolve();
          } else {
            this.countdownElement.textContent = String(remaining);
          }
        }, 1000);
      });
    },

    captureFrame() {
      const video = this.videoElement;
      if (!video || video.videoWidth === 0 || video.videoHeight === 0) {
        return Promise.resolve(null);
      }

      const canvas = document.createElement('canvas');
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      const context = canvas.getContext('2d');
      context.drawImage(video, 0, 0, canvas.width, canvas.height);

      return new Promise((resolve) => {
        canvas.toBlob((blob) => resolve(blob), 'image/png');
      });
    },

    renderThumbnail(step, blob) {
      const url = URL.createObjectURL(blob);
      let card = document.querySelector('[data-angle="' + step.key + '"]');
      if (!card) {
        card = document.createElement('div');
        card.className = 'col-md-4';
        card.setAttribute('data-angle', step.key);

        const cardInner = document.createElement('div');
        cardInner.className = 'card shadow-sm';

        const img = document.createElement('img');
        img.className = 'card-img-top';
        img.alt = step.label + ' 캡쳐 이미지';
        cardInner.appendChild(img);

        const body = document.createElement('div');
        body.className = 'card-body p-2';

        const text = document.createElement('p');
        text.className = 'card-text text-center small mb-0';
        text.textContent = step.label;
        body.appendChild(text);

        cardInner.appendChild(body);
        card.appendChild(cardInner);
        this.thumbnailContainer.appendChild(card);
      }
      const imgElement = card.querySelector('img');
      if (imgElement) {
        imgElement.src = url;
      }
    },

    async sendForAnalysis() {
      this.updateStatus('촬영한 이미지를 분석 중입니다...');
      const formData = new FormData();
      Object.keys(this.capturedBlobs).forEach((key) => {
        const blob = this.capturedBlobs[key];
        formData.append(key, blob, key + '.png');
      });

      try {
        const response = await fetch(this.analysisEndpoint, {
          method: 'POST',
          body: formData
        });

        if (!response.ok) {
          const error = await response.json().catch(() => ({}));
          const message = error.error || '분석 요청에 실패했습니다.';
          this.updateStatus(message);
          return;
        }

        const data = await response.json();
        this.displayResults(data);
        this.updateStatus('분석이 완료되었습니다. 결과를 확인해주세요.');
      } catch (error) {
        console.error('분석 호출 실패', error);
        this.updateStatus('분석 서버와 통신 중 오류가 발생했습니다.');
      }
    },

    displayResults(data) {
      this.resultContainer.innerHTML = '';

      if (data.summary) {
        const summaryCard = document.createElement('div');
        summaryCard.className = 'card mb-3 border-primary';

        const header = document.createElement('div');
        header.className = 'card-header bg-primary text-white';
        header.textContent = '스타일링 요약';

        const body = document.createElement('div');
        body.className = 'card-body';

        const paragraph = document.createElement('p');
        paragraph.className = 'card-text';
        paragraph.innerHTML = this.formatText(data.summary);

        body.appendChild(paragraph);
        summaryCard.appendChild(header);
        summaryCard.appendChild(body);
        this.resultContainer.appendChild(summaryCard);
      }
    },

    formatText(text) {
      if (!text) {
        return '';
      }
      return text
              .replace(/\r\n/g, '\n')
              .replace(/\n\n+/g, '</p><p class="card-text">')
              .replace(/\n/g, '<br/>');
    },

    clearResults() {
      this.resultContainer.innerHTML = '';
      this.thumbnailContainer.innerHTML = '';
    },

    updateStatus(message) {
      if (this.statusElement) {
        this.statusElement.textContent = message;
      }
    }
  };

  document.addEventListener('DOMContentLoaded', () => clothesCoach.init());
</script>

<div class="col-sm-10">
  <h2>Clothes</h2>
  <p class="text-muted">다양한 각도에서 촬영해 맞춤형 스타일링 코칭을 받아보세요.</p>

  <div class="row g-4">
    <div class="col-lg-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">실시간 카메라 미리보기</h5>
          <video id="clothesCamera" class="w-100 rounded" autoplay muted playsinline></video>
          <div class="text-center mt-3">
            <span id="clothesScanCountdown" class="display-5 fw-bold text-primary d-none"></span>
          </div>
          <p id="clothesStatus" class="text-muted small mt-3">카메라 초기화 중...</p>
          <button id="clothesScanButton" class="btn btn-primary w-100">스캔 시작</button>
        </div>
      </div>
    </div>
    <div class="col-lg-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">촬영된 각도</h5>
          <p class="text-muted small">각 촬영 단계마다 미리보기가 표시됩니다.</p>
          <div id="clothesCapturedThumbnails" class="row g-3"></div>
        </div>
      </div>
    </div>
  </div>

  <div class="mt-4" id="clothesAnalysisResult"></div>
</div>