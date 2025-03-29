# 🐍 flask_api_guidelines.md

## 📘 Flask API 개발 가이드 (for Pingtelligent)
본 문서는 Flask 기반의 AI 분석 서버를 개발하기 위한 기준을 정의합니다. 이 서버는 Flutter 앱 및 Raspberry Pi 장비와 통신하며, 얼굴 인식, 경기 분석, 자동 심판 등의 핵심 기능을 담당합니다.

---

## 📦 프로젝트 구조 (예시)
```
flask_server/
├── app.py              # 엔트리 포인트
├── routes/             # API 라우트 정의
│   ├── face.py         # 얼굴 인식 API
│   ├── match.py        # 경기 분석 API
│   └── score.py        # 자동 심판 API
├── services/           # AI 모델 로직 분리
│   ├── face_recognition.py
│   ├── ball_analysis.py
│   └── scoring_ai.py
├── utils/              # 공통 유틸리티 함수
├── static/             # 영상, 이미지 저장용 (임시)
├── requirements.txt    # 의존성 목록
└── config.py           # 환경설정 (포트, 경로 등)
```

---

## 🚀 API 서버 기본 설정
```python
# app.py
from flask import Flask
from routes.face import face_api
from routes.match import match_api
from routes.score import score_api

app = Flask(__name__)
app.register_blueprint(face_api)
app.register_blueprint(match_api)
app.register_blueprint(score_api)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

## 📡 AI 모델 실행 구조
- 모든 AI 관련 로직은 `services/` 폴더 내에 분리하여 작성
- 비동기 처리를 고려하여 heavy 연산은 `ThreadPoolExecutor` 또는 `asyncio`로 처리 가능
- 예측 결과는 JSON 형식으로만 응답

---

## 📂 예시: 얼굴 인식 API (routes/face.py)
```python
from flask import Blueprint, request, jsonify
from services.face_recognition import recognize_face

face_api = Blueprint('face_api', __name__)

@face_api.route('/api/recognize-face', methods=['POST'])
def recognize():
    image_url = request.json.get('image_url')
    result = recognize_face(image_url)
    return jsonify(result)
```

---

## 🧪 테스트 & 디버깅
- Postman 또는 curl로 각 API 개별 테스트
- 로컬에서는 `localhost:5000`, 배포 시엔 `.env`로 주소 관리
- Flask 디버깅 모드 사용 가능: `app.run(debug=True)`

---

## 🔐 보안 및 예외 처리
- 모든 API 응답은 다음 형식을 따라야 함:
```json
{ "status": "success", "data": {...} }
{ "status": "error", "message": "에러 내용" }
```
- 이미지 다운로드 실패, 모델 분석 오류 등은 `try/except`로 예외 처리
- 추후 Firebase ID 토큰 인증 추가 고려 (Authorization header)

---

## 🧠 AI 모델별 참고사항
| 기능 | 라이브러리 | 처리 방식 |
|------|------------|-----------|
| 얼굴 인식 | OpenCV, dlib | 이미지 URL 입력 → 얼굴 ID 추출 |
| 공 분석 | YOLOv5 | 영상 또는 프레임 입력 → 공 위치/속도 분석 |
| 자동 심판 | Custom TensorFlow 모델 | 센서+영상 결합 분석 → 점수 판정 |

---

## ✅ 정리
- Flask 서버는 앱과의 중간 허브이며, 모든 AI 처리는 독립된 서비스로 구성해야 함
- 코드 분리를 통해 기능별 유지보수를 쉽게 하고, 확장성을 고려
- 이 가이드를 기준으로 `api_documentation.md`에 정의된 API를 정확히 구현해야 함