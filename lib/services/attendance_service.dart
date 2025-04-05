import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

/// 출석 데이터 관리 서비스
class AttendanceService {
  final CollectionReference _attendanceCollection = FirebaseFirestore.instance
      .collection('attendance');

  /// 특정 수업의 출석 목록 조회
  Stream<List<AttendanceModel>> getAttendanceByClass(
    String classId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // 기본 조건으로 수업 ID만 사용
    Query query = _attendanceCollection.where('classId', isEqualTo: classId);

    // 시작 날짜와 종료 날짜가 모두 있는 경우 날짜 필터링은 메모리에서 수행
    return query.snapshots().map((snapshot) {
      List<AttendanceModel> attendanceList =
          snapshot.docs
              .map((doc) => AttendanceModel.fromFirestore(doc))
              .toList();

      // 메모리에서 날짜 필터링
      if (startDate != null) {
        attendanceList =
            attendanceList
                .where(
                  (attendance) =>
                      attendance.date.isAfter(startDate) ||
                      attendance.date.isAtSameMomentAs(startDate),
                )
                .toList();
      }

      if (endDate != null) {
        attendanceList =
            attendanceList
                .where(
                  (attendance) =>
                      attendance.date.isBefore(endDate) ||
                      attendance.date.isAtSameMomentAs(endDate),
                )
                .toList();
      }

      return attendanceList;
    });
  }

  /// 특정 학생의 출석 목록 조회
  Stream<List<AttendanceModel>> getAttendanceByStudent(
    String studentId, {
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // 기본 조건으로 학생 ID만 사용
    Query query = _attendanceCollection.where(
      'studentId',
      isEqualTo: studentId,
    );

    return query.snapshots().map((snapshot) {
      List<AttendanceModel> attendanceList =
          snapshot.docs
              .map((doc) => AttendanceModel.fromFirestore(doc))
              .toList();

      // 메모리에서 추가 필터링
      if (classId != null) {
        attendanceList =
            attendanceList
                .where((attendance) => attendance.classId == classId)
                .toList();
      }

      if (startDate != null) {
        attendanceList =
            attendanceList
                .where(
                  (attendance) =>
                      attendance.date.isAfter(startDate) ||
                      attendance.date.isAtSameMomentAs(startDate),
                )
                .toList();
      }

      if (endDate != null) {
        attendanceList =
            attendanceList
                .where(
                  (attendance) =>
                      attendance.date.isBefore(endDate) ||
                      attendance.date.isAtSameMomentAs(endDate),
                )
                .toList();
      }

      return attendanceList;
    });
  }

  /// 특정 날짜의 출석 목록 조회
  Stream<List<AttendanceModel>> getAttendanceByDate(
    DateTime date, {
    String? classId,
    String? studentId,
  }) {
    // 날짜를 기준으로 timestamp 범위 생성
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    Query query = _attendanceCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));

    return query.snapshots().map((snapshot) {
      List<AttendanceModel> attendanceList =
          snapshot.docs
              .map((doc) => AttendanceModel.fromFirestore(doc))
              .toList();

      // 메모리에서 추가 필터링
      if (classId != null) {
        attendanceList =
            attendanceList
                .where((attendance) => attendance.classId == classId)
                .toList();
      }

      if (studentId != null) {
        attendanceList =
            attendanceList
                .where((attendance) => attendance.studentId == studentId)
                .toList();
      }

      return attendanceList;
    });
  }

  /// 출석 기록 생성
  Future<AttendanceModel> createAttendance({
    required String classId,
    required String studentId,
    required DateTime date,
    required AttendanceStatus status,
    String? teacherId,
    String? note,
    bool isCarriedOver = false,
  }) async {
    try {
      final newAttendance = {
        'classId': classId,
        'studentId': studentId,
        'date': Timestamp.fromDate(date),
        'status': status.toString().split('.').last,
        'teacherId': teacherId,
        'note': note,
        'isCarriedOver': isCarriedOver,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final docRef = await _attendanceCollection.add(newAttendance);
      final docSnapshot = await docRef.get();

      return AttendanceModel.fromFirestore(docSnapshot);
    } catch (e) {
      print('출석 기록 생성 오류: $e');
      rethrow;
    }
  }

  /// 출석 상태 업데이트
  Future<AttendanceModel> updateAttendance(AttendanceModel attendance) async {
    try {
      await _attendanceCollection.doc(attendance.id).update(attendance.toMap());

      final docSnapshot = await _attendanceCollection.doc(attendance.id).get();
      return AttendanceModel.fromFirestore(docSnapshot);
    } catch (e) {
      print('출석 상태 업데이트 오류: $e');
      rethrow;
    }
  }

  /// 출석 기록 삭제
  Future<void> deleteAttendance(String id) async {
    try {
      await _attendanceCollection.doc(id).delete();
    } catch (e) {
      print('출석 기록 삭제 오류: $e');
      rethrow;
    }
  }

  /// 월별 학생의 출석 횟수 계산
  Future<Map<String, int>> getMonthlyAttendanceCount(
    String studentId,
    String classId,
    DateTime month,
  ) async {
    try {
      // 월의 시작과 끝 날짜 설정
      final firstDayOfMonth = DateTime(month.year, month.month, 1);
      final lastDayOfMonth = DateTime(
        month.year,
        month.month + 1,
        0,
        23,
        59,
        59,
      );

      final snapshot =
          await _attendanceCollection
              .where('studentId', isEqualTo: studentId)
              .where('classId', isEqualTo: classId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
              )
              .where(
                'date',
                isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
              )
              .get();

      // 각 상태별 출석 횟수
      final Map<String, int> counts = {
        'present': 0,
        'absent': 0,
        'late': 0,
        'excused': 0,
        'cancelled': 0,
        'makeup': 0,
        'total': 0,
      };

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String;

        if (counts.containsKey(status)) {
          counts[status] = counts[status]! + 1;
        }

        counts['total'] = counts['total']! + 1;
      }

      return counts;
    } catch (e) {
      print('월별 출석 횟수 계산 오류: $e');
      rethrow;
    }
  }

  /// 이월 수업 횟수 계산
  Future<int> getCarriedOverSessionCount(
    String studentId,
    String classId,
    DateTime month,
  ) async {
    try {
      // 월의 시작과 끝 날짜 설정
      final firstDayOfMonth = DateTime(month.year, month.month, 1);
      final lastDayOfMonth = DateTime(
        month.year,
        month.month + 1,
        0,
        23,
        59,
        59,
      );

      final snapshot =
          await _attendanceCollection
              .where('studentId', isEqualTo: studentId)
              .where('classId', isEqualTo: classId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
              )
              .where(
                'date',
                isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
              )
              .where('isCarriedOver', isEqualTo: true)
              .get();

      return snapshot.docs.length;
    } catch (e) {
      print('이월 수업 횟수 계산 오류: $e');
      rethrow;
    }
  }
}
