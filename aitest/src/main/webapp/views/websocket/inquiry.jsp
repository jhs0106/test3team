<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="false" %>

<style>
    .container-800{max-width:800px;margin:0 auto;padding:20px;}
    .section-header{background:#2563eb;color:#fff;padding:30px;border-radius:8px;text-align:center;margin-bottom:30px;}
    .section-header h2{margin:0 0 10px;font-size:28px;font-weight:600;}
    .section-header p{margin:0;opacity:.9}

    /* AI 1차 상담 */
    #aiSection .chip-group{display:flex;gap:8px;flex-wrap:wrap;margin-top:12px}
    #aiSection .chip{border:1px solid #e2e8f0;background:#fff;border-radius:20px;padding:6px 12px;cursor:pointer;font-size:13px}
    #aiSection .chip.active{background:#2563eb;color:#fff;border-color:#2563eb}
    #aiSection .chat-panel{background:#fff;border:1px solid #e2e8f0;border-radius:8px;padding:16px}
    #aiSection .chat-messages{height:420px;overflow-y:auto;background:#f8fafc;border:1px solid #e2e8f0;border-radius:6px;padding:10px}
    .msg{margin:10px 0}
    .msg .bubble{display:inline-block;max-width:85%;padding:10px 12px;border-radius:12px;word-break:break-word}
    .msg.user .bubble{background:#2563eb;color:#fff;float:right;clear:both}
    .msg.ai .bubble{background:#fff;border:1px solid #e2e8f0;float:left;clear:both}
    .badge{display:inline-block;font-size:11px;padding:2px 8px;border-radius:999px;border:1px solid #e2e8f0;margin-right:6px;color:#64748b}
    .badge[data-topic="PROJECT_HELP"]{color:#0ea5e9;border-color:#0ea5e9}
    .badge[data-topic="LOVE"],.badge[data-topic="MATCHING"],.badge[data-topic="COACHING"]{color:#2563eb;border-color:#2563eb}
    #aiSection .chat-input{display:flex;gap:8px;margin-top:12px}
    #aiSection .chat-input textarea{flex:1;height:60px;padding:10px;border:1px solid #e2e8f0;border-radius:6px;resize:vertical}
    #aiSection .chat-input button{background:#2563eb;color:#fff;border:none;border-radius:6px;padding:0 16px}
    #aiSection .call-agent-btn{margin-top:12px;background:#facc15;border:none;color:#7c6f1b;padding:10px 16px;border-radius:6px;font-size:14px;cursor:pointer}
    #aiSection .call-agent-btn:disabled{opacity:.6;cursor:not-allowed}

    /* 사람 상담 */
    #humanSection{display:none}
    .inquiry-info{background:#f8fafc;border-left:3px solid #2563eb;padding:20px;border-radius:4px;margin-bottom:30px}
    .inquiry-info h5{color:#1e293b;margin-bottom:15px;font-weight:600}
    .inquiry-info li{margin-bottom:8px;color:#64748b}
    .chat-status{background:#fff;border:1px solid #e2e8f0;border-radius:8px;padding:25px;margin-bottom:20px;text-align:center}
    .chat-status .status-icon{font-size:48px;margin-bottom:15px}
    .chat-status .status-message{font-size:18px;color:#1e293b;margin-bottom:10px;font-weight:600}
    .chat-status .status-detail{font-size:14px;color:#64748b}
    .chat-status .room-info{margin-top:10px;font-size:13px;color:#94a3b8}
    .btn-video-call{background:#10b981;border:none;color:#fff;padding:10px 20px;border-radius:6px;font-weight:500;margin-top:10px;width:100%;cursor:pointer;transition:background .2s}
    .btn-video-call:hover{background:#059669}
    .human-chat-panel{background:#fff;border-radius:8px;padding:20px;border:1px solid #e2e8f0}
    .human-chat-panel h4{margin:0 0 15px;color:#1e293b;font-weight:600}
    .chat-status-indicator{margin-bottom:15px;font-size:14px;color:#64748b}
    #humanMessages{height:300px;overflow-y:auto;border:1px solid #e2e8f0;padding:15px;border-radius:6px;margin-bottom:15px;background:#f8fafc}
    .chat-message{margin-bottom:12px;line-height:1.5}
    .chat-message .sender{display:block;font-weight:600;font-size:13px}
    .chat-message.user .sender{color:#2563eb}
    .chat-message.admin .sender{color:#0ea5e9}
    .human-input-group{display:flex;gap:10px}
    .human-input-group input{flex:1;border-radius:6px;border:1px solid #e2e8f0;padding:10px 12px;font-size:14px}
    .human-input-group input:focus{outline:none;border-color:#2563eb}
    .human-input-group button{background:#2563eb;border:none;color:#fff;padding:0 24px;border-radius:6px;font-weight:500;transition:background .2s}
    .human-input-group button:disabled{background:#94a3b8}

    /* 비디오 */
    .video-modal{display:none;position:fixed;z-index:9999;left:0;top:0;width:100%;height:100%;background:rgba(0,0,0,.85)}
    .video-modal-content{position:relative;background:#1e293b;margin:2% auto;width:90%;max-width:1200px;height:90%;border-radius:12px;display:flex;flex-direction:column}
    .video-modal-header{background:#334155;color:#fff;padding:20px;border-radius:12px 12px 0 0;display:flex;justify-content:space-between;align-items:center}
    .video-modal-header h3{margin:0;font-size:18px;font-weight:600}
    .video-modal-close{color:#fff;font-size:28px;cursor:pointer;background:none;border:none;width:36px;height:36px;display:flex;align-items:center;justify-content:center;border-radius:6px;transition:background-color .2s}
    .video-modal-close:hover{background:rgba(255,255,255,.1)}
    .video-modal-body{flex:1;padding:20px;display:flex;flex-direction:column;gap:20px}
    .video-container{display:grid;grid-template-columns:1fr 1fr;gap:20px;flex:1}
    .video-wrapper{position:relative;background:#0f172a;border-radius:8px;overflow:hidden;display:flex;align-items:center;justify-content:center}
    .video-stream{width:100%;height:100%;object-fit:cover}
    .video-label{position:absolute;top:12px;left:12px;background:rgba(0,0,0,.6);color:#fff;padding:6px 12px;border-radius:4px;font-size:13px;font-weight:500}
    .video-controls{display:flex;justify-content:center;gap:15px;padding:15px;background:#334155;border-radius:8px}
    .video-control-btn{padding:12px 24px;border:none;border-radius:6px;font-size:15px;font-weight:500;cursor:pointer;transition:all .2s;display:flex;align-items:center;gap:8px;background:#dc2626;color:#fff}
    .video-control-btn:hover{background:#b91c1c}
    .connection-status{text-align:center;padding:10px;background:#334155;border-radius:6px;color:#e2e8f0;font-size:14px}
    .connection-status.connected{background:#10b981;color:#fff}
    .connection-status.disconnected{background:#64748b;color:#fff}
    .connection-status.connecting{background:#f59e0b;color:#fff}

    /* 사람 상담을 AI 섹션과 같은 카드/말풍선 스타일로 통일 */
    #humanSection .chat-status {
        background:#fff;
        border:1px solid #e2e8f0;
        border-radius:8px;
        padding:16px;
        margin-bottom:16px;
        text-align:center;
    }
    #humanSection .status-icon{font-size:48px;margin-bottom:10px}
    #humanSection .status-message{font-size:18px;color:#1e293b;margin-bottom:8px;font-weight:600}
    #humanSection .status-detail{font-size:14px;color:#64748b}
    #humanSection .room-info{margin-top:8px;font-size:13px;color:#94a3b8}

    /* AI와 동일한 카드 컨테이너 재사용 */
    #humanSection .chat-panel{background:#fff;border:1px solid #e2e8f0;border-radius:8px;padding:16px}

    /* 메시지 박스 높이/스크롤 동일화 */
    #humanSection .chat-messages{height:420px;overflow-y:auto;background:#f8fafc;border:1px solid #e2e8f0;border-radius:6px;padding:10px}

    /* 말풍선 스타일을 AI 섹션과 동일하게 매핑 */
    .chat-message{margin:10px 0;line-height:1.5}
    .chat-message .text{
        display:inline-block;max-width:85%;
        padding:10px 12px;border-radius:12px;word-break:break-word;
        background:#fff;border:1px solid #e2e8f0;float:left;clear:both
    }
    .chat-message.user .text{
        background:#2563eb;color:#fff;border:none;float:right;clear:both
    }
    .chat-message .sender{display:none} /* 말풍선 위 보낸이 라벨 숨김(필요시 살려도 됨) */

    /* 입력창도 AI 섹션 레이아웃과 통일 */
    #humanSection .human-input-group{display:flex;gap:8px;margin-top:12px}
    #humanSection .human-input-group input{
        flex:1;height:40px;padding:10px;border:1px solid #e2e8f0;border-radius:6px;font-size:14px
    }
    #humanSection .human-input-group input:focus{outline:none;border-color:#2563eb}
    #humanSection .human-input-group button{
        background:#2563eb;border:none;color:#fff;padding:0 16px;border-radius:6px;font-weight:500
    }
    #humanSection .human-input-group button:disabled{background:#94a3b8}

    /* 영상 통화 버튼을 AI의 call-agent 버튼 톤과 유사하게 */
    #humanSection .btn-video-call{
        margin-top:12px;background:#facc15;border:none;color:#7c6f1b;
        padding:10px 16px;border-radius:6px;font-size:14px;cursor:pointer;transition:background .2s;width:100%
    }
    #humanSection .btn-video-call:hover{background:#eab308}
    #humanSection .btn-video-call:disabled{opacity:.6;cursor:not-allowed}

</style>

<script>
    /* ---------- 유틸 ---------- */
    function htmlEscape(s){
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;')
            .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }
    async function safeJson(res){
        const t = await res.text();
        if(!res.ok) throw new Error(t || (res.status + ' ' + res.statusText));
        return t ? JSON.parse(t) : null;
    }

    /* ---------- AI 1차 상담 ---------- */
    const aiConcierge = {
        topicHint:'', isEscalating:false, loadingNode:null,
        init(){
            this.bind();
            this.disableInput(false);
            this.addAi(
                '안녕하세요! 사람다움 케어 AI 상담사입니다 😊\n' +
                '연애 코칭, 매칭 문의, 프로필/스타일 코칭, 기능 설명까지 도와드릴게요.\n' +
                '사람 상담을 원하시면 채팅창에 **"상담사 연결"**이라고 입력하거나 아래 버튼을 눌러주세요.',
                'GENERAL'
            );
        },
        bind(){
            document.querySelectorAll('#aiSection .chip').forEach(ch=>{
                ch.addEventListener('click', ()=>{
                    document.querySelectorAll('#aiSection .chip').forEach(c=>c.classList.remove('active'));
                    ch.classList.add('active');
                    this.topicHint = ch.dataset.topic || '';
                });
            });
            const sendBtn = document.getElementById('aiSendBtn');
            const msg     = document.getElementById('aiMsg');
            const callBtn = document.getElementById('callAgentBtn');
            if(sendBtn) sendBtn.addEventListener('click', ()=>this.send());
            if(msg){
                msg.addEventListener('keypress', e=>{
                    if(e.key==='Enter' && !e.shiftKey){ e.preventDefault(); this.send(); }
                });
            }
            if(callBtn) callBtn.addEventListener('click', ()=>this.addEscalation());
        },
        wantHuman(text){
            return /(상담\s*사?\s*연결|상담\s*연락|상담원\s*연결|사람\s*상담|human|operator)/i.test(text);
        },
        disableInput(d){
            const msg=document.getElementById('aiMsg'), btn=document.getElementById('aiSendBtn'), call=document.getElementById('callAgentBtn');
            if(msg) msg.disabled=!!d; if(btn) btn.disabled=!!d; if(call) call.disabled=!!d;
        },
        showThinking(){
            const box=document.getElementById('aiMsgs');
            const div=document.createElement('div');
            div.className='msg ai'; div.dataset.loading='true';
            div.innerHTML='<div class="bubble">생각 중이에요… ⏳</div>';
            box.appendChild(div); box.scrollTop=box.scrollHeight; this.loadingNode=div;
        },
        clearThinking(){ if(this.loadingNode?.parentNode){ this.loadingNode.parentNode.removeChild(this.loadingNode); } this.loadingNode=null; },
        addUser(text){
            const box=document.getElementById('aiMsgs');
            const div=document.createElement('div'); div.className='msg user';
            div.innerHTML='<div class="bubble">'+ htmlEscape(text) +'</div>';
            box.appendChild(div); box.scrollTop=box.scrollHeight;
        },
        addAi(text,topic){
            const box=document.getElementById('aiMsgs');
            const div=document.createElement('div'); div.className='msg ai';
            const badge= topic ? '<span class="badge" data-topic="'+htmlEscape(topic)+'">'+htmlEscape(topic)+'</span>' : '';
            div.innerHTML = badge + '<div class="bubble">'+ this.toHtml(text) +'</div>';
            box.appendChild(div); box.scrollTop=box.scrollHeight;
        },
        addEscalation(){
            if(this.isEscalating) return;
            this.isEscalating=true; this.disableInput(true);
            this.addAi('상담사와 연결해드릴게요. 잠시만요…','SYSTEM');
            setTimeout(()=>inquiryPage.startHumanSupport(), 400);
        },
        async send(){
            if(this.isEscalating) return;
            const input=document.getElementById('aiMsg');
            const text=(input?.value||'').trim(); if(!text) return;
            this.addUser(text); input.value='';
            if(this.wantHuman(text)){ this.addEscalation(); return; }
            this.showThinking();
            try{
                const res = await fetch(document.getElementById('root').dataset.aiEndpoint, {
                    method:'POST', headers:{'Content-Type':'application/json'},
                    body: JSON.stringify({ message:text, topicHint:this.topicHint })
                });
                const data = await safeJson(res);
                this.clearThinking();
                this.addAi((data && data.message) ? data.message : '응답을 만들지 못했어요.', (data && data.topic) ? data.topic : 'GENERAL');
                if(data && Array.isArray(data.followups)){ data.followups.forEach(q=>this.addAi('❓ '+q, data.topic||'GENERAL')); }
                if(data && (data.status==='ESCALATE' || (String(data.action||'').toUpperCase()==='CALL_AGENT'))){ this.addEscalation(); }
            }catch(e){
                this.clearThinking(); this.addAi('죄송해요. 잠시 후 다시 시도해 주세요. ('+ htmlEscape(e.message) +')','GENERAL');
            }
        },
        toHtml(text){
            if(!text) return '';
            let s=String(text).replace(/\\r\\n/g,'\n').replace(/\\n/g,'\n').replace(/\\t/g,'    ');
            s=htmlEscape(s); s=s.replace(/\*\*(.+?)\*\*/g,'<strong>$1</strong>');
            s=s.replace(/\n\n+/g,'<br><br>').replace(/\n/g,'<br>'); return s;
        }
    };

    /* ---------- 사람 상담 / WS & WebRTC ---------- */
    let inquiryPage = {
        custId:null, activeRoomId:null, stompClient:null, isConnected:false,
        rtcConnection:null, rtcSocket:null, localStream:null, isHumanMode:false,
        init(){
            const root=document.getElementById('root');
            this.custId = root.dataset.custId || ('guest_' + Math.floor(Math.random()*10000));
            document.getElementById('aiSection').style.display='block';
            document.getElementById('humanSection').style.display='none';
        },
        startHumanSupport(){
            if(this.isHumanMode) return; this.isHumanMode=true;
            document.getElementById('aiSection').style.display='none';
            document.getElementById('humanSection').style.display='block';
            document.getElementById('humanSection').scrollIntoView({behavior:'smooth',block:'start'});
            document.getElementById('humanStatusBox').innerHTML =
                '<div class="chat-status"><div class="status-icon">🔁</div><div class="status-message">상담사 연결 준비 중</div><div class="status-detail">잠시만 기다려주세요...</div></div>';
            this.updateConnectionStatus(false);
            this.connectWebSocket();
            this.checkOrCreateRoom();
        },
        async checkOrCreateRoom(){
            try{
                const base=document.getElementById('root').dataset.apiBase; // '/api/chatroom'
                let res = await fetch(base + '/active/' + encodeURIComponent(this.custId));
                let data = await safeJson(res);
                if(data && data.roomId){
                    this.activeRoomId=data.roomId; this.renderRoomStatus(data); this.updateConnectionStatus(this.isConnected);
                }else{
                    const fd=new URLSearchParams(); fd.append('custId', this.custId);
                    await safeJson(await fetch(base + '/create', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:fd}));
                    res = await fetch(base + '/active/' + encodeURIComponent(this.custId));
                    data = await safeJson(res);
                    if(data && data.roomId){ this.activeRoomId=data.roomId; this.renderRoomStatus(data); }
                    else{
                        document.getElementById('humanStatusBox').innerHTML =
                            '<div class="chat-status"><div class="status-icon">⚠️</div><div class="status-message">채팅방 생성 실패</div><div class="status-detail">다시 시도해 주세요.</div></div>';
                    }
                }
            }catch(e){
                document.getElementById('humanStatusBox').innerHTML =
                    '<div class="chat-status"><div class="status-icon">⚠️</div><div class="status-message">오류</div><div class="status-detail">'+ htmlEscape(e.message) +'</div></div>';
            }
        },
        renderRoomStatus(room){
            const icon = room.status==='waiting' ? '⏳' : '✅';
            const text = room.status==='waiting' ? '상담사 연결 대기 중' : '상담 진행 중';
            const detail = room.status==='waiting' ? '상담사가 곧 연결됩니다. 잠시만 기다려주세요.' : '상담사와 연결되었습니다.';
            document.getElementById('humanStatusBox').innerHTML =
                '<div class="chat-status"><div class="status-icon">'+icon+'</div><div class="status-message">'+text+
                '</div><div class="status-detail">'+detail+'</div><div class="room-info">채팅방 번호: '+ room.roomId +' | 고객 ID: '+ htmlEscape(this.custId) +'</div></div>';
        },
        connectWebSocket(){
            if(this.stompClient || !this.custId) return;
            try{
                // 서버 endpoint: /chat → 현재 호스트 기준
                const sockUrl = location.origin + '/chat';
                const socket  = new SockJS(sockUrl);
                this.stompClient = Stomp.over(socket);
                this.stompClient.connect({}, (frame)=>{
                    this.updateConnectionStatus(true);
                    this.stompClient.subscribe('/adminsend/to/' + this.custId, (message)=>{
                        const payload = JSON.parse(message.body);
                        if(payload.content1==='__CHAT_CLOSED__'){ this.handleChatClosed(); }
                        else if(payload.content1==='__VIDEO_CALL_START__'){ this.receiveVideoCallStart(); }
                        else { this.appendHumanMessage('admin', payload.content1); }
                    });
                }, (err)=>{ this.stompClient=null; this.updateConnectionStatus(false); });
                socket.onclose=()=>{ this.stompClient=null; this.updateConnectionStatus(false); };
            }catch(e){ this.updateConnectionStatus(false); }
        },
        updateConnectionStatus(ok){
            this.isConnected = ok; const canChat = ok && this.activeRoomId;
            const el=document.getElementById('humanConnText'); if(!el) return;
            if(ok){
                el.classList.remove('text-danger'); el.classList.add('text-success'); el.textContent='실시간 상담 연결됨';
                document.getElementById('humanSendBtn').disabled=!canChat;
                document.getElementById('humanInput').disabled=!canChat;
                document.getElementById('humanVideoBtn').disabled=!canChat;
            }else{
                el.classList.remove('text-success'); el.classList.add('text-danger'); el.textContent='연결 대기 중...';
                document.getElementById('humanSendBtn').disabled=true;
                document.getElementById('humanInput').disabled=true;
                document.getElementById('humanVideoBtn').disabled=true;
            }
        },
        handleChatClosed(){
            this.appendHumanMessage('admin','⚠️ 상담사가 채팅을 종료했습니다. 감사합니다!');
            const el=document.getElementById('humanConnText'); el.classList.remove('text-success'); el.classList.add('text-warning'); el.textContent='상담 종료됨';
            document.getElementById('humanSendBtn').disabled=true; document.getElementById('humanInput').disabled=true; document.getElementById('humanVideoBtn').disabled=true;
            if(this.stompClient){ this.stompClient.disconnect(); this.stompClient=null; }
            this.isConnected=false; this.activeRoomId=null;
            document.getElementById('humanStatusBox').innerHTML =
                '<div class="chat-status"><div class="status-icon">✅</div><div class="status-message">상담 종료</div><div class="status-detail">새로운 문의를 시작하려면 페이지를 새로고침하세요.</div></div>';
        },
        appendHumanMessage(sender,message){
            const time=new Date().toLocaleTimeString(); const who= sender==='user'?'나':'상담사'; const cls= sender==='user'?'user':'admin';
            document.getElementById('humanMessages').insertAdjacentHTML('beforeend',
                '<div class="chat-message '+cls+'"><span class="sender">['+time+'] '+who+'</span><span class="text">'+ htmlEscape(message) +'</span></div>');
            const box=document.getElementById('humanMessages'); box.scrollTop=box.scrollHeight;
        },
        sendHumanMessage(){
            if(!this.isConnected || !this.stompClient){ alert('상담 연결이 아직 완료되지 않았습니다.'); return; }
            const input=document.getElementById('humanInput'); const text=(input.value||'').trim(); if(!text) return;
            const payload={ sendid:this.custId, receiveid:'admin', content1:text, roomId:this.activeRoomId };
            this.stompClient.send('/receiveto', {}, JSON.stringify(payload));
            this.appendHumanMessage('user', text); input.value='';
        },

        /* ---- WebRTC ---- */
        startVideo(){
            if(!this.activeRoomId){ alert('먼저 채팅방을 생성해주세요.'); return; }
            if(this.stompClient && this.isConnected){
                this.stompClient.send('/receiveto', {}, JSON.stringify({sendid:this.custId,receiveid:'admin',content1:'__VIDEO_CALL_START__',roomId:this.activeRoomId}));
            }
            document.getElementById('videoModal').style.display='block'; this.initWebRTC();
        },
        receiveVideoCallStart(){ document.getElementById('videoModal').style.display='block'; this.initWebRTC(); },
        initWebRTC(){
            const status=document.getElementById('videoConnStatus'); status.classList.remove('disconnected'); status.classList.add('connecting'); status.textContent='연결 중...';
            navigator.mediaDevices.getUserMedia({video:true,audio:true}).then(stream=>{
                this.localStream=stream; document.getElementById('localVideo').srcObject=stream; this.setupPeer();
            }).catch(err=>{ alert('카메라/마이크 권한이 필요합니다.'); status.classList.remove('connecting'); status.classList.add('disconnected'); status.textContent='연결 실패'; });
        },
        setupPeer(){
            const wsProto = (location.protocol==='https:'?'wss:':'ws:');
            const signalUrl = wsProto+'//'+location.host+'/signal';
            this.rtcSocket = new WebSocket(signalUrl);
            this.rtcSocket.onopen = ()=>{ this.rtcSocket.send(JSON.stringify({type:'join',roomId:String(this.activeRoomId),custId:this.custId})); };
            this.rtcSocket.onmessage = (ev)=> this.handleSignal(JSON.parse(ev.data));
            this.rtcSocket.onerror  = ()=> this.setVideoStatus('연결 실패','disconnected');

            const config={iceServers:[{urls:'stun:stun.l.google.com:19302'}]};
            this.rtcConnection = new RTCPeerConnection(config);
            this.localStream.getTracks().forEach(t=>this.rtcConnection.addTrack(t,this.localStream));
            this.rtcConnection.onconnectionstatechange = ()=>{
                switch(this.rtcConnection.connectionState){
                    case 'connected': this.setVideoStatus('통화 연결됨','connected'); break;
                    case 'disconnected': case 'failed': case 'closed': this.setVideoStatus('연결 종료/실패','disconnected'); break;
                }
            };
            this.rtcConnection.ontrack = (e)=>{ const v=document.getElementById('remoteVideo'); v.srcObject=e.streams[0]; v.play().catch(()=>{}); };
            this.rtcConnection.onicecandidate = (e)=>{ if(e.candidate && this.rtcSocket?.readyState===WebSocket.OPEN){ this.rtcSocket.send(JSON.stringify({type:'ice-candidate',roomId:String(this.activeRoomId),data:e.candidate})); } };
        },
        handleSignal(msg){
            switch(msg.type){
                case 'offer':
                    this.rtcConnection.setRemoteDescription(new RTCSessionDescription(msg.offer||msg.data))
                        .then(()=>this.rtcConnection.createAnswer()).then(ans=>this.rtcConnection.setLocalDescription(ans))
                        .then(()=>this.rtcSocket.send(JSON.stringify({type:'answer',roomId:String(this.activeRoomId),data:this.rtcConnection.localDescription})));
                    break;
                case 'answer':
                    this.rtcConnection.setRemoteDescription(new RTCSessionDescription(msg.answer||msg.data)); break;
                case 'ice-candidate':
                    this.rtcConnection.addIceCandidate(new RTCIceCandidate(msg.candidate||msg.data)); break;
                case 'user-joined':
                    this.rtcConnection.createOffer().then(off=>this.rtcConnection.setLocalDescription(off))
                        .then(()=>this.rtcSocket.send(JSON.stringify({type:'offer',roomId:String(this.activeRoomId),data:this.rtcConnection.localDescription})));
                    break;
            }
        },
        setVideoStatus(text,cls){
            const el=document.getElementById('videoConnStatus'); el.classList.remove('connected','connecting','disconnected'); el.classList.add(cls); el.textContent=text;
        },
        closeVideoModal(){ if(!confirm('통화를 종료하시겠습니까?')) return; this.endVideo(); document.getElementById('videoModal').style.display='none'; },
        endVideo(){
            if(this.localStream){ this.localStream.getTracks().forEach(t=>t.stop()); this.localStream=null; }
            if(this.rtcConnection){ this.rtcConnection.close(); this.rtcConnection=null; }
            if(this.rtcSocket){ this.rtcSocket.close(); this.rtcSocket=null; }
            document.getElementById('localVideo').srcObject=null; document.getElementById('remoteVideo').srcObject=null;
            this.setVideoStatus('연결 대기 중','disconnected');
        }
    };

    document.addEventListener('DOMContentLoaded', ()=>{
        aiConcierge.init();
        inquiryPage.init();
        document.getElementById('humanSendBtn').addEventListener('click', ()=>inquiryPage.sendHumanMessage());
        document.getElementById('humanInput').addEventListener('keypress', e=>{ if(e.key==='Enter'){ e.preventDefault(); inquiryPage.sendHumanMessage(); }});
        document.getElementById('humanVideoBtn').addEventListener('click', ()=>inquiryPage.startVideo());
        document.getElementById('videoCloseBtn').addEventListener('click', ()=>inquiryPage.closeVideoModal());
        document.getElementById('videoEndBtn').addEventListener('click', ()=>inquiryPage.endVideo());
    });
</script>

<!-- ===== 루트 컨테이너: 서버 값은 data-* 로만 주입 == -->
<div class="col-sm-10">
    <div id="root"
         data-cust-id="${sessionScope.loginMember != null ? sessionScope.loginMember.loginId : ''}"
         data-api-base="<c:url value='/api/chatroom'/>"
         data-ai-endpoint="<c:url value='/aichat-api/message'/>">
        <div class="col-sm-10 container-800">
            <div class="section-header">
                <h2>🎧 고객 상담 센터</h2>
                <p>무엇을 도와드릴까요?</p>
            </div>

            <div class="inquiry-info">
                <h5>📋 상담 안내</h5>
                <ul>
                    <li>먼저 AI 상담사가 신속히 안내해 드립니다.</li>
                    <li>“상담사 연결”을 입력하시면 사람 상담으로 바로 연결해 드립니다.</li>
                    <li>실시간 상담 가능 시간: 평일 09:00 ~ 18:00 (긴급: 1588-0000)</li>
                </ul>
            </div>

            <!-- AI 섹션 -->
            <section id="aiSection">
                <div class="chat-status">
                    <div class="status-icon">💬</div>
                    <div class="status-message">AI 1차 상담</div>
                    <div class="status-detail">상담사가 연결되기 전, AI 상담사와 먼저 이야기해보세요.</div>
                    <div class="chip-group">
                        <button type="button" class="chip" data-topic="LOVE">연애 고민</button>
                        <button type="button" class="chip" data-topic="MATCHING">매칭 문의</button>
                        <button type="button" class="chip" data-topic="COACHING">프로필/스타일 코칭</button>
                        <button type="button" class="chip" data-topic="SCHEDULE">일정 도와줘</button>
                        <button type="button" class="chip" data-topic="PROJECT_HELP">프로젝트 도움</button>
                    </div>
                </div>
                <div class="chat-panel">
                    <div id="aiMsgs" class="chat-messages"></div>
                    <div class="chat-input">
                        <textarea id="aiMsg" placeholder='무엇이든 편하게 말씀해 주세요. (Enter 전송 / "상담사 연결" 입력 시 바로 이관)'></textarea>
                        <button type="button" id="aiSendBtn">전송</button>
                    </div>
                    <button type="button" id="callAgentBtn" class="call-agent-btn">상담사 연결 요청</button>
                </div>
            </section>

            <!-- 사람 상담 섹션 -->
            <section id="humanSection" style="display:none;">
                <!-- 상단 안내카드: AI 섹션의 헤더 카드와 톤 통일 -->
                <div id="humanStatusBox" class="chat-status">
                    <div class="status-icon">💬</div>
                    <div class="status-message">사람 상담 대기</div>
                    <div class="status-detail">상담사 연결을 준비 중입니다.</div>
                    <div class="room-info">채팅방 번호: - | 고객 ID: -</div>
                </div>

                <!-- 영상 통화 버튼 (AI 섹션의 "상담사 연결" 버튼과 비슷한 톤) -->
                <button id="humanVideoBtn" class="btn-video-call" disabled>
                    <i class="fas fa-video"></i> 영상 통화 시작
                </button>

                <!-- 대화 카드: AI 섹션의 .chat-panel 재사용 -->
                <div class="chat-panel">
                    <div class="chat-status-indicator" style="margin-bottom:12px;font-size:14px;color:#64748b">
                        연결 상태: <span id="humanConnText" class="text-danger">연결 대기 중...</span>
                    </div>

                    <!-- 메시지 영역: AI와 동일한 .chat-messages 박스 -->
                    <div id="humanMessages" class="chat-messages"></div>

                    <!-- 입력창: AI와 동일 레이아웃 -->
                    <div class="human-input-group">
                        <input type="text" id="humanInput" placeholder="상담사에게 메시지를 입력하세요" disabled>
                        <button id="humanSendBtn" disabled>전송</button>
                    </div>
                </div>

                <!-- 영상 통화 모달은 기존 그대로 -->
                <div id="videoModal" class="video-modal">
                    <div class="video-modal-content">
                        <div class="video-modal-header">
                            <h3><i class="fas fa-video"></i> 영상 상담</h3>
                            <button class="video-modal-close" id="videoCloseBtn">&times;</button>
                        </div>
                        <div class="video-modal-body">
                            <div class="video-container">
                                <div class="video-wrapper">
                                    <video id="localVideo" autoplay playsinline muted class="video-stream"></video>
                                    <div class="video-label">내 화면</div>
                                </div>
                                <div class="video-wrapper">
                                    <video id="remoteVideo" autoplay playsinline class="video-stream"></video>
                                    <div class="video-label">상담사 화면</div>
                                </div>
                            </div>
                            <div class="video-controls">
                                <button id="videoEndBtn" class="video-control-btn"><i class="fas fa-phone-slash"></i> 통화 종료</button>
                            </div>
                            <div id="videoConnStatus" class="connection-status disconnected">연결 대기 중</div>
                        </div>
                    </div>
                </div>
            </section>

        </div>
    </div>
</div>