<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="true" %>

<style>
  .ai-container { max-width: 800px; margin: 0 auto; padding: 20px; }
  .ai-header { background:#2563eb; color:#fff; padding:30px; border-radius:8px; text-align:center; margin-bottom: 30px; }
  .ai-header h2 { margin:0 0 10px; font-size:28px; font-weight:600; }
  .ai-header p { margin:0; opacity:.9; }

  .chip-group { display:flex; gap:8px; flex-wrap:wrap; margin-bottom: 10px; }
  .chip { border:1px solid #e2e8f0; background:#fff; border-radius:20px; padding:6px 12px; cursor:pointer; font-size:13px; }
  .chip.active { background:#2563eb; color:#fff; border-color:#2563eb; }

  .chat-panel { background:#fff; border:1px solid #e2e8f0; border-radius:8px; padding:16px; }
  .chat-messages { height: 420px; overflow-y:auto; background:#f8fafc; border:1px solid #e2e8f0; border-radius:6px; padding:10px; }
  .msg { margin:10px 0; }
  .msg .bubble { display:inline-block; max-width:85%; padding:10px 12px; border-radius:12px; }
  .msg.user .bubble { background:#2563eb; color:#fff; float:right; clear:both; }
  .msg.ai .bubble { background:#fff; border:1px solid #e2e8f0; float:left; clear:both; }
  .badge { display:inline-block; font-size:11px; padding:2px 8px; border-radius:999px; border:1px solid #e2e8f0; margin-right:6px; color:#64748b; }
  .badge[data-topic="PROJECT_HELP"] { color:#0ea5e9; border-color:#0ea5e9; }
  .badge[data-topic="LOVE"], .badge[data-topic="MATCHING"], .badge[data-topic="COACHING"] { color:#2563eb; border-color:#2563eb; }

  .chat-input { display:flex; gap:8px; margin-top:12px; }
  .chat-input textarea { flex:1; height:60px; padding:10px; border:1px solid #e2e8f0; border-radius:6px; }
  .chat-input button { background:#2563eb; color:#fff; border:none; border-radius:6px; padding:0 16px; }
  .handoff { background:#fff8e1; border:1px solid #facc15; color:#7c6f1b; padding:10px; border-radius:6px; margin-top:10px; }
</style>

<script>
  const AI_INQUIRY_URL = '<c:url value="/websocket/inquiry"/>'; // 상담사 페이지

  const aiFront = {
    topicHint: '',

    init() {
      this.bind();
      // 최초 안내 + 사람상담 가이드
      this.addAi(
              "안녕하세요! 결.정.사 AI 상담사입니다 😊\n" +
              "연애 코칭, 매칭 문의, 프로필/스타일 코칭, 가벼운 프로젝트 이슈까지 도와드릴게요.\n" +
              "사람 상담을 원하시면 채팅창에 **“상담사 연결”**이라고 입력해 주세요.",
              "GENERAL"
      );
    },

    bind() {
      document.querySelectorAll('.chip').forEach(ch => {
        ch.addEventListener('click', () => {
          document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
          ch.classList.add('active');
          this.topicHint = ch.dataset.topic || '';
        });
      });

      document.getElementById('sendBtn').addEventListener('click', () => this.send());
      document.getElementById('msg').addEventListener('keypress', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          this.send();
        }
      });
    },

    // 상담사 연결 의도 감지 (붙여쓰기/공백/변형 포괄)
    wantHuman(text) {
      return /(상담\s*사?\s*연결|상담\s*연락|상담원\s*연결|사람\s*상담|human|operator)/i.test(text);
    },

    addUser(text) {
      const box = document.getElementById('chatMsgs');
      const div = document.createElement('div');
      div.className = 'msg user';
      div.innerHTML = `<div class="bubble">${this.escape(text)}</div>`;
      box.appendChild(div);
      box.scrollTop = box.scrollHeight;
    },

    addAi(text, topic) {
      const box = document.getElementById('chatMsgs');
      const div = document.createElement('div');
      div.className = 'msg ai';
      const badge = topic ? `<span class="badge" data-topic="${this.escape(topic)}">${this.escape(topic)}</span>` : '';
      div.innerHTML = `${badge}<div class="bubble">${this.toHtml(text)}</div>`;
      box.appendChild(div);
      box.scrollTop = box.scrollHeight;
    },

    addEscalation() {
      // 안내 띄우고 즉시 이동
      this.addAi('상담사와 연결해드릴게요. 잠시만요…', 'SYSTEM');
      window.location.assign(AI_INQUIRY_URL);
    },

    async send() {
      const $input = document.getElementById('msg');
      const text = ($input.value || '').trim();
      if (!text) return;

      this.addUser(text);
      $input.value = '';

      // 1) 사용자가 곧장 사람상담을 요청한 경우 → LLM 호출 없이 즉시 이동
      if (this.wantHuman(text)) {
        this.addEscalation();
        return;
      }

      // 2) LLM 호출 (백엔드는 항상 깨끗한 JSON AiResponse 반환)
      this.addAi('생각 중이에요… ⏳', 'SYSTEM'); // 로딩 더미
      try {
        const res = await fetch('<c:url value="/aichat-api/message"/>', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ message: text, topicHint: this.topicHint })
        });

        const data = await res.json();

        // 로딩 더미 제거
        const box = document.getElementById('chatMsgs');
        if (box.lastElementChild && box.lastElementChild.classList.contains('msg')) {
          box.removeChild(box.lastElementChild);
        }

        // 사람에게 보여줄 메시지만 렌더
        this.addAi(data.message || '응답을 만들지 못했어요.', data.topic || 'GENERAL');

        // followups를 AI가 문장으로 주면 안내풍선으로 붙임(선택)
        if (Array.isArray(data.followups)) {
          data.followups.forEach(q => this.addAi('❓ ' + q, data.topic || 'GENERAL'));
        }

        // AI가 이관을 결정한 경우 즉시 이동
        if ((data.status === 'ESCALATE') || ((data.action || '').toUpperCase() === 'CALL_AGENT')) {
          this.addEscalation();
        }

      } catch (e) {
        // 로딩 더미 제거
        const box = document.getElementById('chatMsgs');
        if (box.lastElementChild && box.lastElementChild.classList.contains('msg')) {
          box.removeChild(box.lastElementChild);
        }
        this.addAi('죄송해요. 잠시 후 다시 시도해 주세요. (' + this.escape(e.message) + ')', 'GENERAL');
      }
    },

    toHtml(text) {
      if (!text) return '';

      // 1) 모델이 문자열로 준 \n, \t 같은 이스케이프를 실제 문자로 변환
      let s = String(text)
              .replace(/\\r\\n/g, '\n')   // \r\n → \n
              .replace(/\\n/g, '\n')      // \n   → 개행
              .replace(/\\t/g, '    ');   // \t   → 공백 4칸

      // 2) XSS 방지
      s = this.escape(s);

      // 3) (선택) **볼드** Markdown 가볍게 지원
      s = s.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');

      // 4) 개행을 브라우저 라인브레이크로
      s = s.replace(/\n\n+/g, '<br><br>').replace(/\n/g, '<br>');

      return s;
    },


    escape(s) {
      return String(s)
              .replace(/&/g,'&amp;').replace(/</g,'&lt;')
              .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }
  };

  document.addEventListener('DOMContentLoaded', () => aiFront.init());
</script>

<div class="ai-container">
  <div class="ai-header">
    <h2>💬 AI 상담</h2>
    <p>연애/매칭/코칭 + 프로젝트 가벼운 이슈까지 한 번에</p>
  </div>

  <div class="chip-group">
    <button type="button" class="chip" data-topic="LOVE">연애 고민</button>
    <button type="button" class="chip" data-topic="MATCHING">매칭 문의</button>
    <button type="button" class="chip" data-topic="COACHING">프로필/스타일 코칭</button>
    <button type="button" class="chip" data-topic="SCHEDULE">일정 도와줘</button>
    <button type="button" class="chip" data-topic="PROJECT_HELP">프로젝트 도움</button>
  </div>

  <div class="chat-panel">
    <div id="chatMsgs" class="chat-messages"></div>
    <div class="chat-input">
      <textarea id="msg" placeholder="무엇이든 편하게 말씀해 주세요. (Enter로 전송, Shift+Enter 줄바꿈)"></textarea>
      <button id="sendBtn">전송</button>
    </div>
  </div>
</div>
