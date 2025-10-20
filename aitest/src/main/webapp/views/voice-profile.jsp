<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .voice-profile-container {
        max-width: 800px;
        margin: 50px auto;
        padding: 30px;
        background: #f8f9fa;
        border-radius: 15px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }

    .record-btn {
        width: 150px;
        height: 150px;
        border-radius: 50%;
        font-size: 24px;
        margin: 20px auto;
        display: block;
    }

    .profile-result {
        background: white;
        padding: 20px;
        border-radius: 10px;
        margin-top: 20px;
    }

    .audio-player {
        width: 100%;
        margin-top: 15px;
    }

    .step-indicator {
        display: flex;
        justify-content: space-between;
        margin-bottom: 30px;
    }

    .step {
        flex: 1;
        text-align: center;
        padding: 10px;
        background: #e9ecef;
        margin: 0 5px;
        border-radius: 5px;
    }

    .step.active {
        background: #007bff;
        color: white;
    }

    .step.completed {
        background: #28a745;
        color: white;
    }
</style>

<script>
    let voiceProfile = {
        mediaRecorder: null,
        audioChunks: [],
        currentStep: 1,

        init: function() {
            this.setupRecordButton();
            $('#submit-text').click(() => this.submitText());
            $('#retry-record').click(() => this.resetRecording());
        },

        setupRecordButton: function() {
            $('#record-btn').click(() => {
                if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
                    this.stopRecording();
                } else {
                    this.startRecording();
                }
            });
        },

        startRecording: async function() {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                this.mediaRecorder = new MediaRecorder(stream);
                this.audioChunks = [];

                this.mediaRecorder.ondataavailable = (event) => {
                    this.audioChunks.push(event.data);
                };

                this.mediaRecorder.onstop = () => {
                    const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
                    this.displayRecordedAudio(audioBlob);
                    this.updateStep(2);
                };

                this.mediaRecorder.start();
                $('#record-btn').removeClass('btn-primary').addClass('btn-danger')
                        .html('<i class="fas fa-stop"></i><br>녹음 중...');
                $('#status-text').text('녹음 중입니다. 자기소개를 말씀해주세요.');

            } catch (error) {
                console.error('마이크 접근 오류:', error);
                alert('마이크 접근 권한이 필요합니다.');
            }
        },

        stopRecording: function() {
            if (this.mediaRecorder) {
                this.mediaRecorder.stop();
                this.mediaRecorder.stream.getTracks().forEach(track => track.stop());
                $('#record-btn').removeClass('btn-danger').addClass('btn-primary')
                        .html('<i class="fas fa-microphone"></i><br>녹음 시작');
                $('#status-text').text('녹음이 완료되었습니다.');
            }
        },

        displayRecordedAudio: function(audioBlob) {
            const audioUrl = URL.createObjectURL(audioBlob);
            const audioPlayer = `
            <div class="text-center">
                <h5>녹음된 자기소개</h5>
                <audio controls class="audio-player">
                    <source src="${audioUrl}" type="audio/webm">
                </audio>
                <div class="mt-3">
                    <button id="process-voice" class="btn btn-success btn-lg">
                        <i class="fas fa-magic"></i> AI 프로필 생성
                    </button>
                    <button id="retry-record" class="btn btn-secondary">
                        <i class="fas fa-redo"></i> 다시 녹음
                    </button>
                </div>
            </div>
        `;
            $('#recorded-audio').html(audioPlayer);

            $('#process-voice').click(() => this.processVoiceProfile(audioBlob));
        },

        processVoiceProfile: async function(audioBlob) {
            $('#status-text').text('AI가 프로필을 생성하는 중입니다...');
            this.showSpinner(true);

            const formData = new FormData();
            formData.append('voiceFile', audioBlob, 'voice-intro.webm');

            try {
                const response = await fetch('/api/voice-profile/create', {
                    method: 'POST',
                    body: formData
                });

                const result = await response.json();
                this.displayProfile(result);
                this.updateStep(3);

            } catch (error) {
                console.error('프로필 생성 오류:', error);
                alert('프로필 생성에 실패했습니다.');
            } finally {
                this.showSpinner(false);
            }
        },

        displayProfile: function(data) {
            const profileHtml = `
            <div class="profile-result">
                <h4><i class="fas fa-user-circle"></i> AI가 생성한 프로필</h4>
                <div class="alert alert-info">
                    <h6>원본 텍스트:</h6>
                    <p>${data.originalText}</p>
                </div>
                <div class="alert alert-success">
                    <h6><i class="fas fa-star"></i> 정리된 프로필:</h6>
                    <p>${data.summary}</p>
                </div>
                <div class="text-center">
                    <h6>음성 프로필</h6>
                    <audio controls class="audio-player" autoplay>
                        <source src="data:audio/mp3;base64,${data.voiceProfile}" type="audio/mp3">
                    </audio>
                </div>
                <div class="text-center mt-3">
                    <button class="btn btn-primary" onclick="voiceProfile.saveProfile('${data.summary}')">
                        <i class="fas fa-save"></i> 프로필 저장
                    </button>
                </div>
            </div>
        `;
            $('#profile-result').html(profileHtml);
            $('#status-text').text('프로필이 생성되었습니다!');
        },

        submitText: function() {
            const text = $('#text-intro').val().trim();
            if (!text) {
                alert('자기소개를 입력해주세요.');
                return;
            }

            this.showSpinner(true);
            $.ajax({
                url: '/voice-profile/summarize',
                method: 'POST',
                data: { text: text },
                success: (result) => {
                    this.displayProfile({
                        originalText: text,
                        summary: result.summary,
                        voiceProfile: ''
                    });
                    this.generateVoiceFromText(result.summary);
                },
                error: () => alert('프로필 생성 실패'),
                complete: () => this.showSpinner(false)
            });
        },

        generateVoiceFromText: function(summary) {
            $.ajax({
                url: '/voice-profile/read-aloud',
                method: 'POST',
                data: { profileText: summary },
                success: (result) => {
                    const audioHtml = `
                    <audio controls class="audio-player" autoplay>
                        <source src="data:audio/mp3;base64,${result.audio}" type="audio/mp3">
                    </audio>
                `;
                    $('#profile-result').append(audioHtml);
                }
            });
        },

        saveProfile: function(summary) {
            // TODO: 데이터베이스 저장 로직 구현
            alert('프로필이 저장되었습니다:\n' + summary);
        },

        resetRecording: function() {
            $('#recorded-audio').empty();
            $('#profile-result').empty();
            this.updateStep(1);
            $('#status-text').text('녹음 버튼을 눌러 자기소개를 시작하세요.');
        },

        updateStep: function(step) {
            this.currentStep = step;
            $('.step').removeClass('active completed');

            for (let i = 1; i < step; i++) {
                $(`.step:nth-child(${i})`).addClass('completed');
            }
            $(`.step:nth-child(${step})`).addClass('active');
        },

        showSpinner: function(show) {
            if (show) {
                $('#spinner').show();
            } else {
                $('#spinner').hide();
            }
        }
    };

    $(document).ready(function() {
        voiceProfile.init();
    });
