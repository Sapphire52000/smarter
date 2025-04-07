# Project Progress: Smart Academy Management App

## Currently Functional Features

1. **Authentication System**
   - Email/password login
   - Google account login
   - Role-based authentication (student, teacher, parent, academyOwner)
   - User profile retrieval with role information
   - Logout functionality

2. **UI Implementation**
   - Login screen complete
   - Home screen with bottom navigation
   - Tab-based interface (Dashboard, Schedule, Classes, Students)
   - Material Design 3 theme applied

3. **Core Features**
   - Dashboard with summary statistics
   - Schedule view with calendar integration
   - Classes management interface
   - Student management with attendance tracking
   - Profile management

---

## Features in Development

1. **Role-Based Architecture**
   - Restructuring file system for role-based views
   - Creating dedicated interfaces for each user role
   - Implementing role-based routing
   - Developing appropriate permissions system

2. **Data Management**
   - Fixing Firebase compound query issues
   - Optimizing data retrieval for different roles
   - Implementing proper data visibility rules

3. **User Experience Improvements**
   - Eliminating UI redundancies
   - Enhancing error handling
   - Streamlining navigation flows

---

## Features Not Yet Developed

1. **AI-Powered Features**
   - Chat analysis for scheduling suggestions
   - Automated administrative tasks
   - Smart notifications

2. **Advanced Role-Specific Features**
   - Parent payment tracking
   - Teacher assessment tools
   - Student performance metrics
   - Academy owner analytics dashboard

3. **Extended Capabilities**
   - Offline support
   - Push notifications
   - Calendar integration with device calendars
   - Multi-language support

---

## Current Status

- **Development Stage**: Beta phase
- **Architecture**: Transitioning to role-based structure
- **Testing**: Manual testing ongoing
- **User Roles**: All user roles discovered and working (student, teacher, parent, academyOwner)

---

## Known Issues

1. **UI/UX Concerns**
   - Duplicate app bars in some views (fixed)
   - Inconsistent navigation patterns
   - Limited role-specific features

2. **Firebase Integration**
   - Compound query limitations requiring client-side filtering
   - Potential performance issues with large datasets

3. **Code Structure**
   - Need for better organization of role-specific code
   - Some ViewModels require refactoring for role-based approach

## 시간표 기능 구현 진행상황
Smartable 앱의 시간표 기능을 역할별로 분리하고 개선했습니다.

### 구현 완료
- [x] 시간표 관련 파일 구조 재구성 (역할별 분리)
- [x] 학원 관리자용 일간/주간 시간표 뷰
- [x] 학부모용 일간/주간 시간표 뷰
- [x] 선생님용 일간 시간표 뷰
- [x] 학생용 일간 시간표 뷰
- [x] 공통 컴포넌트 추출 및 최적화
- [x] 간편한 일정 생성/수정 인터페이스
- [x] 색상 선택 기능 구현
- [x] 일/주 단위 뷰 전환 기능
- [x] 현재 시간 표시 기능
- [x] 날짜 네비게이션 개선
  - [x] 싱글 탭으로 날짜 선택
  - [x] 더블 탭으로 해당 날짜 일간 뷰로 이동

### 작업 중
- [ ] 반복 일정 설정 기능
- [ ] 선생님용 주간 시간표 뷰
- [ ] 학생용 주간 시간표 뷰
- [ ] 일정 알림 기능
- [ ] 역할별 권한 관리 로직 개선

### 예정된 작업
- [ ] 학원별 일정 필터링
- [ ] 학원 운영 시간 설정 기능
- [ ] 선생님별 일정 보기 기능
- [ ] 강의실/교실별 일정 보기
- [ ] 혼잡도 표시 기능 (중복 일정 경고)
- [ ] 일정 충돌 감지 및 경고

### 해결된 이슈
- 일정 색상 선택 시 hex string과 Color 객체 간 변환 문제 해결
- 여러 위젯에서 공통 디자인 패턴 적용으로 코드 중복 제거
- initialDate 매개변수를 통한 화면 간 날짜 데이터 전달 구현
- 요일 헤더 UI 개선으로 현재 날짜 및 선택된 날짜 시각적 구분 향상

## 코드 정리 작업 진행상황

### 완료된 작업
- [x] 시간표 관련 불필요한 파일 정리
  - [x] 기존 `lib/views/schedule/academy/` 폴더 삭제
  - [x] 기존 `lib/views/schedule/parent/` 폴더 삭제
  - [x] 기존 `lib/views/schedule/teacher/` 폴더 삭제
  - [x] 기존 `lib/views/schedule/common/` 폴더 삭제
- [x] 파일 백업 작업: `backup/schedule_old/` 디렉토리에 백업 완료
- [x] 파일 구조 정리 결과 문서화: `cleanup_results.txt` 생성

### 현재 파일 구조
```
--- 역할별 시간표 ---
lib/views/academy/schedule/academy_schedule_view.dart
lib/views/academy/schedule/academy_weekly_schedule_view.dart
lib/views/academy/schedule/schedule_view.dart
lib/views/academy/schedule/components/...
lib/views/parent/schedule/schedule_view.dart
lib/views/parent/schedule/weekly_schedule_view.dart
lib/views/student/schedule/schedule_view.dart
lib/views/teacher/schedule/schedule_view.dart

--- 공통 컴포넌트 ---
lib/views/schedule/components/color_selector_widget.dart
lib/views/schedule/components/date_header_widget.dart
lib/views/schedule/components/schedule_block_widget.dart
lib/views/schedule/components/schedule_grid_widget.dart
lib/views/schedule/components/time_slots_column_widget.dart
lib/views/schedule/utils/date_utils.dart
lib/views/schedule/utils/schedule_formatter.dart