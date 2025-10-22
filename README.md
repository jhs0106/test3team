### 🧑‍💻TEAM 3 - 파일럿명 : 사람다움 케어
***
### 시연 영상 : [![Video Label](http://img.youtube.com/vi/JNBo558s100/0.jpg)]
***
# 🎯 주제
-  Spring Boot와 JSP 그리고 OpenAI API를 중심으로 구축된 케어 웹앱 
-  외모 코칭, AI상담+상담사(코치) 상담, 일기 쓰기, 습관 관리, 일정 관리, 오늘의 책 추천, 내 얼굴 기반 옷 추천 등의 기능을 제공하는  웹 애플리케이션
***
# ⌛개발 기간
- 25.10.17 ~ 25.10.22
***
# 🕺구성원/역할
1. 주민성(Rediaum)          <https://github.com/Rediaum>
- PM(sub)

2. 주희성(jhs0106)        <https://github.com/jhs0106>
- PL&PM, readme.md 작성

3. 이다온(daon217)         <https://github.com/daon217>
- DEV

3. 이승호(lsh030412)         <https://github.com/lsh030412>
- DEV
***
# 기능 설명
## 1. Appearance (외모 코칭)
   이 기능은 사용자의 사진을 AI가 다각도로 분석하여 외모 및 스타일링에 대한 맞춤 코칭을 제공
- 주요 기능 (Face: 얼굴 분석)
  - 다각도 사진 촬영: 사용자가 웹캠을 통해 정면, 좌측, 우측, 위쪽, 아래쪽 등 총 5가지 각도의 얼굴 사진을 순서대로 촬영.
  - AI 상세 분석: AI는 각 각도에서 얻은 정보를 바탕으로 얼굴 특징 분석, 맞춤 눈썹 디자인 제안, 추천 헤어스타일, 맞춤형 메이크업 가이드, 일상 맞춤 케어 팁 등의 정보를 제공
  - 종합 코칭 요약: 최종적으로 모든 각도의 분석 결과를 종합하여 고객만을 위한 장기적인 스타일링 및 관리 계획을 한눈에 볼 수 있도록 요약 제공

- 주요 기능 (Clothes: 의상 스타일링 분석)
  - 전신 사진 촬영: 사용자가 웹캠을 통해 정면, 좌측, 우측 등 총 3가지 각도의 전신 사진을 촬영하여 현재 입고 있는 의상 스타일을 코칭받음.
  - AI 스타일링 피드백: AI는 각 각도의 사진을 분석하여 체형과 사이즈 적합성 평가, 컬러와 질감 조화 분석, 스타일링 개선 제안, 추천 아이템 및 액세서리 등의 코칭을 제공

## 2. Book (맞춤형 도서 추천)
- 이 기능은 AI가 간단한 설문을 통해 사용자의 심리 상태와 환경을 종합적으로 분석하여 오늘 읽으면 좋을 책을 추천해 주는 기능.

- 주요 기능
  - 사용자 설문: 사용자는 현재 기분, 그 기분을 느끼게 된 이유, 오늘 독서에 투자할 수 있는 시간, 최근의 고민거리 등 4가지 질문에 답변합니다.
  - AI 기반 추천: 답변을 바탕으로 AI는 전문 북 큐레이터 역할을 맡아 사용자에게 가장 적합한 3권의 책을 추천
  - 상세 추천 이유 제공: 단순히 책 제목만 나열하는 것이 아니라, 각 책의 추천 이유, 핵심 메시지, 그리고 사용 가능한 독서 시간을 고려한 효율적인 독서 방법까지 구체적으로 안내해줌.

## 3. Diary (AI 감성 일기)
- 이 기능은 사용자가 일기를 작성하고 저장하면, AI가 그 내용을 분석하여 공감과 조언이 담긴 피드백을 자동으로 생성해 주는 기능

