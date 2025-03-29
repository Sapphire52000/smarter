# 🚀 deployment_guide.md

## 📦 Pingtelligent 시스템 배포 가이드
본 문서는 스마트 탁구장 시스템(Pingtelligent)을 실제 환경에 배포하기 위한 절차를 설명합니다. 앱, 서버, Firebase 설정, Raspberry Pi까지 전 구성 요소를 포함합니다.

---

## 🧱 구성요소별 배포 전략

### 📱 1. Flutter 앱 배포
#### 🔧 사전 준비
- Firebase 프로젝트 연결
- Android/iOS 각 플랫폼용 번들 ID 및 앱 등록 완료

#### ✅ Android 배포
```bash
flutter build apk --release
```
- `build/app/outputs/flutter-apk/app-release.apk` 사용
- 탁구장 태블릿/폰에 직접 설치하거나 Google Play 등록 (선택)

#### ✅ iOS 배포 (Mac + Xcode 필요)
```bash
flutter build ios --release
```
- Apple Developer 계정 필요
- TestFlight 또는 App Store 등록

---

### ☁️ 2. Firebase 설정
- Firestore: 출석, 경기 기록, AI 분석 저장
- Realtime Database: 점수판 실시간 반영
- Authentication: 이메일/비밀번호 기반 로그인
- Storage (선택): 얼굴 사진, 경기 영상 저장

#### ⚙️ 환경 변수 (Flutter 앱 내 `.env` 또는 constants.dart)
```dart
const firebaseProjectId = 'pingtelligent-app';
```

---

### 🧠 3. Flask AI 서버 배포
#### 🔧 사전 준비
- Python 3.8 이상 + 가상환경 구성
- 모델 및 의존성 설치: `pip install -r requirements.txt`

#### ✅ 개발용 실행
```bash
python app.py
```

#### ✅ 프로덕션용 실행 (gunicorn + supervisor)
```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

#### ✅ Docker 배포 (선택)
```Dockerfile
FROM python:3.9
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

---

### 🍓 4. Raspberry Pi 배포
#### 📌 설치 구성
- Python + Firebase SDK
- OpenCV / dlib / YOLOv5 등 AI 모듈 사전 설치
- Flask 서버는 Pi에서 실행하거나 외부 서버와 통신

#### ✅ 자동 실행 등록
```bash
sudo nano /etc/rc.local
# app.py 또는 service_launcher.sh 경로 추가
```

#### ✅ 카메라 & 센서 연결 테스트
- 카메라: `raspistill` or `libcamera-still`
- 진동센서: `GPIO` 코드 테스트

---

## 🛡️ 보안 및 운영 팁
- Flask API에 Firebase 인증 토큰 검증 추가 예정
- Firebase Firestore 규칙 설정 필수 (역할 기반 접근 제한)
- Raspberry Pi는 내부망으로만 연결하거나 VPN 설정 권장

---

## ✅ 전체 배포 흐름 요약
```
[Flutter 앱] → Firebase 설정 후 빌드 및 설치
[Flask 서버] → Gunicorn or Docker로 운영
[Raspberry Pi] → 카메라/센서 연결 + Flask API 연동
[Firebase] → 데이터 저장, 인증, 실시간 반영
```

📌 이 문서를 기준으로 각 파트별 배포를 마무리하면 전체 시스템이 현장에서 작동 가능해집니다.