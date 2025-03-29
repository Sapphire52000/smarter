# 🧠 Backend 체크리스트 (Flask API)

## 🧭 Flask 서버 설정

### 개발 환경
- [x] Python 3.8+ 설치
- [x] 가상환경 설정
- [x] Flask 및 기본 라이브러리 설치
  - [x] Flask
  - [x] Flask-CORS
  - [x] NumPy
  - [x] OpenCV

### 프로젝트 구조
- [x] 기본 Flask 앱 생성
- [x] 폴더 구조 설정
  ```
  flask_api/
  ├── app.py
  ├── routes/
  │   └── face.py
  ├── services/
  │   └── face_recognition.py
  ├── utils/
  ├── requirements.txt
  ```
- [x] Hello World API 엔드포인트 테스트

## 👤 얼굴 인식 시스템

### 라이브러리 설정
- [x] OpenCV 설치 및 설정
- [ ] dlib 설치 및 설정 (필요시)
- [ ] face_recognition 라이브러리 설치 (권장)

### 얼굴 인식 서비스 구현
- [ ] `services/face_recognition.py` 구현
  - [ ] 얼굴 감지 기능
  - [ ] 얼굴 특징 추출 기능
  - [ ] 얼굴 비교 및 매칭 기능
- [ ] 얼굴 데이터 저장 및 관리 로직

### API 엔드포인트 구현
- [ ] `/api/recognize-face` 엔드포인트 구현
  ```python
  @app.route('/api/recognize-face', methods=['POST'])
  def recognize_face():
      image_url = request.json.get('image_url')
      # 얼굴 인식 로직
      return jsonify(result)
  ```
- [ ] 이미지 처리 및 결과 반환 로직
- [ ] 에러 핸들링 및 응답 형식 표준화

## 📅 시간표 분석 시스템

### NLP 라이브러리 설정
- [ ] OpenAI API 연동
  ```bash
  pip install openai
  ```
- [ ] API 키 환경 변수 설정
  ```python
  import os
  api_key = os.environ.get("OPENAI_API_KEY")
  ```

### 메시지 분석 서비스 구현
- [ ] `services/message_analyzer.py` 구현
  - [ ] OpenAI API 호출 로직
  - [ ] 날짜/시간 추출 로직
  - [ ] 학생/코치 정보 추출 로직

### API 엔드포인트 구현
- [ ] `/api/analyze-message` 엔드포인트 구현
  ```python
  @app.route('/api/analyze-message', methods=['POST'])
  def analyze_message():
      message = request.json.get('message')
      # 메시지 분석 로직
      return jsonify(result)
  ```
- [ ] Firebase 연동 (선택적)
  - [ ] Firestore 일정 업데이트 기능

## 🏓 경기 분석 시스템

### 컴퓨터 비전 설정
- [ ] YOLOv5 설치 및 설정
  ```bash
  git clone https://github.com/ultralytics/yolov5
  cd yolov5
  pip install -r requirements.txt
  ```
- [ ] 공 감지 모델 준비 (미리 훈련된 모델 사용)

### 분석 서비스 구현
- [ ] `services/match_analyzer.py` 구현
  - [ ] 공 감지 및 추적 로직
  - [ ] 속도 계산 로직
  - [ ] 충돌 위치 분석 로직

### API 엔드포인트 구현
- [ ] `/api/analyze-match` 엔드포인트 구현
  ```python
  @app.route('/api/analyze-match', methods=['POST'])
  def analyze_match():
      video_url = request.json.get('video_url')
      match_id = request.json.get('match_id')
      # 분석 로직
      return jsonify(result)
  ```
- [ ] 분석 결과 저장 및 관리 로직

## 🎯 자동 심판 시스템

### 센서 데이터 처리
- [ ] MPU6050 센서 데이터 처리 로직
  ```python
  def process_sensor_data(sensor_data):
      # 진동 임계값 등 판정 로직
      return edge_detected
  ```

### 심판 서비스 구현
- [ ] `services/auto_referee.py` 구현
  - [ ] 공 궤적 분석 로직
  - [ ] 센서 데이터 통합 로직
  - [ ] 규칙 기반 점수 판정 로직

### API 엔드포인트 구현
- [ ] `/api/auto-score` 엔드포인트 구현
  ```python
  @app.route('/api/auto-score', methods=['POST'])
  def auto_score():
      frame_data = request.json.get('frame_data')
      sensor_data = request.json.get('sensor_data')
      table_id = request.json.get('table_id')
      # 판정 로직
      return jsonify(result)
  ```
- [ ] 판정 결과 Firebase 연동 (Realtime DB)

## 🔄 Firebase 연동

### Firebase Admin SDK 설정
- [ ] Firebase Admin SDK 설치
  ```bash
  pip install firebase-admin
  ```
- [ ] 서비스 계정 키 설정
  ```python
  import firebase_admin
  from firebase_admin import credentials, firestore
  
  cred = credentials.Certificate('serviceAccountKey.json')
  firebase_admin.initialize_app(cred)
  ```

### Firestore 연동
- [ ] Firestore 클라이언트 설정
  ```python
  db = firestore.client()
  ```
- [ ] 출석 데이터 업데이트 기능
- [ ] 분석 결과 저장 기능

### Realtime Database 연동
- [ ] Realtime DB 클라이언트 설정
  ```python
  from firebase_admin import db
  
  # Initialize with database URL
  firebase_admin.initialize_app(cred, {
      'databaseURL': 'https://pingtelligent.firebaseio.com'
  })
  ```
- [ ] 점수판 실시간 업데이트 기능

## 🚀 배포 및 통합

### 서버 설정
- [ ] 프로덕션 환경 설정
  - [ ] Gunicorn 설정
  - [ ] WSGI 설정
- [ ] 환경 변수 관리
  - [ ] 개발/테스트/프로덕션 환경 분리

### 배포 자동화
- [ ] Docker 컨테이너화
  ```
  flask_api/
  ├── Dockerfile
  ├── docker-compose.yml
  ```
- [ ] CI/CD 파이프라인 설정 (선택적)

### 통합 테스트
- [ ] API 엔드포인트 테스트 스크립트
- [ ] Flutter 앱 연동 테스트
- [ ] 라즈베리파이 연동 테스트

## 📊 모니터링 및 로깅

### 로깅 설정
- [ ] 로깅 시스템 구현
  ```python
  import logging
  
  logging.basicConfig(
      level=logging.INFO,
      format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
  )
  ```
- [ ] 에러 추적 및 보고 시스템

### 성능 모니터링
- [ ] API 응답 시간 모니터링
- [ ] 리소스 사용량 모니터링
- [ ] 알림 시스템 구현 (선택적) 