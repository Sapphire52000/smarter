# ✅ checklist.md - 초보자용 확장판

> 이 문서는 Pingtelligent 프로젝트의 진행 상황을 기능별로 체크할 수 있도록 도와줍니다. 핵심 목표 5가지에 따라 항목을 구성하며, 각 항목은 초보자도 따라할 수 있도록 세부적인 단계로 나뉘어 있습니다.
-> 특히 어떤 일이 추가되거나 어떤 일을 끝냈을 때 언제나 업데이트하도록 합니다.

---

## 🧭 프로젝트 핵심 목표
1. 학생 출석 관리
2. 코치 시간표 자동화
3. 스마트 점수판 기반 대회 운영
4. AI 기반 탁구 데이터 수집 및 분석
5. AI 자동 심판 시스템

---

## 🔧 공통 사전 작업

### 개발 환경 구축
- [x] Flutter 설치 및 IDE 설정 (VS Code 권장)
  - 📘 [Flutter 설치 가이드](https://flutter.dev/docs/get-started/install)
  - 📘 [VS Code Flutter 확장 설치](https://flutter.dev/docs/development/tools/vs-code)
- [x] Python 3.8+ 설치 및 가상환경 구성
  - 📘 [Python 설치 가이드](https://www.python.org/downloads/)
  - 📘 [venv 가상환경 사용법](https://docs.python.org/3/library/venv.html)

### 프로젝트 기본 설정
- [x] `.cursor.rules` 파일 완성 및 설정 적용
- [ ] 프로젝트 이름 및 로고 확정
  - 간단한 로고 제작: [Canva](https://www.canva.com/) 활용

### Firebase 설정
- [x] Firebase 계정 생성 (Google 계정 필요)
- [x] 새 Firebase 프로젝트 생성
  - 📘 [Firebase 프로젝트 생성 가이드](https://firebase.google.com/docs/projects/learn-more)
- [x] Firebase CLI 설치 및 로그인
  ```bash
  npm install -g firebase-tools
  firebase login
  ```
- [x] Flutter에 Firebase 연결
  - 📘 [FlutterFire 설정 가이드](https://firebase.flutter.dev/docs/overview)
  - 패키지 설치: firebase_core, cloud_firestore, firebase_database
- [ ] Firestore 데이터베이스 생성 및 규칙 설정
- [ ] Realtime Database 생성 및 규칙 설정

### Raspberry Pi 준비
- [ ] Raspberry Pi OS 설치 및 기본 설정
  - 📘 [Raspberry Pi OS 설치 가이드](https://www.raspberrypi.org/documentation/installation/)
- [ ] SSH 접속 설정
  - 📘 [SSH 접속 가이드](https://www.raspberrypi.org/documentation/remote-access/ssh/)
- [ ] 필요한 하드웨어 준비
  - Raspberry Pi 4 (최소 2GB RAM)
  - Pi 카메라 모듈
  - MPU6050 진동 센서
  - 버튼 모듈
  - LED 디스플레이 (혹은 모니터)
  - 점퍼 와이어 및 브레드보드

---

## ✅ 1. 학생 출석 관리

### Firestore 데이터 구조 설계
- [ ] Firestore 기본 사용법 학습
  - 📘 [Firestore 기본 가이드](https://firebase.google.com/docs/firestore)
- [ ] 출석 컬렉션 구조 (`attendance`) 설계
  ```json
  attendance (collection)
  ├── student_id (document)
      ├── name: string
      ├── photo_url: string
      ├── total_attendance: number
      ├── dates: {
           "2025-03-20": true,
           "2025-03-21": false
         }
  ```
- [ ] 테스트 데이터 수동 입력해보기

### Flutter 앱 기본 구조 생성
- [ ] Flutter 프로젝트 생성
  ```bash
  flutter create pingtelligent
  ```
- [ ] MVVM 폴더 구조 생성
  ```
  lib/
  ├── models/
  │   └── attendance_model.dart
  ├── viewmodels/
  │   └── attendance_viewmodel.dart
  ├── views/
  │   └── attendance_screen.dart
  ├── services/
  │   └── firebase_service.dart
  └── main.dart
  ```
- [ ] 기본 모델 클래스 작성 (AttendanceModel)
- [ ] Provider 패키지 설치 및 기본 설정

### 얼굴 인식 시스템 구축
- [x] Flask 기본 학습
  - 📘 [Flask 튜토리얼](https://flask.palletsprojects.com/en/2.0.x/tutorial/)
- [x] Flask 프로젝트 생성
  ```bash
  mkdir flask_api
  cd flask_api
  python -m venv venv
  source venv/bin/activate  # Windows: venv\Scripts\activate
  pip install flask
  ```
- [x] 기본 Flask 앱 구조 생성
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
- [x] 기본 "Hello, World" API 엔드포인트 생성 및 테스트
- [x] 얼굴 인식 라이브러리 설치 (OpenCV)
  ```bash
  pip install opencv-python numpy
  ```
  - 💡 dlib 설치 문제 시: [CMake 설치](https://cmake.org/download/) 필요
- [x] 얼굴 인식 테스트 코드 작성
  - 샘플 이미지로 테스트
- [x] `/api/recognize-face` API 엔드포인트 완성
  - 요청/응답 형식은 `api_documentation.md` 참조

### Raspberry Pi 카메라 연결
- [ ] Pi 카메라 물리적 연결
  - 📘 [Pi 카메라 연결 가이드](https://www.raspberrypi.org/documentation/accessories/camera.html)
- [ ] 카메라 활성화 (raspi-config)
  ```bash
  sudo raspi-config
  ```
- [ ] 카메라 테스트 코드 작성
  ```python
  from picamera import PiCamera
  camera = PiCamera()
  camera.capture('test.jpg')
  ```
- [ ] Pi에서 Flask 서버 실행 및 카메라 연동 테스트

### Flutter 앱 UI 구현
- [ ] 출석 화면 UI 디자인
  - 카메라 촬영 버튼
  - 학생 목록 표시
  - 출석 현황 그리드/캘린더
- [ ] 카메라 기능 추가 (camera 패키지)
  ```bash
  flutter pub add camera
  ```
- [ ] HTTP 요청 기능 추가 (http 패키지)
  ```bash
  flutter pub add http
  ```
- [ ] Flask API 호출 코드 작성
  ```dart
  final response = await http.post(
    Uri.parse('http://<SERVER_IP>:5001/api/recognize-face'),
    body: jsonEncode({ 'image_url': photoUrl }),
    headers: { 'Content-Type': 'application/json' },
  );
  ```

### 출석 기능 통합 및 테스트
- [ ] Flutter에서 사진 촬영 → Flask API 전송 → 결과 표시 흐름 테스트
- [ ] Firestore에 출석 데이터 저장 코드 작성
- [ ] 출석 내역 보기 화면 구현
- [ ] 전체 출석 기능 통합 테스트

---

## ✅ 2. 코치 시간표 자동화

### 시간표 데이터 구조 설계
- [ ] 시간표 컬렉션 구조 (`schedules`) 확정
  ```json
  schedules (collection)
  ├── coach_id (document)
      ├── name: string
      ├── schedule: [
           {
             "date": "2025-03-22",
             "time": "14:00",
             "student": "김철수"
           },
           ...
         ]
  ```
- [ ] Firestore에 테스트 데이터 입력

### Flutter 시간표 화면 구현
- [ ] 시간표 모델 클래스 작성
  ```dart
  class ScheduleItem {
    final String date;
    final String time;
    final String student;
    
    ScheduleItem({required this.date, required this.time, required this.student});
    
    factory ScheduleItem.fromJson(Map<String, dynamic> json) {
      // JSON 변환 코드
    }
  }
  ```
- [ ] 시간표 ViewModel 작성
  ```dart
  class ScheduleViewModel extends ChangeNotifier {
    // Firestore 연동 및 상태 관리 코드
  }
  ```
- [ ] 시간표 UI 구현
  - 달력 형태 (table_calendar 패키지 활용)
  - 목록 형태 (ListView 활용)
- [ ] Firestore 연동 테스트

### 메시지 분석 기능 개발
- [ ] OpenAI API 키 발급
  - 📘 [OpenAI API 가이드](https://platform.openai.com/docs/guides/authentication)
- [ ] Flask에 OpenAI 라이브러리 설치
  ```bash
  pip install openai
  ```
- [ ] `/api/analyze-message` API 엔드포인트 생성
  ```python
  @app.route('/api/analyze-message', methods=['POST'])
  def analyze_message():
      message = request.json.get('message')
      # OpenAI API 호출 코드
      return jsonify(result)
  ```
- [ ] 메시지 → 시간 추출 로직 구현
  - 예: "내일 오후 3시에 레슨 가능한가요?" → {"date": "2023-04-02", "time": "15:00"}
- [ ] 추출된 시간을 Firestore에 저장하는 로직 작성

### Flutter 메시지 입력 화면
- [ ] 메시지 입력 UI 구현
- [ ] 전송 버튼 클릭 → Flask API 호출 → 결과 표시 흐름 구현
- [ ] 시간표 자동 업데이트 확인

### 시간표 변경 알림 기능
- [ ] Firebase Cloud Messaging 설정
  ```bash
  flutter pub add firebase_messaging
  ```
- [ ] 시간표 변경 시 알림 발송 로직 구현
- [ ] 앱에서 알림 수신 및 표시 기능 구현

---

## ✅ 3. 스마트 점수판 운영

### Realtime Database 설계
- [ ] Realtime DB 기본 사용법 학습
  - 📘 [Realtime Database 가이드](https://firebase.google.com/docs/database)
- [ ] 점수판 데이터 구조 설계
  ```json
  live_matches
  ├── table_1
      ├── player1: "김철수"
      ├── player2: "박영희"
      ├── score1: 7
      ├── score2: 9
      ├── status: "in_progress"  // or "finished"
  ```
- [ ] 테스트 데이터 입력

### Raspberry Pi 하드웨어 구성
- [ ] 버튼 모듈 연결
  - 📘 [GPIO 핀 배치](https://www.raspberrypi.org/documentation/usage/gpio/)
  - 플레이어1 점수 증가 버튼, 플레이어2 점수 증가 버튼, 리셋 버튼
- [ ] 버튼 입력 처리 코드 작성
  ```python
  import RPi.GPIO as GPIO
  
  GPIO.setmode(GPIO.BCM)
  GPIO.setup(17, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # 플레이어1 버튼
  
  def button_callback(channel):
      # 점수 증가 처리
  
  GPIO.add_event_detect(17, GPIO.FALLING, callback=button_callback, bouncetime=300)
  ```
- [ ] LED 또는 디스플레이 연결
  - 7세그먼트 디스플레이 또는 OLED 디스플레이
- [ ] 점수 표시 코드 작성
  ```python
  # 예: OLED 디스플레이 사용 시
  from luma.core.interface.serial import i2c
  from luma.core.render import canvas
  from luma.oled.device import ssd1306
  
  serial = i2c(port=1, address=0x3C)
  device = ssd1306(serial)
  
  with canvas(device) as draw:
      draw.text((10, 10), f"Player 1: {score1}", fill="white")
      draw.text((10, 30), f"Player 2: {score2}", fill="white")
  ```

### Firebase 연동
- [ ] Firebase Realtime DB Python SDK 설치
  ```bash
  pip install firebase-admin
  ```
- [ ] 인증 설정 (서비스 계정 키 생성)
- [ ] Pi에서 Realtime DB 연동 코드 작성
  ```python
  import firebase_admin
  from firebase_admin import credentials, db
  
  cred = credentials.Certificate('serviceAccountKey.json')
  firebase_admin.initialize_app(cred, {
      'databaseURL': 'https://pingtelligent.firebaseio.com'
  })
  
  def update_score(table_id, player, new_score):
      db.reference(f'live_matches/{table_id}/score{player}').set(new_score)
  ```
- [ ] 버튼 입력 → DB 업데이트 테스트

### Flutter 점수판 화면
- [ ] 실시간 DB 연동 설정
  ```dart
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref('live_matches/table_1');
  
  ref.onValue.listen((event) {
    // 실시간 데이터 처리
  });
  ```
- [ ] 점수판 UI 구현
  - 테이블별 선택 기능
  - 플레이어 이름 입력
  - 점수 실시간 표시
- [ ] 앱에서 점수 수동 조정 기능 추가

### 경기 기록 저장 기능
- [ ] 경기 종료 감지 로직
  - 예: 21점(또는 설정값) 도달 시
- [ ] Firestore `matches` 컬렉션에 기록 저장
  ```dart
  FirebaseFirestore.instance.collection('matches').add({
    'table_id': 'table_1',
    'players': {'player1': name1, 'player2': name2},
    'score': {'player1': score1, 'player2': score2},
    'winner': winner,
    'timestamp': DateTime.now().toIso8601String(),
  });
  ```
- [ ] 경기 결과 화면 구현

---

## ✅ 4. AI 기반 탁구 데이터 수집 및 분석

### Flask AI 분석 API 개발
- [ ] Flask 서버에 OpenCV, NumPy 설치
  ```bash
  pip install opencv-python numpy
  ```
- [ ] YOLOv5 설정
  ```bash
  git clone https://github.com/ultralytics/yolov5
  cd yolov5
  pip install -r requirements.txt
  ```
- [ ] 공 감지 테스트 코드 작성
  ```python
  import torch
  
  model = torch.hub.load('ultralytics/yolov5', 'yolov5s')
  results = model('test_image.jpg')
  
  # 핑퐁볼만 필터링 (class 32)
  balls = [detection for detection in results.xyxy[0] if detection[5] == 32]
  ```
- [ ] `/api/analyze-match` API 엔드포인트 구현
  - 영상 또는 프레임 받기
  - YOLOv5로 공 추적
  - 속도 및 위치 계산
  - 결과 JSON 반환

### 진동 센서 연결
- [ ] MPU6050 센서 I2C 연결
  - 📘 [I2C 설정 가이드](https://www.raspberrypi.org/documentation/hardware/raspberrypi/i2c/README.md)
- [ ] I2C 인터페이스 활성화
  ```bash
  sudo raspi-config  # Interfacing Options → I2C → Enable
  ```
- [ ] 센서 라이브러리 설치
  ```bash
  pip install mpu6050-raspberrypi
  ```
- [ ] 진동 감지 테스트 코드 작성
  ```python
  from mpu6050 import mpu6050
  
  sensor = mpu6050(0x68)
  
  def detect_edge_hit():
      data = sensor.get_accel_data()
      # 진동 임계값 검사
      if abs(data['x']) > 1.0 or abs(data['y']) > 1.0:
          return True
      return False
  ```

### 데이터 저장 및 분석
- [ ] 분석 결과 Firestore 저장 코드 작성
- [ ] 분석 데이터 구조 설계
  ```json
  ai_analysis (collection)
  ├── match_id (document)
      ├── player1: string
      ├── player2: string
      ├── ball_speeds: [
           { "time": "00:01", "speed": 5.2 },
           ...
         ]
      ├── hit_locations: [
           { "player": "김철수", "x": 120, "y": 80 },
           ...
         ]
  ```

### Flutter 분석 결과 화면
- [ ] 분석 데이터 모델 클래스 작성
- [ ] 차트 라이브러리 설치
  ```bash
  flutter pub add fl_chart
  ```
- [ ] 데이터 시각화 UI 구현
  - 속도 그래프
  - 히트맵 (위치 시각화)
  - 기본 통계 (평균 속도, 최고 속도 등)

---

## ✅ 5. AI 자동 심판 시스템

### 점수 판정 로직 개발
- [ ] 자동 판정 알고리즘 설계
  - 공 궤적 + 테이블 엣지 센서 + 네트 센서 조합
- [ ] 룰 기반 점수 판정 코드 작성
  ```python
  def score_point(ball_position, sensor_data):
      # 판정 로직 구현
      return { "point": "player1", "reason": "ball_out" }
  ```
- [ ] `/api/auto-score` API 엔드포인트 구현
  - 현재 프레임 + 센서 데이터 입력
  - 점수 판정 로직 실행
  - 판정 결과 JSON 반환

### 실시간 점수 업데이트
- [ ] AI 판정 → Firebase Realtime DB 연동
  ```python
  def update_score_from_ai(table_id, result):
      if result["point"] == "player1":
          ref = db.reference(f'live_matches/{table_id}/score1')
          current_score = ref.get()
          ref.set(current_score + 1)
      elif result["point"] == "player2":
          # player2 점수 증가 로직
  ```
- [ ] 판정 히스토리 저장 (이유 포함)

### Flutter 자동 심판 모드 UI
- [ ] 심판 모드 전환 스위치
- [ ] 자동 판정 이력 표시
- [ ] 판정 이유 설명 표시
- [ ] 수동/자동 모드 전환 기능

### 시스템 통합 테스트
- [ ] 전체 시스템 흐름 테스트
  - 카메라 → 공 감지 → 센서 → 판정 → 점수 업데이트
- [ ] 에지 케이스 테스트 (여러 상황 시뮬레이션)
- [ ] 판정 정확도 개선

---

## 📁 문서 작성 체크
- [x] `firebase_data_structure.md`
- [x] `system_architecture.md`
- [x] `flutter_guidelines.md`
- [x] `api_documentation.md`
- [x] `flask_api_guidelines.md`
- [x] `deployment_guide.md`
- [x] `.cursor.rules`
- [x] 로고 및 아이콘 제작
- [x] Flutter 설치 및 기본 사용법 가이드 (Flutter 설치를 통해 확인)
- [x] Flask API 서버 구성 가이드 (Flask 서버 초기 설정 완료)
- [ ] Raspberry Pi 설정 가이드
- [ ] 하드웨어 연결 다이어그램

---

## 📚 학습 자료 모음
- **Flutter**
  - [Flutter 공식 문서](https://flutter.dev/docs)
  - [Flutter 기초 강의 (유튜브)](https://youtube.com/playlist?list=PL4cUxeGkcC9jLYyp2Aoh6hcWuxFDX6PBJ)
  - [Firebase와 Flutter](https://firebase.flutter.dev/docs/overview)

- **Flask**
  - [Flask 공식 문서](https://flask.palletsprojects.com/)
  - [Flask 메가 튜토리얼](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world)

- **Firebase**
  - [Firebase 공식 문서](https://firebase.google.com/docs)
  - [Firestore 사용법](https://firebase.google.com/docs/firestore/quickstart)

- **Raspberry Pi**
  - [Raspberry Pi 공식 문서](https://www.raspberrypi.org/documentation/)
  - [라즈베리파이 GPIO 프로그래밍](https://www.raspberrypi.org/documentation/usage/gpio/python/README.md)

- **Computer Vision / AI**
  - [OpenCV 튜토리얼](https://docs.opencv.org/master/d9/df8/tutorial_root.html)
  - [YOLOv5 사용법](https://github.com/ultralytics/yolov5)

---

📌 **Tip:** 이 문서는 기능 완료 시 각 항목에 체크 표시(✅ 또는 [x])를 하며 사용합니다.

🔥 지속적으로 업데이트하면서 전체 개발 상황을 한눈에 관리하세요!