- 주요 기능
  - 일기 작성 및 저장: 사용자가 오늘의 제목과 내용을 입력하고 저장 버튼을 누르면 일기가 기록.
  - AI 피드백 자동 생성: 일기 내용이 서버에 전송되면, AI는 '섬세한 상담 코치' 역할을 수행하며 내용을 분석.
  - 공감과 실천 조언: AI는 사용자의 감정에 공감하는 피드백과 실천 가능한 간단한 조언을 3문장 이내의 짧고 따뜻한 메시지로 생성.
  - 일기 목록 및 조회: 저장된 일기는 AI의 피드백과 함께 목록(diarylist)에서 확인 가능하며, 개별 일기 조회(view) 시 상세 내용과 AI 코멘트를 확인할 수 있음.

## 4. Schedule (일정 관리) 기능
- 사용자가 일정을 입력하면 AI가 자동으로 분석하여 캘린더에 일정 추가 (월/주/일별 뷰 제공)
- 5가지의 카테고리를 설정 (외모관리 / 대화연습 / 취미활동 / 데이트연습 / 자기계발)

- AI 기능 : 한 번에 최대 7개의 일정만 생성 (토큰 제한), '내일', '이번 주' 등 상대적 시간 표현 처리, 시간 미지정 시 기본값 07:00 설정, 운동 일정일 경우 "운동내용 | 식단" 형식으로 내용 생성 (40자 이내)

- 사용자 화면 :
  - 채팅 인터페이스에 일정 입력 (예: "내일 오후 7시 헬스장")
  - AI가 "분석 중..." 로딩 메세지 표시
  - 일정이 캘린더에 추가됨
  - 캘린더 이벤트(일정) 클릭 시 상세 모달 팝업 띄움 (제목, 카테고리, 시간, 장소, 설명, 삭제/닫기 버튼)


## 5. ai2(습관 관리)
- 습관 등록 : 이름, 카테고리, 주 당 목표 빈도, 설명 입력(선택)
- 일일 체크인 : 오늘 수행한 습관 체크
- 연속 달성 추적 : 7일 연속 달성 시 축하 알림
- AI 주간 리포트 : AI코치가 한 주간의 습관 데이터를 분석하여 맞춤형 피드백 제공


- AI 코치 주간 리포트 :
    - 통계 표시 : 전체 습관 수, 목표 달성 습관 수, 평균 달성률
    - AI 분석 : 사용자의 습관 데이터를 기반으로 성취도 분석, 개선 방안 및 격려 메세지 생성

- 사용자 화면 :
  - 등록된 습관이 없을 때 안내 메세지와 "새 습관 추가"
  - 7일 연속 달성 시 축하 알림
  - 모달 기반 주간 리포트 표시

## 6. AI 상담사 기능

- 고객 응대 및 문제 해결 지원 시스템
  - 사용자가 텍스트로 문의나 요청을 입력하면 AI가 문장을 분석해 적절한 답변, 해결 방법, 또는 상담사 연결 단계를 수행해줌
  - FAQ, 불만 접수, 정보 문의 등 1차 처리
  - 사람이 개입해야 하는 문의는 AI가 요약·분류하여 관리자에게 전달

- AI 기능
  - 문맥·감정·의도 분석
  - 자동 분류: 일반문의 / 오류신고 / 불만접수 / 기능요청 / 기타
  - 감정 분석으로 부정적 어조 시 진정적 톤 적용
  - 해결 가능 시 가이드·명령형 답변 제공
  - 해결 불가 시 상담사 연결 버튼과 문의 요약 생성
  - 상담 로그 자동 기록 및 사용자별 대화 이력 관리
  - 응답 길이 제한(약 200자), 불필요한 반복 방지
  - 대화 재진입 시 직전 문맥 복원

- 사용자 화면 흐름
  - 하단 입력창에 메시지 입력 후 전송
  - “AI가 분석 중입니다…” 로딩 메시지 표시
  - AI 답변 풍선 출력
  - 답변 형태: 텍스트 / 링크형(가이드 이동) / 선택형(예·아니오, 카테고리 버튼)
  - 해결 불가 시 “상담사에게 연결할까요?” 버튼 제공
  - 대화 이력 보기 및 초기화 지원