</script>

<div class="voice-profile-container">
    <h2 class="text-center mb-4">
        <i class="fas fa-microphone-alt"></i> 음성 프로필 생성
    </h2>

    <div class="step-indicator">
        <div class="step active">
            <i class="fas fa-microphone"></i><br>녹음
        </div>
        <div class="step">
            <i class="fas fa-file-audio"></i><br>확인
        </div>
        <div class="step">
            <i class="fas fa-robot"></i><br>AI 생성
        </div>
    </div>

    <div class="text-center">
        <p id="status-text" class="lead">녹음 버튼을 눌러 자기소개를 시작하세요.</p>

        <button id="record-btn" class="btn btn-primary record-btn">
            <i class="fas fa-microphone"></i><br>
            녹음 시작
        </button>

        <div id="spinner" class="spinner-border text-primary" style="display:none;"></div>
    </div>

    <div id="recorded-audio" class="mt-4"></div>

    <div id="profile-result" class="mt-4"></div>

    <hr class="my-5">

    <div class="card">
        <div class="card-header">
            <h5><i class="fas fa-keyboard"></i> 텍스트로 입력하기</h5>
        </div>
        <div class="card-body">
            <textarea id="text-intro" class="form-control" rows="5"
                      placeholder="녹음이 어려우시면 여기에 자기소개를 입력하세요."></textarea>
            <button id="submit-text" class="btn btn-info mt-3">
                <i class="fas fa-paper-plane"></i> 프로필 생성
            </button>
        </div>
    </div>
</div>