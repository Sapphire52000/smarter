# 🔌 api_documentation.md

## 🧭 Flask API 명세서 (for Pingtelligent)
본 문서는 Flutter 앱 또는 라즈베리파이 장비가 호출할 Flask API의 명세를 설명합니다. AI 분석, 얼굴 인식, 자동 심판 등의 기능은 모두 Flask 서버에서 처리되며, 모든 응답은 JSON 형식입니다.

---

## ✅ 공통 사항
- Base URL: `http://<SERVER_IP>:5000`
- Request/Response: `application/json`
- 인증: 현재 없음 (추후 Firebase 토큰 검증 추가 가능)

---

## 🧠 1. 얼굴 인식 API
### POST `/api/recognize-face`
**설명:** 사진을 업로드하면 얼굴을 인식하여 해당 학생 ID를 반환합니다.

#### 📥 Request Body:
```json
{
  "image_url": "https://..."
}
```

#### 📤 Response:
```json
{
  "status": "success",
  "student_id": "abc123",
  "name": "김철수",
  "confidence": 0.98
}
```

---

## 🏓 2. 경기 분석 API (공 움직임)
### POST `/api/analyze-match`
**설명:** 경기 영상을 분석하여 공의 속도 및 충돌 위치 등 AI 분석 데이터를 반환합니다.

#### 📥 Request Body:
```json
{
  "video_url": "https://...",
  "match_id": "match_20250320_001"
}
```

#### 📤 Response:
```json
{
  "status": "done",
  "ball_speeds": [
    { "time": "00:01", "speed": 5.2 },
    { "time": "00:05", "speed": 6.1 }
  ],
  "hit_locations": [
    { "player": "김철수", "x": 120, "y": 80 },
    { "player": "박영희", "x": 140, "y": 60 }
  ]
}
```

---

## 🎯 3. 자동 심판 API
### POST `/api/auto-score`
**설명:** 실시간 경기 중 공의 궤적, 충돌 등을 분석하여 자동으로 점수를 판정합니다.

#### 📥 Request Body:
```json
{
  "frame_data": [ ... ],
  "sensor_data": [ ... ],
  "table_id": "table_1"
}
```

#### 📤 Response:
```json
{
  "status": "scored",
  "point": "player1",
  "reason": "edge detected from sensor + ball went out"
}
```

---

## ⚙️ 4. 헬스 체크 (서버 상태 확인)
### GET `/api/health`
**설명:** 서버가 정상 작동 중인지 확인합니다.

#### 📤 Response:
```json
{
  "status": "ok"
}
```

---

## 📌 참고사항
- 모든 API 호출은 비동기 방식으로 처리되며, Flutter의 `http` 패키지를 통해 사용 가능
- 예외 상황 발생 시 다음과 같은 에러 형식을 반환:
```json
{
  "status": "error",
  "message": "얼굴을 인식할 수 없습니다."
}
```

✅ 이 문서는 Flask 서버 또는 API Mock 서버를 만들 때 기준이 되는 명세서입니다. 기능이 추가되면 업데이트가 필요합니다.

