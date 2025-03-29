# 📊 데이터 모델 체크리스트

## 🧭 모델 설계 원칙
- [ ] 모든 모델은 JSON 직렬화/역직렬화 지원
- [ ] 필드는 nullable로 설정하여 유연성 확보
- [ ] 모든 모델에 toString() 메서드 구현
- [ ] 모델 간 관계 명확히 설계
- [ ] Firebase 데이터 구조와 일치하는 설계

## 🧑‍🎓 사용자 관련 모델

### UserModel
- [ ] 기본 사용자 정보 모델 구현
  ```dart
  class UserModel {
    String? uid;
    String? name;
    String? email;
    String? photoUrl;
    UserRole role; // enum으로 정의
    // ...
  }
  ```

### StudentModel
- [ ] 학생 정보 모델 구현
  ```dart
  class StudentModel extends UserModel {
    String? grade;
    String? contactNumber;
    DateTime? registerDate;
    // ...
  }
  ```

### CoachModel
- [ ] 코치 정보 모델 구현
  ```dart
  class CoachModel extends UserModel {
    String? speciality;
    List<String>? assignedStudents;
    // ...
  }
  ```

### AdminModel
- [ ] 관리자 정보 모델 구현
  ```dart
  class AdminModel extends UserModel {
    List<String>? permissions;
    // ...
  }
  ```

## 📅 출석 및 시간표 모델

### AttendanceModel
- [ ] 출석 기록 모델 구현
  ```dart
  class AttendanceModel {
    String? studentId;
    String? studentName;
    Map<String, bool>? dates; // 날짜별 출석 여부
    int? totalAttendance;
    // ...
  }
  ```

### ScheduleItemModel
- [ ] 시간표 항목 모델 구현
  ```dart
  class ScheduleItemModel {
    String? date;
    String? time;
    String? studentId;
    String? studentName;
    String? coachId;
    String? coachName;
    bool? isCompleted;
    // ...
  }
  ```

### ScheduleModel
- [ ] 전체 시간표 모델 구현
  ```dart
  class ScheduleModel {
    String? coachId;
    String? coachName;
    List<ScheduleItemModel>? scheduleItems;
    // ...
  }
  ```

## 🏓 경기 관련 모델

### ScoreboardModel
- [ ] 실시간 점수판 모델 구현
  ```dart
  class ScoreboardModel {
    String? tableId;
    String? player1;
    String? player2;
    int score1;
    int score2;
    GameStatus status; // enum으로 정의
    // ...
  }
  ```

### MatchModel
- [ ] 경기 기록 모델 구현
  ```dart
  class MatchModel {
    String? matchId;
    String? tableId;
    DateTime? timestamp;
    String? player1;
    String? player2;
    int? score1;
    int? score2;
    String? winner;
    // ...
  }
  ```

## 📊 AI 분석 모델

### BallSpeedModel
- [ ] 공 속도 데이터 모델
  ```dart
  class BallSpeedModel {
    String? time;
    double? speed;
    // ...
  }
  ```

### HitLocationModel
- [ ] 타구 위치 데이터 모델
  ```dart
  class HitLocationModel {
    String? player;
    double? x;
    double? y;
    // ...
  }
  ```

### AnalysisModel
- [ ] 종합 분석 결과 모델
  ```dart
  class AnalysisModel {
    String? matchId;
    String? player1;
    String? player2;
    List<BallSpeedModel>? ballSpeeds;
    List<HitLocationModel>? hitLocations;
    Map<String, dynamic>? statistics; // 추가 통계 데이터
    // ...
  }
  ```

## 🔄 유틸리티 모델

### ApiResponseModel
- [ ] API 응답 처리 공통 모델
  ```dart
  class ApiResponseModel<T> {
    bool success;
    String? message;
    T? data;
    // ...
  }
  ```

### NotificationModel
- [ ] 알림 데이터 모델
  ```dart
  class NotificationModel {
    String? id;
    String? title;
    String? body;
    DateTime? timestamp;
    String? targetUserId;
    NotificationType type; // enum으로 정의
    Map<String, dynamic>? data;
    bool? isRead;
    // ...
  }
  ```

## 🧰 Enum 및 상수 정의

### 열거형(Enum) 정의
- [ ] 사용자 역할 정의
  ```dart
  enum UserRole { student, coach, admin }
  ```
- [ ] 게임 상태 정의
  ```dart
  enum GameStatus { notStarted, inProgress, finished }
  ```
- [ ] 알림 유형 정의
  ```dart
  enum NotificationType { schedule, match, attendance, system }
  ```

### JSON 변환 유틸리티
- [ ] fromJson 및 toJson 헬퍼 함수
  ```dart
  T fromJson<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return fromJsonT(json);
  }
  ```

## 📦 확장성 및 리팩토링

### 최적화 작업
- [ ] 모델 상속 구조 확인 및 최적화
- [ ] 중복 코드 제거 및 공통 기능 추출
- [ ] 필드명 일관성 유지 및 표준화

### 테스트
- [ ] 각 모델 직렬화/역직렬화 테스트
- [ ] 모델 변환 에지 케이스 테스트 (null 값 등)
- [ ] Firebase 데이터 연동 테스트 