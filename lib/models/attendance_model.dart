import 'package:cloud_firestore/cloud_firestore.dart';

/// 출석 상태 정의
enum AttendanceStatus {
  present, // 출석
  absent, // 결석
  late, // 지각
  excused, // 사유있는 결석
  cancelled, // 수업 취소
  makeup, // 보충 수업
}

/// 출석 모델 클래스
class AttendanceModel {
  final String id;
  final String classId;
  final String studentId;
  final DateTime date;
  final AttendanceStatus status;
  final String? teacherId;
  final String? note;
  final bool isCarriedOver; // 다음 달로 이월 여부
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceModel({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.date,
    required this.status,
    this.teacherId,
    this.note,
    required this.isCarriedOver,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore 문서에서 출석 모델 생성
  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AttendanceModel(
      id: doc.id,
      classId: data['classId'] ?? '',
      studentId: data['studentId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: _parseAttendanceStatus(data['status'] ?? 'absent'),
      teacherId: data['teacherId'],
      note: data['note'],
      isCarriedOver: data['isCarriedOver'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// 문자열을 AttendanceStatus enum으로 변환
  static AttendanceStatus _parseAttendanceStatus(String statusStr) {
    switch (statusStr) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      case 'cancelled':
        return AttendanceStatus.cancelled;
      case 'makeup':
        return AttendanceStatus.makeup;
      default:
        return AttendanceStatus.absent;
    }
  }

  /// Firestore에 저장하기 위한 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'status': status.toString().split('.').last,
      'teacherId': teacherId,
      'note': note,
      'isCarriedOver': isCarriedOver,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 출석 데이터 업데이트
  AttendanceModel copyWith({
    String? classId,
    String? studentId,
    DateTime? date,
    AttendanceStatus? status,
    String? teacherId,
    String? note,
    bool? isCarriedOver,
  }) {
    return AttendanceModel(
      id: id,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
      teacherId: teacherId ?? this.teacherId,
      note: note ?? this.note,
      isCarriedOver: isCarriedOver ?? this.isCarriedOver,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() => 'AttendanceModel(id: $id, date: $date, status: $status)';
}
