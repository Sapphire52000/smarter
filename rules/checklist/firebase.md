# 🔥 Firebase 체크리스트

## 🧭 Firebase 프로젝트 설정

### 기본 설정
- [x] Firebase 계정 생성
- [x] 새 Firebase 프로젝트 생성
- [x] Firebase CLI 설치 및 로그인
- [x] Flutter 프로젝트에 Firebase 연결
  - [x] firebase_core 패키지 설치
  - [x] firebase_auth 패키지 설치
  - [x] firebase_options.dart 생성
  - [x] Firebase 초기화 코드 작성 (main.dart)

### 인증 (Authentication)
- [x] 인증 서비스 활성화
- [x] 구글 로그인 설정
  - [x] SHA 인증서 지문 설정 (Android)
  - [x] GoogleService-Info.plist 설정 (iOS)
  - [x] 웹 클라이언트 ID 설정 (Web)
- [ ] 애플 로그인 설정
  - [ ] Apple Developer 계정 연결
  - [ ] 서비스 식별자 설정
  - [ ] 인증 키 생성 및 등록
- [ ] 사용자 권한 그룹 설계
  - [ ] 관리자(Admin) 권한 정의
  - [ ] 코치(Coach) 권한 정의
  - [ ] 학생(Student) 권한 정의

## 📊 Firestore 데이터베이스

### 데이터베이스 설정
- [ ] Firestore 데이터베이스 생성
- [ ] 보안 규칙 설정
  - [ ] 사용자 권한별 접근 규칙 정의
  - [ ] 컬렉션별 CRUD 권한 설정
- [ ] 인덱스 설정 (필요시)

### 컬렉션 구조 구현
- [ ] `attendance` 컬렉션 구성
  - [ ] 학생 문서 구조 정의
  - [ ] 날짜별 출석 데이터 구조 설계
  - [ ] 테스트 데이터 생성
- [ ] `schedules` 컬렉션 구성
  - [ ] 코치 문서 구조 정의
  - [ ] 시간표 배열 구조 설계
  - [ ] 테스트 데이터 생성
- [ ] `matches` 컬렉션 구성
  - [ ] 경기 기록 문서 구조 정의
  - [ ] 선수, 점수, 결과 필드 설계
  - [ ] 테스트 데이터 생성
- [ ] `ai_analysis` 컬렉션 구성
  - [ ] 분석 데이터 문서 구조 정의
  - [ ] 공 속도, 위치 배열 구조 설계
  - [ ] 테스트 데이터 생성

### 쿼리 최적화
- [ ] 복합 인덱스 설정 (필요시)
- [ ] 쿼리 캐싱 전략 수립
- [ ] 대용량 데이터 페이지네이션 설계

## ⚡ Realtime Database

### 데이터베이스 설정
- [ ] Realtime Database 생성
- [ ] 보안 규칙 설정
  - [ ] 실시간 점수판 접근 규칙
  - [ ] 테이블별 접근 권한

### 데이터 구조 구현
- [ ] `live_matches` 노드 구성
  - [ ] 테이블별 하위 노드 구조
  - [ ] 선수 정보 및 점수 필드 설계
  - [ ] 경기 상태 필드 설계
- [ ] 테스트 데이터 생성
- [ ] 실시간 동기화 테스트

## 🗄️ Firebase Storage (선택적)

### 스토리지 설정
- [ ] Firebase Storage 활성화
- [ ] 보안 규칙 설정
- [ ] 폴더 구조 설계

### 파일 관리 구현
- [ ] 얼굴 사진 저장 구조
  - [ ] 학생별 폴더 구성
  - [ ] 파일 명명 규칙 정의
- [ ] 경기 비디오 저장 구조
  - [ ] 경기별 폴더 구성
  - [ ] 파일 명명 규칙 정의

## 🔔 Firebase Cloud Messaging (선택적)

### FCM 설정
- [ ] Firebase Cloud Messaging 활성화
- [ ] 앱 권한 설정
  - [ ] Android 설정
  - [ ] iOS 설정
- [ ] 서버 키 설정

### 알림 구현
- [ ] 시간표 변경 알림 구현
- [ ] 경기 결과 알림 구현
- [ ] 일반 공지 알림 구현

## 🧪 테스트 및 모니터링

### 테스트 환경
- [ ] 개발 환경 Firebase 프로젝트 설정
- [ ] 테스트 환경 Firebase 프로젝트 설정
- [ ] 프로덕션 환경 Firebase 프로젝트 설정

### 성능 모니터링
- [ ] Firebase Performance Monitoring 설정
- [ ] 주요 화면 로딩 시간 측정
- [ ] 네트워크 성능 모니터링

### 오류 모니터링
- [ ] Firebase Crashlytics 설정
- [ ] 오류 보고서 설정
- [ ] 주요 오류 알림 설정

## 🔒 보안 및 백업

### 보안 설정
- [ ] Firebase 프로젝트 멤버 관리
- [ ] API 키 제한 설정
- [ ] IP 기반 접근 제한 (선택적)

### 데이터 백업
- [ ] 정기 데이터 백업 전략 수립
- [ ] Firestore 데이터 내보내기 스크립트 작성
- [ ] 복원 절차 문서화 