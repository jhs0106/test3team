<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="true" %>

<!-- 상단 컨테이너 -->
<div class="col-sm-10"
     id="aiOrchestratorRoot"
      data-cust-id="${sessionScope.loginMember != null ? sessionScope.loginMember.loginId : ''}"
      data-inquiry-url="<c:url value='/websocket/inquiry'/>"
      data-websocket-url="${websocketurl}">

  <!-- ===== AI 패널 ===== -->
  <style>
    .ai-wrap{max-width:900px;margin:0 auto}
    .ai-card{background:#fff;border:1px solid #e2e8f0;border-radius:10px;padding:16px}
    .ai-head{background:#2563eb;color:#fff;padding:24px;border-radius:8px;margin-bottom:16px}
    .chip{border:1px solid #e2e8f0;border-radius:20px;padding:6px 12px;font-size:13px;background:#fff;margin-right:6px;cursor:pointer}
    .chip.active{background:#2563eb;color:#fff;border-color:#2563eb}
    .msgs{height:300px;overflow-y:auto;background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;padding:10px}
    .msg{margin:8px 0}
    .msg .bubble{display:inline-block;max-width:85%;padding:10px 12px;border-radius:12px}
    .msg.user .bubble{background:#2563eb;color:#fff;float:right;clear:both}
    .msg.ai .bubble{background:#fff;border:1px solid #e2e8f0;float:left;clear:both}
    .badge{display:inline-block;font-size:11px;padding:2px 8px;border-radius:999px;border:1px solid #e2e8f0;margin-right:6px;color:#64748b}
    .badge[data-topic="PROJECT_HELP"]{color:#0ea5e9;border-color:#0ea5e9}
    .ai-input{display:flex;gap:8px;margin-top:12px}
    .ai-input textarea{flex:1;height:64px;border:1px solid #e2e8f0;border-radius:6px;padding:10px}
    .ai-input button{background:#2563eb;border:none;color:#fff;border-radius:6px;padding:0 16px}
    .handoff{background:#fff8e1;border:1px solid #facc15;color:#7c6f1b;padding:10px;border-radius:6px;margin-top:10px}
    .pill-btn{border:1px solid #e5e7eb;border-radius:999px;padding:6px 12px;background:#fff;cursor:pointer}
    .pill-btn:hover{background:#f3f4f6}
    .section-title{font-weight:600;margin:8px 0}
  </style>

  <div class="ai-wrap">
    <div class="ai-head">
      <h3 style="margin:0">💬 AI 1차 상담</h3>
      <small>사람 상담을 원하시면 채팅창에 <b>“상담사 연결”</b>이라고 입력하세요.</small>
    </div>

    <div class="ai-card">
      <!-- 카테고리 칩 -->
      <div style="margin-bottom:8px">
        <button type="button" class="chip" data-topic="LOVE">연애 고민</button>
        <button type="button" class="chip" data-topic="MATCHING">매칭 문의</button>
        <button type="button" class="chip" data-topic="COACHING">프로필/스타일 코칭</button>
        <button type="button" class="chip" data-topic="SCHEDULE">일정 도와줘</button>
        <button type="button" class="chip" data-topic="PROJECT_HELP">프로젝트 도움</button>
        <button type="button" id="forceHandoffBtn" class="pill-btn" style="float:right">상담사 연결 ▶</button>
      </div>

      <!-- 대화 -->
      <div id="aiMsgs" class="msgs"></div>

      <!-- 입력 -->
      <div class="ai-input">
        <textarea id="aiInput" placeholder="무엇이든 편하게 말씀해 주세요. (Enter=전송, Shift+Enter 줄바꿈)"></textarea>
        <button id="aiSendBtn">전송</button>
      </div>
    </div>
  </div>

  <hr class="my-4"/>

  <!-- ===== 사람 상담 패널(초기 숨김) : 기존 inquiry UI 이식 (간략/핵심만) ===== -->
  <style>
    .human-wrap{max-width:900px;margin:0 auto;display:none}
    .status-box{background:#fff;border:1px solid #e2e8f0;border-radius:8px;padding:20px;text-align:center;margin-bottom:10px}
    .human-card{background:#fff;border:1px solid #e2e8f0;border-radius:10px;padding:16px}
    .hm-messages{height:300px;overflow-y:auto;background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;padding:10px}
    .hm-item{margin-bottom:10px}
    .hm-sender{display:block;font-weight:600;font-size:12px}
  </style>

  <div id="humanWrap" class="human-wrap">
    <div class="section-title">🧑‍💼 사람 상담</div>
    <div id="humanStatus" class="status-box">대기 상태입니다. “상담사 연결”을 요청하면 연결합니다.</div>

    <div class="human-card">
      <div style="display:flex;justify-content:space-between;align-items:center">
        <h5 style="margin:0">실시간 상담</h5>
        <button id="videoCallBtnTop" class="pill-btn" disabled>🎥 영상 통화</button>
      </div>
      <div class="text-muted" style="margin:6px 0">연결 상태: <span id="hmConn" class="text-danger">연결 대기</span></div>

      <div id="hmMsgs" class="hm-messages"></div>

      <div style="display:flex;gap:8px;margin-top:8px">
        <input id="hmInput" class="form-control" placeholder="상담사에게 메시지를 입력하세요" disabled/>
        <button id="hmSendBtn" class="btn btn-primary" disabled>전송</button>
      </div>

      <button id="videoCallBtnMain" class="btn btn-success mt-2" disabled>🎥 영상 통화 시작</button>
    </div>

    <!-- 영상통화 모달은 기존 것 그대로 사용 가능 (여기서는 생략 가능) -->
  </div>
</div>

<!-- ===== Orchestrator JS ===== -->
<script>
  (function(){
    const root = document.getElementById('aiOrchestratorRoot');
    const state = {
      mode: 'AI',
      topicHint: '',
      custId: root.dataset.custId || ('guest_' + Math.floor(Math.random()*10000)),
      websocketUrl: root.dataset.websocketUrl || '/',
      inquiryUrl: root.dataset.inquiryUrl || '/websocket/inquiry',
      // 사람 상담 상태
      stomp: null,
      connected: false,
      roomId: null
    };

    /* ---------- 공통 유틸 ---------- */
    const esc = (s)=>String(s)
            .replace(/&/g,'&amp;').replace(/</g,'&lt;')
            .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');

    const normalizeNewlines = (s)=>{
      if (!s) return '';
      // 서버가 "\\n" 형태로 줄 수도 있어 보호
      const fixed = s.replace(/\\n/g, '\n');
      return esc(fixed).replace(/\n\n+/g,'<br><br>').replace(/\n/g,'<br>');
    };

    const scrollToBottom = (el)=>{ el.scrollTop = el.scrollHeight; };

    /* ---------- 1) AI 패널 ---------- */
    const ai = {
      box: document.getElementById('aiMsgs'),
      input: document.getElementById('aiInput'),
      sendBtn: document.getElementById('aiSendBtn'),
      chips: document.querySelectorAll('.chip'),
      forceBtn: document.getElementById('forceHandoffBtn'),

      init(){
        this.chips.forEach(ch=>{
          ch.addEventListener('click', ()=>{
            this.chips.forEach(c=>c.classList.remove('active'));
            ch.classList.add('active');
            state.topicHint = ch.dataset.topic || '';
          });
        });
        this.sendBtn.addEventListener('click', ()=>this.send());
        this.input.addEventListener('keypress',(e)=>{
          if(e.key==='Enter' && !e.shiftKey){ e.preventDefault(); this.send(); }
        });
        this.forceBtn.addEventListener('click', ()=>handoff.start());

        this.addAi(
                "안녕하세요! 결.정.사 AI 상담사입니다 😊\n" +
                "연애 코칭, 매칭 문의, 스타일/프로필 코칭, 프로젝트 이슈까지 도와드릴게요.\n" +
                "사람 상담을 원하시면 채팅창에 **“상담사 연결”**이라고 입력해 주세요.",
                'GENERAL'
        );
      },

      addUser(text){
        const div = document.createElement('div');
        div.className = 'msg user';
        div.innerHTML = `<div class="bubble">${esc(text)}</div>`;
        this.box.appendChild(div); scrollToBottom(this.box);
      },

      addAi(text, topic){
        const div = document.createElement('div');
        div.className = 'msg ai';
        const badge = topic ? `<span class="badge" data-topic="${topic}">${topic}</span>` : '';
        div.innerHTML = `${badge}<div class="bubble">${normalizeNewlines(text)}</div>`;
        this.box.appendChild(div); scrollToBottom(this.box);
      },

      addEscalation(){
        const wrap = document.createElement('div');
        wrap.className = 'handoff';
        wrap.innerHTML = `사람 상담이 더 적합해 보여요. 아래 버튼을 눌러 연결해 주세요.<br>
        <button type="button" id="handoffBtnInner" class="pill-btn" style="margin-top:6px">상담사 연결 ▶</button>`;
        this.box.appendChild(wrap); scrollToBottom(this.box);
        document.getElementById('handoffBtnInner').addEventListener('click', ()=>handoff.start());
      },

      isHandoffKeyword(text){
        const t = (text||'').trim();
        // 다양한 표현 허용
        return /상담\s*사?\s*연결/.test(t);
      },

      async send(){
        const text = (this.input.value||'').trim();
        if(!text) return;

        // 키워드 즉시 이관
        if (this.isHandoffKeyword(text)) {
          this.addUser(text);
          this.addAi("사람 상담을 연결할게요. 잠시만요…", 'GENERAL');
          return handoff.start();
        }

        this.addUser(text);
        this.input.value='';

        // 로딩 표시
        this.addAi("생각 중이에요… ⏳", 'GENERAL');

        try{
          const res = await fetch('<c:url value="/aichat-api/message"/>', {
            method:'POST',
            headers:{'Content-Type':'application/json'},
            body: JSON.stringify({ message:text, topicHint: state.topicHint })
          });
          const data = await res.json();

          // 로딩 말풍선 지우고 새 답
          if (this.box.lastElementChild?.classList.contains('msg')) {
            this.box.removeChild(this.box.lastElementChild);
          }

          this.addAi(data.message || '응답이 없어요.', data.topic || 'GENERAL');

          // followups → 간단히 추가 질문 형태로
          if (Array.isArray(data.followups)) {
            data.followups.forEach(q=> this.addAi('❓ ' + q, data.topic || 'GENERAL'));
          }

          // 서버가 이관 지시하면 바로 전환
          if (data.status === 'ESCALATE' || data.action === 'CALL_AGENT') {
            this.addEscalation();
          }
        }catch(e){
          if (this.box.lastElementChild?.classList.contains('msg')) {
            this.box.removeChild(this.box.lastElementChild);
          }
          this.addAi('죄송해요. 잠시 후 다시 시도해 주세요. ('+ e.message +')', 'GENERAL');
        }
      }
    };

    /* ---------- 2) 사람 상담 패널 ---------- */
    const human = {
      wrap: document.getElementById('humanWrap'),
      status: document.getElementById('humanStatus'),
      conn: document.getElementById('hmConn'),
      box: document.getElementById('hmMsgs'),
      input: document.getElementById('hmInput'),
      sendBtn: document.getElementById('hmSendBtn'),
      btnTop: document.getElementById('videoCallBtnTop'),
      btnMain: document.getElementById('videoCallBtnMain'),

      show(){ this.wrap.style.display='block'; },
      setConnected(ok){
        state.connected = !!ok;
        this.conn.textContent = ok ? '연결됨' : '연결 대기';
        this.conn.classList.toggle('text-success', !!ok);
        this.conn.classList.toggle('text-danger', !ok);
        this.input.disabled = !ok; this.sendBtn.disabled = !ok;
        this.btnTop.disabled = !ok; this.btnMain.disabled = !ok;
      },

      add(sender, text){
        const div = document.createElement('div');
        div.className = 'hm-item';
        const who = sender==='user' ? '나' : '상담사';
        div.innerHTML = `<span class="hm-sender">[${who}]</span><span>${esc(text)}</span>`;
        this.box.appendChild(div); scrollToBottom(this.box);
      },

      bind(){
        this.sendBtn.addEventListener('click', ()=>this.send());
        this.input.addEventListener('keypress',(e)=>{
          if(e.key==='Enter'){ e.preventDefault(); this.send(); }
        });
      },

      async send(){
        if(!state.stomp || !state.connected){ alert('아직 연결되지 않았습니다.'); return; }
        const text = (this.input.value||'').trim(); if(!text) return;
        const payload = { sendid: state.custId, receiveid:'admin', content1:text, roomId: state.roomId };
        state.stomp.send('/receiveto', {}, JSON.stringify(payload));
        this.add('user', text); this.input.value='';
      }
    };

    /* ---------- 3) 이관(초기화 → 방확인/생성 → STOMP 연결) ---------- */
    const handoff = {
      async start(){
        // UI 전환
        human.show();
        human.status.textContent = '사람 상담사를 연결 중입니다…';
        ai.addAi('사람 상담 연결을 시작했어요. 잠시만 기다려 주세요.', 'GENERAL');

        // 1) 내 활성 방 조회
        const active = await fetch(`/api/chatroom/active/${encodeURIComponent(state.custId)}`).then(r=>r.json()).catch(()=>null);
        if (active && active.roomId) {
          state.roomId = active.roomId;
        } else {
          // 2) 없으면 생성
          await fetch('/api/chatroom/create', {
            method:'POST',
            headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body: 'custId='+encodeURIComponent(state.custId)
          }).catch(()=>{});
          const again = await fetch(`/api/chatroom/active/${encodeURIComponent(state.custId)}`).then(r=>r.json()).catch(()=>null);
          state.roomId = again && again.roomId ? again.roomId : null;
        }

        if (!state.roomId) {
          human.status.textContent = '연결에 실패했습니다. 잠시 후 다시 시도하거나 고객센터로 연락해 주세요.';
          return;
        }

        // 3) STOMP 연결
        await this.connectStomp();
      },

      async connectStomp(){
        try{
          const socket = new SockJS(state.websocketUrl + 'chat');
          const client = Stomp.over(socket);
          state.stomp = client;

          client.connect({}, frame=>{
            human.setConnected(true);
            human.status.textContent = `상담사 연결됨. 채팅방 #${state.roomId}`;
            // 관리자 → 사용자 메시지 구독
            client.subscribe('/adminsend/to/' + state.custId, (message)=>{
              try{
                const payload = JSON.parse(message.body);
                if (payload.content1 === '__CHAT_CLOSED__') {
                  human.add('admin','상담이 종료되었습니다. 이용해 주셔서 감사합니다.');
                  human.setConnected(false);
                  return;
                }
                human.add('admin', payload.content1 || '');
              }catch(e){ /* no-op */ }
            });
          }, err=>{
            human.status.textContent = '연결에 실패했습니다. 새로고침 후 다시 시도해 주세요.';
            human.setConnected(false);
          });

          socket.onclose = ()=>{ human.setConnected(false); };
        }catch(e){
          human.status.textContent = '연결 중 오류가 발생했습니다.';
          human.setConnected(false);
        }
      }
    };

    /* ---------- 부트 ---------- */
    ai.init();
    human.bind();
  })();
</script>
