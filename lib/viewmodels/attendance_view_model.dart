import 'package:flutter/foundation.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

/// 출석 관리 상태 열거형
enum AttendanceState {
  initial, // 초기 상태
  loading, // 로딩 중
  loaded, // 로드됨
  error, // 오류 발생
}

/// 출석 관리 뷰모델 클래스
class AttendanceViewModel extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  // 상태 변수
  AttendanceState _state = AttendanceState.initial;
  List<AttendanceModel> _attendanceList = [];
  Map<String, int>? _monthlyCounts;
  int? _carriedOverSessions;
  String? _errorMessage;

  // 게터
  AttendanceState get state => _state;
  List<AttendanceModel> get attendanceList => _attendanceList;
  Map<String, int>? get monthlyCounts => _monthlyCounts;
  int? get carriedOverSessions => _carriedOverSessions;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AttendanceState.loading;

  /// 특정 수업의 출석 목록 로드
  void loadAttendanceByClass(
    String classId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _state = AttendanceState.loading;
    notifyListeners();

    try {
      _attendanceService
          .getAttendanceByClass(classId, startDate: startDate, endDate: endDate)
          .listen(
            (attendance) {
              _attendanceList = attendance;
              _state = AttendanceState.loaded;
              notifyListeners();
            },
            onError: (error) {
              _state = AttendanceState.error;
              _errorMessage = '출석 목록을 불러오는 중 오류가 발생했습니다: $error';
              notifyListeners();
            },
          );
    } catch (e) {
      _state = AttendanceState.error;
      _errorMessage = '출석 목록을 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  /// 특정 학생의 출석 목록 로드
  void loadAttendanceByStudent(
    String studentId, {
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _state = AttendanceState.loading;
    notifyListeners();

    try {
      _attendanceService
          .getAttendanceByStudent(
            studentId,
            classId: classId,
            startDate: startDate,
            endDate: endDate,
          )
          .listen(
            (attendance) {
              _attendanceList = attendance;
              _state = AttendanceState.loaded;
              notifyListeners();
            },
            onError: (error) {
              _state = AttendanceState.error;
              _errorMessage = '출석 목록을 불러오는 중 오류가 발생했습니다: $error';
              notifyListeners();
            },
          );
    } catch (e) {
      _state = AttendanceState.error;
      _errorMessage = '출석 목록을 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  /// 특정 날짜의 출석 목록 로드
  void loadAttendanceByDate(
    DateTime date, {
    String? classId,
    String? studentId,
  }) {
    _state = AttendanceState.loading;
    notifyListeners();

    try {
      _attendanceService
          .getAttendanceByDate(date, classId: classId, studentId: studentId)
          .listen(
            (attendance) {
              _attendanceList = attendance;
              _state = AttendanceState.loaded;
              notifyListeners();
            },
            onError: (error) {
              _state = AttendanceState.error;
              _errorMessage = '출석 목록을 불러오는 중 오류가 발생했습니다: $error';
              notifyListeners();
            },
          );
    } catch (e) {
      _state = AttendanceState.error;
      _errorMessage = '출석 목록을 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  /// 출석 기록 생성
  Future<bool> createAttendance({
    required String classId,
    required String studentId,
    required DateTime date,
    required AttendanceStatus status,
    String? teacherId,
    String? note,
    bool isCarriedOver = false,
  }) async {
    try {
      _state = AttendanceState.loading;
      notifyListeners();

      await _attendanceService.createAttendance(
        classId: classId,
        studentId: studentId,
        date: date,
        status: status,
        teacherId: teacherId,
        note: note,
        isCarriedOver: isCarriedOver,
      );

      _state = AttendanceState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AttendanceState.error;
      _errorMessage = '출석 기록 생성 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 출석 상태 업데이트
  Future<bool> updateAttendance({
    required String id,
    required AttendanceStatus status,
    String? note,
    bool? isCarriedOver,
  }) async {
    try {
      _state = AttendanceState.loading;
      notifyListeners();

      // 현재 출석 정보 찾기
      final existingAttendance = _attendanceList.firstWhere(
        (attendance) => attendance.id == id,
        orElse: () => throw Exception('해당 ID의 출석 기록을 찾을 수 없습니다'),
      );

      // 업데이트할 출석 정보 생성
      final updatedAttendance = existingAttendance.copyWith(
        status: status,
        note: note,
        isCarriedOver: isCarriedOver,
      );

      // 출석 정보 업데이트
      await _attendanceService.updateAttendance(updatedAttendance);

      _state = AttendanceState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AttendanceState.error;
      _errorMessage = '출석 상태 업데이트 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 출석 기록 삭제
  Future<bool> deleteAttendance(String id) async {
    try {
      _state = AttendanceState.loading;
      notifyListeners();

      await _attendanceService.deleteAttendance(id);

      _state = AttendanceState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AttendanceState.error;
      _errorMessage = '출석 기록 삭제 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 월별 출석 통계 로드
  Future<void> loadMonthlyStatistics({
    required String studentId,
    required String classId,
    required DateTime month,
  }) async {
    try {
      _state = AttendanceState.loading;
      notifyListeners();

      // 월별 출석 횟수 로드
      _monthlyCounts = await _attendanceService.getMonthlyAttendanceCount(
        studentId,
        classId,
        month,
      );

      // 이월 수업 횟수 로드
      _carriedOverSessions = await _attendanceService
          .getCarriedOverSessionCount(studentId, classId, month);

      _state = AttendanceState.loaded;
      notifyListeners();
    } catch (e) {
      _state = AttendanceState.error;
      _errorMessage = '월별 통계를 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  /// 오류 메시지 초기화
  void clearError() {
    _errorMessage = null;
    _state =
        _attendanceList.isNotEmpty
            ? AttendanceState.loaded
            : AttendanceState.initial;
    notifyListeners();
  }
}
