import 'package:flutter/foundation.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';

/// 수업 관리 상태 열거형
enum ClassState {
  initial, // 초기 상태
  loading, // 로딩 중
  loaded, // 로드됨
  error, // 오류 발생
}

/// 수업 관리 뷰모델 클래스
class ClassViewModel extends ChangeNotifier {
  final ClassService _classService = ClassService();

  // 상태 변수
  ClassState _state = ClassState.initial;
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  String? _errorMessage;
  String? _academyId;

  // 게터
  ClassState get state => _state;
  List<ClassModel> get classes => _classes;
  ClassModel? get selectedClass => _selectedClass;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ClassState.loading;

  /// 학원별 수업 목록 로드
  void loadClasses({String? academyId, String? teacherId}) {
    _state = ClassState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _classService
          .getClasses(academyId: academyId, teacherId: teacherId)
          .listen(
            (classes) {
              _classes = classes;
              _state = ClassState.loaded;
              notifyListeners();
            },
            onError: (error) {
              _state = ClassState.error;
              _errorMessage = '수업 목록을 불러오는 중 오류가 발생했습니다: $error';
              print('수업 목록 불러오기 에러: $error');
              notifyListeners();
            },
          );
    } catch (e) {
      _state = ClassState.error;
      _errorMessage = '수업 목록을 불러오는 중 오류가 발생했습니다: $e';
      print('수업 목록 불러오기 예외: $e');
      notifyListeners();
    }
  }

  /// 학생이 등록된 수업 목록 로드
  void loadClassesByStudentId(String studentId) {
    _state = ClassState.loading;
    notifyListeners();

    try {
      _classService
          .getClassesByStudentId(studentId)
          .listen(
            (classes) {
              _classes = classes;
              _state = ClassState.loaded;
              notifyListeners();
            },
            onError: (error) {
              _state = ClassState.error;
              _errorMessage = '수업 목록을 불러오는 중 오류가 발생했습니다: $error';
              notifyListeners();
            },
          );
    } catch (e) {
      _state = ClassState.error;
      _errorMessage = '수업 목록을 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  /// 수업 선택
  void selectClass(ClassModel classModel) {
    _selectedClass = classModel;
    notifyListeners();
  }

  /// 수업 ID로 수업 정보 로드
  Future<void> loadClassById(String id) async {
    try {
      _state = ClassState.loading;
      notifyListeners();

      final classModel = await _classService.getClassById(id);

      if (classModel != null) {
        _selectedClass = classModel;
        _state = ClassState.loaded;
      } else {
        _state = ClassState.error;
        _errorMessage = '해당 ID의 수업을 찾을 수 없습니다';
      }

      notifyListeners();
    } catch (e) {
      _state = ClassState.error;
      _errorMessage = '수업 정보를 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  /// 새 수업 생성
  Future<bool> createClass({
    required String name,
    String? teacherId,
    String? subject,
    String? description,
    required int maxStudents,
    required int sessionsPerMonth,
    Map<DayOfWeek, TimeOfDay>? schedule,
    required DateTime startDate,
    DateTime? endDate,
    ClassStatus status = ClassStatus.active,
  }) async {
    try {
      _state = ClassState.loading;
      notifyListeners();

      await _classService.createClass(
        name: name,
        academyId: _academyId,
        teacherId: teacherId,
        subject: subject,
        description: description,
        maxStudents: maxStudents,
        sessionsPerMonth: sessionsPerMonth,
        schedule: schedule,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );

      _state = ClassState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ClassState.error;
      _errorMessage = '수업 생성 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 수업 정보 업데이트
  Future<bool> updateClass({
    required String id,
    String? name,
    String? teacherId,
    String? subject,
    String? description,
    int? maxStudents,
    int? sessionsPerMonth,
    Map<DayOfWeek, TimeOfDay>? schedule,
    DateTime? startDate,
    DateTime? endDate,
    ClassStatus? status,
  }) async {
    try {
      _state = ClassState.loading;
      notifyListeners();

      // 현재 수업 정보 로드
      final currentClass = await _classService.getClassById(id);

      if (currentClass == null) {
        _state = ClassState.error;
        _errorMessage = '수업 정보를 찾을 수 없습니다';
        notifyListeners();
        return false;
      }

      // 업데이트할 수업 정보 생성
      final updatedClass = currentClass.copyWith(
        name: name,
        teacherId: teacherId,
        subject: subject,
        description: description,
        maxStudents: maxStudents,
        sessionsPerMonth: sessionsPerMonth,
        schedule: schedule,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );

      // 수업 정보 업데이트
      await _classService.updateClass(updatedClass);

      if (_selectedClass?.id == id) {
        _selectedClass = updatedClass;
      }

      _state = ClassState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ClassState.error;
      _errorMessage = '수업 정보 업데이트 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 수업에 학생 등록
  Future<bool> enrollStudent(String classId, String studentId) async {
    try {
      _state = ClassState.loading;
      notifyListeners();

      await _classService.enrollStudentInClass(
        classId: classId,
        studentId: studentId,
      );

      _state = ClassState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ClassState.error;
      _errorMessage = '학생 등록 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 수업에서 학생 제거
  Future<bool> removeStudent(String classId, String studentId) async {
    try {
      _state = ClassState.loading;
      notifyListeners();

      await _classService.removeStudentFromClass(
        classId: classId,
        studentId: studentId,
      );

      _state = ClassState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ClassState.error;
      _errorMessage = '학생 제거 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 수업 삭제
  Future<bool> deleteClass(String id) async {
    try {
      _state = ClassState.loading;
      notifyListeners();

      await _classService.deleteClass(id);

      if (_selectedClass?.id == id) {
        _selectedClass = null;
      }

      _state = ClassState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ClassState.error;
      _errorMessage = '수업 삭제 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 오류 메시지 초기화
  void clearError() {
    _errorMessage = null;
    _state = _classes.isNotEmpty ? ClassState.loaded : ClassState.initial;
    notifyListeners();
  }
}
