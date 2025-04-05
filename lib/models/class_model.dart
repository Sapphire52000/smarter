import 'package:cloud_firestore/cloud_firestore.dart';

/// 요일 정의
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// 수업 상태 정의
enum ClassStatus {
  active, // 활성 상태
  cancelled, // 취소됨
  completed, // 완료됨
  onHold, // 일시 중지
}

/// 수업 모델 클래스
class ClassModel {
  final String id;
  final String name;
  final String? academyId;
  final String? teacherId;
  final String? subject;
  final String? description;
  final int maxStudents;
  final List<String>? enrolledStudentIds;
  final int sessionsPerMonth; // 한 달 수업 횟수
  final Map<DayOfWeek, TimeOfDay>? schedule; // 요일별 수업 시간
  final DateTime startDate;
  final DateTime? endDate;
  final ClassStatus status;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassModel({
    required this.id,
    required this.name,
    this.academyId,
    this.teacherId,
    this.subject,
    this.description,
    required this.maxStudents,
    this.enrolledStudentIds,
    required this.sessionsPerMonth,
    this.schedule,
    required this.startDate,
    this.endDate,
    required this.status,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore 문서에서 수업 모델 생성
  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // 일정 변환
    Map<DayOfWeek, TimeOfDay>? scheduleMap;
    if (data['schedule'] != null) {
      scheduleMap = {};
      final Map<String, dynamic> rawSchedule = Map<String, dynamic>.from(
        data['schedule'],
      );

      rawSchedule.forEach((key, value) {
        final day = _parseDayOfWeek(key);
        final timeString = value as String; // "HH:MM" 형식
        final parts = timeString.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        scheduleMap![day] = TimeOfDay(hour: hour, minute: minute);
      });
    }

    return ClassModel(
      id: doc.id,
      name: data['name'] ?? '',
      academyId: data['academyId'],
      teacherId: data['teacherId'],
      subject: data['subject'],
      description: data['description'],
      maxStudents: data['maxStudents'] ?? 0,
      enrolledStudentIds:
          data['enrolledStudentIds'] != null
              ? List<String>.from(data['enrolledStudentIds'])
              : null,
      sessionsPerMonth: data['sessionsPerMonth'] ?? 0,
      schedule: scheduleMap,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate:
          data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
      status: _parseClassStatus(data['status'] ?? 'active'),
      additionalInfo: data['additionalInfo'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// 문자열을 DayOfWeek enum으로 변환
  static DayOfWeek _parseDayOfWeek(String dayStr) {
    switch (dayStr) {
      case 'monday':
        return DayOfWeek.monday;
      case 'tuesday':
        return DayOfWeek.tuesday;
      case 'wednesday':
        return DayOfWeek.wednesday;
      case 'thursday':
        return DayOfWeek.thursday;
      case 'friday':
        return DayOfWeek.friday;
      case 'saturday':
        return DayOfWeek.saturday;
      case 'sunday':
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }

  /// 문자열을 ClassStatus enum으로 변환
  static ClassStatus _parseClassStatus(String statusStr) {
    switch (statusStr) {
      case 'active':
        return ClassStatus.active;
      case 'cancelled':
        return ClassStatus.cancelled;
      case 'completed':
        return ClassStatus.completed;
      case 'onHold':
        return ClassStatus.onHold;
      default:
        return ClassStatus.active;
    }
  }

  /// Firestore에 저장하기 위한 Map 변환
  Map<String, dynamic> toMap() {
    // 일정 변환
    Map<String, String>? scheduleMap;
    if (schedule != null) {
      scheduleMap = {};
      schedule!.forEach((day, time) {
        final dayStr = day.toString().split('.').last;
        final timeStr =
            '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        scheduleMap![dayStr] = timeStr;
      });
    }

    return {
      'name': name,
      'academyId': academyId,
      'teacherId': teacherId,
      'subject': subject,
      'description': description,
      'maxStudents': maxStudents,
      'enrolledStudentIds': enrolledStudentIds,
      'sessionsPerMonth': sessionsPerMonth,
      'schedule': scheduleMap,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status.toString().split('.').last,
      'additionalInfo': additionalInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 수업 데이터 업데이트
  ClassModel copyWith({
    String? name,
    String? academyId,
    String? teacherId,
    String? subject,
    String? description,
    int? maxStudents,
    List<String>? enrolledStudentIds,
    int? sessionsPerMonth,
    Map<DayOfWeek, TimeOfDay>? schedule,
    DateTime? startDate,
    DateTime? endDate,
    ClassStatus? status,
    Map<String, dynamic>? additionalInfo,
  }) {
    return ClassModel(
      id: id,
      name: name ?? this.name,
      academyId: academyId ?? this.academyId,
      teacherId: teacherId ?? this.teacherId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      maxStudents: maxStudents ?? this.maxStudents,
      enrolledStudentIds: enrolledStudentIds ?? this.enrolledStudentIds,
      sessionsPerMonth: sessionsPerMonth ?? this.sessionsPerMonth,
      schedule: schedule ?? this.schedule,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() => 'ClassModel(id: $id, name: $name, status: $status)';
}

/// 시간을 표현하는 클래스
class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() => '$hour:${minute.toString().padLeft(2, '0')}';
}