예시)
- 사용자: “로그인이 안 돼요”
- AI: “비밀번호를 잊으셨나요? 비밀번호 찾기 페이지를 안내드릴게요”
- 사용자: “그것도 안 돼요”
- AI: “이 문제는 상담사 연결이 필요해요. 연결하시겠어요?”
- 상담사에게 요약과 함께 자동 전달

## 7. AI 옷 추천 / 가상 착장 기능(외모 코칭 부족한 부분을 메꾸기 위한 2번째 기능)
- 사용자가 셀피(사진)를 업로드하면 AI가 얼굴·피부 톤을 분석하여 개인 맞춤 색상 팔레트와 옷 스타일을 추천
- 선택한 아이템을 AI 이미지 생성으로 실제 착용 이미지처럼 합성(가상 착장)

- AI 기능
  - 얼굴 인식 및 피부 톤 분석(밝기·대비·색조)
  - 퍼스널 컬러 진단(봄·여름·가을·겨울)
  - 얼굴형 인식(계란형, 각진형, 둥근형 등)
  - 분위기 분석(쿨톤, 웜톤)
  - 추천 색상 (HEX, 최대 6개)
  - 카테고리별 추천: 상의 / 하의 / 아우터 / 원피스
  - 톤·대비·성별 기반 색상 가중치 계산
  - 가상 착장 합성 시 성별에 맞춘 체형·포즈·헤어스타일 반영
  - 출력 해상도: 상반신 1024x1024, 전신 1024x1792 자동 조정
  - 밝기(brightness), 채도(saturation) 수동 조정 가능

- 사용자 화면 흐름
  - 셀피 업로드 → 미리보기 표시
  - 분석 결과 표시: 톤, 대비, 얼굴형, 분위기, 색상 팔레트
  - 추천 아이템 카드: 썸네일, 이름, 추천 이유, 색상 칩, “입어보기” 버튼, 입어보기시 로그인된 사용자의 성별 정보를 llm이 입력 받아 반영
  - “입어보기” 클릭 시 합성 진행(처리 중 메시지와 스피너), 완료 후 프리뷰 갱신
  - 색상·밝기·채도 값 변경 시 재합성으로 반영

## 8. Review (케어 후기 작성)
- 이 기능은 사람다움 케어 이용자가 별점과 후기를 남기면 AI가 맞춤 케어 응답과 후속 제안을 즉시 돌려주고, 다른 회원이 참고할 수 있도록 최신 후기를 공유.
- 주요 기능 (리뷰 작성 화면)
    - 로그인 여부를 확인해 입력 폼과 별점 버튼을 활성/비활성화하며, 미로그인 시 안내 메시지를 노출.
    - 사용자가 별점을 선택하고 후기를 작성하면 `/api/reviews`에 JSON으로 전송하고, 성공 시 입력값을 초기화하며 알림과 함께 최신 데이터를 다시 불러옴.
    - 최근 등록된 후기를 불러와 회원 이름, 별점(별 아이콘), 후기 본문, 케어 응답, 작성 시각을 리스트 형태로 렌더링하고, 로딩/오류/빈 상태에 맞춰 메시지를 줌.
- 주요 기능 (백엔드 & AI 케어 플랜)
    - `ReviewController`가 리뷰 저장(POST)과 최근 리뷰 조회(GET), 케어 플랜 생성(GET `/action-plan`)을 처리하며, 로그인 누락 시 401, 잘못된 입력 시 400을 반환함.
    - `ReviewService`는 회원·본문·별점을 검증하고 1~5점 범위로 정규화한 뒤 `CustomerCareService`를 통해 케어 톤·응답 메시지·후속 제안을 포함한 `CustomerCarePlan`을 생성.
    - 생성된 플랜을 기반으로 리뷰 엔터티를 구성해 MyBatis 매퍼로 `decision_member_review` 테이블에 저장하고, 감정 레이블이 없을 때는 별점으로 POSITIVE/NEUTRAL/NEGATIVE를 알려줌.
- 주요 기능 (리뷰 데이터 제공)
    - `ReviewRepository`는 회원 테이블과 조인해 작성자 이름, 케어 응답, 생성일을 포함한 최신 리뷰를 내려주며, 프론트는 이를 케어 응답 카드와 리스트에 반영.

