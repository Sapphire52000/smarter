# 시스템 패턴: Smartable

## 시스템 아키텍처
Smartable은 MVVM(Model-View-ViewModel) 아키텍처 패턴을 따릅니다:
- **모델(Model)**: 데이터 구조와 비즈니스 로직 정의 (`models` 디렉토리)
- **뷰(View)**: UI 요소와 사용자 상호작용 담당 (`views` 디렉토리)
- **뷰모델(ViewModel)**: 뷰와 모델 사이의 중개자 역할 (`viewmodels` 디렉토리)
- **서비스(Service)**: 외부 API 및 데이터 소스와의 통신 담당 (`services` 디렉토리)

## 주요 기술 결정
1. **Flutter 프레임워크**: 크로스 플랫폼 개발 지원 및 풍부한 위젯 라이브러리
2. **Firebase**: 인증, 실시간 데이터베이스 및 클라우드 스토리지
3. **Provider 패턴**: 상태 관리 및 데이터 흐름 제어
4. **비동기 프로그래밍**: Future 및 Stream을 활용한 비동기 작업 처리

## 디자인 패턴
1. **싱글톤 패턴**: 서비스 클래스에서 단일 인스턴스 보장
2. **팩토리 패턴**: 객체 생성 로직 캡슐화
3. **옵저버 패턴**: Provider를 통한 UI 업데이트
4. **리포지토리 패턴**: 데이터 소스 추상화

## 컴포넌트 관계
```
                +-------------+
                |    Views    |
                +-------------+
                       |
                       v
                +-------------+
                | ViewModels  |
                +-------------+
                       |
                       v
+-------------+  +-------------+  +--------------+
|   Models    |  |  Services   |  | Repositories |
+-------------+  +-------------+  +--------------+
                       |
                       v
                +-------------+
                |  Firebase   |
                +-------------+
```

## 주요 데이터 흐름
1. 사용자 인증:
   - LoginView → AuthViewModel → AuthService → Firebase Auth
   
2. 사용자 데이터 관리:
   - HomeView → AuthViewModel → UserService → Firestore

## 확장 전략
1. 새로운 기능 추가 시 기존 MVVM 패턴 따르기
2. 재사용 가능한 위젯 컴포넌트 개발
3. 비즈니스 로직과 UI 분리 유지
4. 기능별 서비스 모듈화 

## 시간표 관리 시스템 구조
Smartable의 시간표 관리 시스템은 역할별로 분리된 구조를 가지며, 공통 컴포넌트와 유틸리티를 재사용합니다:

### 파일 구조
```
lib/
  ├── models/
  │    └── schedule_model.dart       # 시간표 데이터 모델
  │
  ├── viewmodels/
  │    └── schedule_view_model.dart  # 시간표 관리 뷰모델
  │
  ├── views/
  │    ├── schedule/                 # 공통 시간표 컴포넌트
  │    │    ├── components/          # 재사용 가능한 UI 컴포넌트
  │    │    │    ├── date_header_widget.dart
  │    │    │    ├── schedule_block_widget.dart
  │    │    │    ├── schedule_grid_widget.dart
  │    │    │    ├── time_slots_column_widget.dart
  │    │    │    └── color_selector_widget.dart
  │    │    │
  │    │    └── utils/               # 일정 관련 유틸리티
  │    │         ├── date_utils.dart
  │    │         └── schedule_formatter.dart
  │    │
  │    ├── academy/schedule/         # 학원 관리자용 시간표
  │    │    ├── components/
  │    │    ├── schedule_view.dart   # 일간 시간표
  │    │    └── academy_weekly_schedule_view.dart # 주간 시간표
  │    │
  │    ├── teacher/schedule/         # 선생님용 시간표
  │    │    ├── components/
  │    │    └── schedule_view.dart   # 일간 시간표
  │    │
  │    ├── parent/schedule/          # 학부모용 시간표
  │    │    ├── components/
  │    │    ├── schedule_view.dart   # 일간 시간표
  │    │    └── weekly_schedule_view.dart # 주간 시간표
  │    │
  │    └── student/schedule/         # 학생용 시간표
  │         ├── components/
  │         └── schedule_view.dart   # 일간 시간표
```

### 컴포넌트 구조
1. **공통 컴포넌트** (`views/schedule/components/`):
   - `date_header_widget.dart`: 날짜 선택 및 네비게이션 헤더
   - `schedule_block_widget.dart`: 개별 일정 블록 표시
   - `schedule_grid_widget.dart`: 시간표 그리드 레이아웃
   - `time_slots_column_widget.dart`: 시간 슬롯 컬럼
   - `color_selector_widget.dart`: 일정 색상 선택기

2. **유틸리티** (`views/schedule/utils/`):
   - `date_utils.dart`: 날짜 조작 및 포맷팅
   - `schedule_formatter.dart`: 일정 데이터 포맷팅

### 역할별 기능 차이
1. **학원 관리자** (`views/academy/schedule/`):
   - 모든 일정 생성, 수정, 삭제 권한
   - 주간/일간 뷰 모두 제공
   - 일정 색상 변경 및 상세 설정

2. **선생님** (`views/teacher/schedule/`):
   - 담당 반 일정 조회 및 관리
   - 자신의 일정 생성, 수정 가능

3. **학부모** (`views/parent/schedule/`):
   - 자녀 일정 조회 전용
   - 주간/일간 뷰 모두 제공
   - 상세 설명 및 위치 정보 확인

4. **학생** (`views/student/schedule/`):
   - 자신의 일정 조회 전용
   - 상세 설명 및 위치 정보 확인

### 데이터 흐름
```
User Interaction → View → ScheduleViewModel → ScheduleService → Firebase
```

1. 사용자가 일정 관련 액션 수행 (생성, 수정, 삭제, 조회)
2. View는 액션을 ViewModel에 전달
3. ViewModel은 비즈니스 로직 처리 후 Service를 통해 데이터 저장/조회
4. 데이터 변경 시 ViewModel은 View에 알림 전송
5. View는 새로운 데이터로 UI 업데이트 