# Active Context: Smart Academy Management App

## Current Focus  
The project is entering a new phase, shifting from a single-interface model to a role-based UI architecture. We're restructuring the app to provide different experiences for academy owners, teachers, parents, and students, with appropriate permissions and features for each role.

## Recent Updates  
1. Implemented basic tab structure with Dashboard, Schedule, Classes, and Students tabs
2. Fixed Firebase compound query issues in AttendanceService
3. Added time scheduling features and calendar integration
4. Restructured UI to eliminate duplicate app bars
5. Enhanced error handling in ViewModels
6. Added attendance tracking in student management section

## Next Steps  
1. Reorganize file structure for role-based views
2. Implement role-based routing in main.dart
3. Create separate home screens for each user role
4. Develop parent-specific views (children tracking, attendance, payments)
5. Develop teacher-specific views (class management, student attendance)
6. Enhance authentication with role-specific permissions
7. Apply consistent UI components across role-specific interfaces
8. 시간표 뷰 기능 개선
   - 모든 역할별 주간 시간표 뷰 구현 완료
   - 일정 관리 기능 사용성 향상
   - 일정 검색 및 필터링 기능 추가

## New Architectural Plan
The app will be restructured with role-based views:

```
lib/
  ├── views/
  │    ├── common/      # Shared components (login, profile)
  │    ├── academy/     # Academy owner views
  │    ├── parent/      # Parent views
  │    ├── teacher/     # Teacher views
  │    └── student/     # Student views (if needed)
```

This allows for specialized interfaces while maintaining shared business logic through common ViewModels and Services.

## Current User Role Discovery
Current user authentication is working and retrieving roles correctly:
- User roles: student, teacher, parent, academyOwner, superAdmin
- Role-based routing needs to be implemented
- Firebase currently returns user information including role

## Technical Challenges  
1. Maintaining consistent data access across different role views
2. Implementing appropriate data visibility and permissions
3. Sharing common UI components while providing role-specific features
4. Ensuring proper navigation flows for different user types
5. Handling transitions between roles (if a user has multiple roles)

## Current Priorities  
1. Complete the role-based architecture plan
2. Reorganize the file structure
3. Implement basic screens for each role
4. Ensure consistent UI and UX across all user types
5. 시간표 기능 안정화
   - 각 역할별 시간표 뷰 테스트 및 버그 수정
   - 색상 선택 및 일정 관리 UX 개선
   - 시간표 관련 성능 최적화

## 시간표 기능 구현 현황
시간표 관리 시스템이 역할 기반으로 재구성되었습니다:

1. **구현 완료된 기능**
   - 학원 관리자용 일간/주간 시간표 뷰
   - 학부모용 일간/주간 시간표 뷰 
   - 선생님용 일간 시간표 뷰
   - 학생용 일간 시간표 뷰
   - 일정 생성, 수정, 삭제 (권한에 따라 차등 적용)
   - 색상 선택 기능
   - 날짜 네비게이션 (이전/다음/오늘)

2. **진행 중인 기능**
   - 일정 검색 및 필터링
   - 선생님용 주간 시간표 뷰
   - 학생용 주간 시간표 뷰
   - 학부모용 자녀별 시간표 필터링

3. **개선 필요 사항**
   - 역할에 따른 권한 관리 세분화
   - 반복 일정 설정 기능
   - 알림 기능 통합
   - 성능 최적화 (특히 대량의 일정 로딩 시)