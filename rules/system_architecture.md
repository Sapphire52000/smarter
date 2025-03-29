# ⚙️ system_architecture.md

## 🧭 시스템 아키텍처 개요
**Pingtelligent**는 Flutter 앱, Firebase 백엔드, Flask 기반 AI 서버, Raspberry Pi 장비로 구성된 분산형 스마트 탁구장 시스템입니다. 각 구성요소는 역할에 따라 분리되어 있으며, 아래와 같은 흐름으로 데이터를 주고받습니다.

---

## 🧱 전체 구성 요소

```
[Flutter 앱]  ↔  [Firebase]  ↔  [Flask AI 서버]  ↔  [라즈베리파이 장비]
           ↕
       [Firestore & Realtime DB]
```

### 📱 Flutter 앱
- 사용자 역할: 학생, 학부모, 코치, 관리자
- 주요 기능:
  - 출석 현황 조회
  - 시간표 확인 및 변경 요청
  - 점수판 실시간 보기
  - 경기 기록 및 분석 확인
- 아키텍처: MVVM
- 상태관리: Provider / Riverpod
- 데이터 연동: Firebase SDK + REST API (Flask 서버)

---

### ☁️ Firebase
- **Firestore**: 기록성 데이터 저장 (출석, 시간표, 경기 기록, AI 분석 결과)
- **Realtime Database**: 실시간 점수판 데이터 (점수 반영, 테이블별 상태)
- **Authentication**: 사용자 로그인/역할 구분
- **Storage (선택)**: 얼굴 사진, 경기 영상 저장 (확장 시)

---

### 🔬 Flask AI 서버 (Microservices)
- 역할: AI 연산 담당 (예측, 판정, 분석)
- 구동 환경: 서버 PC 또는 라즈베리파이 고성능 모델 (4B 이상)
- 주요 API:
  - `/api/recognize-face` → 출석 체크
  - `/api/analyze-match` → 공 움직임 및 분석 결과 반환
  - `/api/auto-score` → 점수 판정 결과 반환
- 입력: 이미지, 센서 데이터, 비디오 프레임
- 출력: JSON 응답 (분석 결과, 판정 점수 등)

---

### 🍓 Raspberry Pi
- 역할: 실제 하드웨어 제어 및 AI 데이터 수집 보조
- 연결 장치:
  - 카메라 (얼굴 인식, 공 추적)
  - MPU6050 진동 센서 (테이블 엣지 감지)
  - 버튼 (수동 점수 입력)
  - LED 디스플레이 (점수 표시)
- 실행 방식:
  - 로컬 Python 스크립트 + Flask 연동
  - Firebase SDK 내장 → 점수판 실시간 업데이트

---

## 🔄 데이터 흐름 예시

### ✅ 출석 흐름
1. 라즈베리파이 카메라 → 얼굴 촬영
2. Flask `/recognize-face` API → 얼굴 인식
3. Firebase Firestore → 해당 학생 출석 저장
4. Flutter 앱 → 출석 확인 가능

### ✅ 점수판 흐름
1. 버튼 누름 or AI 판정 발생
2. 라즈베리파이 → Firebase Realtime DB 점수 업데이트
3. Flutter 앱 & 디스플레이 패널에 실시간 반영

### ✅ 경기 분석 흐름
1. 경기 중 영상/센서 → Flask 서버에 전송
2. YOLO + 진동 분석 → 분석 결과 반환
3. Firestore `ai_analysis`에 저장
4. Flutter 앱 → 차트 UI로 분석 결과 확인

---

## 📌 기술 요약
| 구성 요소 | 기술 | 역할 |
|------------|-------|------|
| Flutter | Dart / MVVM | 사용자 앱 (학생/코치/관리자) |
| Firebase | Firestore, RTDB, Auth | 백엔드 데이터 관리 |
| Flask | Python, REST API | AI 연산 및 분석 기능 |
| Raspberry Pi | Python, 센서연동 | 하드웨어 + 카메라/센서 제어 |
| AI 모델 | OpenCV, YOLOv5, TensorFlow | 얼굴 인식 / 공 추적 / 자동 심판 |

---

✅ 이 문서는 `firebase_data_structure.md`와 함께 개발의 기준이 되며, 기능이 추가될 때 반드시 업데이트되어야 합니다.