## 9. Review Insight (관리자 인사이트)
- 특이사항 : 어드민 로그인은 아이디(admin), 비번(111111)으로 고정 DB 연결 X 
- 이 기능은 관리자 페이지에서 최근 리뷰 들을 주기적으로 분석해 AI 요약, 집중 케어 포커스, 실행 과제, 응원 메시지, 감정 분포, 최신 리뷰 리스트를 한 화면에 제공.
- 주요 기능 (관리자 화면)
    - `/views/care-insights.jsp` 스크립트가 최근 리뷰 수 선택, 로딩/오류 처리, 3분 간격 자동 새로고침 타이머를 제어하고, 필요 시 즉시 재조회함.
    - API 응답을 받아 전체 리뷰 수, 평균 별점(별 아이콘 포함), 감정 배지(긍정/중립/주의)를 카드로 표시하며, 실행 과제와 최근 리뷰(케어 응답, 감정 배지, 작성 시각)를 리스트로 줌.
    - 데이터가 없거나 불러오기 실패 시 상황에 맞는 플레이스홀더 문구를 출력하고, 재시도 시 상태를 초기화
- 주요 기능 
    - `ReviewInsightController`가 `/api/care-insights` GET 요청을 받아 `ReviewInsightService`에 주고, limit 파라미터는 1~100 범위로 보정
    - `ReviewInsightService`는 최근 리뷰가 없으면 기본 안내 메시지를 채운 정보를 반환하고, 데이터가 있으면 리뷰 타임라인·별점·감정을 프롬프트로 구성해 ChatClient를 호출함.
    - AI 분석: LLM 결과가 비정상일 때는 로그를 남기고 안전한 기본 메시지를 채우며, 성공/실패와 무관하게 평균 별점, 감정 카운트, 최근 5건의 리뷰(파생 감정 포함)를 `ReviewCareInsight` DTO에 줌.

***
# db에 필요한 테이블들(sql 스크립트)
```
-- 회원 테이블 ddl
DROP TABLE IF EXISTS decision_member CASCADE;

CREATE TABLE decision_member (
    member_no        BIGSERIAL PRIMARY KEY,
    login_id         VARCHAR(50)  NOT NULL,
    password         VARCHAR(255) NOT NULL,
    name             VARCHAR(100) NOT NULL,
    gender           VARCHAR(10)  NOT NULL,
    birth_date       DATE,
    address          VARCHAR(255),
    asset_status     VARCHAR(100),
    phone_number     VARCHAR(30)  NOT NULL,
    membership_level VARCHAR(20)  NOT NULL DEFAULT '스탠다드',
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX decision_member_login_id_uindex
    ON decision_member (login_id);

COMMENT ON TABLE decision_member IS '고객 회원 정보';
COMMENT ON COLUMN decision_member.gender IS '성별 (남성/여성/기타)';
```

```
-- 리뷰 테이블 ddl
DROP TABLE IF EXISTS decision_member_review;

CREATE TABLE decision_member_review (
    review_id      BIGSERIAL PRIMARY KEY,
    member_no      BIGINT      NOT NULL REFERENCES decision_member(member_no) ON DELETE CASCADE,
    rating         SMALLINT    NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review         TEXT        NOT NULL,
    care_response  TEXT        NOT NULL,
    sentiment      VARCHAR(20),
    created_at     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_decision_member_review_member_no
    ON decision_member_review (member_no);

CREATE INDEX idx_decision_member_review_created_at
    ON decision_member_review (created_at DESC); 
```

```
-- 일기 ddl
CREATE TABLE IF NOT EXISTS diary_entry (
                                           diary_id BIGSERIAL PRIMARY KEY,
                                           title VARCHAR(150) NOT NULL,
                                           content TEXT NOT NULL,
                                           ai_feedback TEXT NOT NULL,
                                           entry_date DATE NOT NULL,
                                           created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX IF NOT EXISTS idx_diary_entry_entry_date ON diary_entry(entry_date DESC); 
```
