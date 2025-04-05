import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

/// 학생 관리 상태 열거형
enum StudentState {
  initial, // 초기 상태
  loading, // 로딩 중
  loaded, // 로드됨
  error, // 오류 발생
}

/// 학생 관리 뷰모델 클래스
class StudentViewModel extends ChangeNotifier {
  final StudentService _studentService = StudentService();

  // 상태 변수
  StudentState _state = StudentState.initial;
  List<StudentModel> _students = [];
  StudentModel? _selectedStudent;
  String? _errorMessage;
  String? _academyId;

  // 게터
  StudentState get state => _state;
  List<StudentModel> get students => _students;
  StudentModel? get selectedStudent => _selectedStudent;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == StudentState.loading;

  /// 학원별 학생 목록 로드
  void loadStudents({String? academyId}) {
    _state = StudentState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _studentService
          .getStudents(academyId: academyId)
          .listen(
            (students) {
              _students = students;
              _state = StudentState.loaded;
              notifyListeners();
            },
            onError: (error) {
              _state = StudentState.error;
              _errorMessage = '학생 목록을 불러오는 중 오류가 발생했습니다: $error';
              print('학생 목록 불러오기 에러: $error');
              notifyListeners();
            },
          );
    } catch (e) {
      _state = StudentState.error;
      _errorMessage = '학생 목록을 불러오는 중 오류가 발생했습니다: $e';
      print('학생 목록 불러오기 에러: $e');
      notifyListeners();
    }
  }

  /// 학생 선택
  void selectStudent(StudentModel student) {
    _selectedStudent = student;
    notifyListeners();
  }

  /// 학생 ID로 학생 정보 로드
  Future<void> loadStudentById(String id) async {
    try {
      _state = StudentState.loading;
      notifyListeners();

      final student = await _studentService.getStudentById(id);

      if (student != null) {
        _selectedStudent = student;
        _state = StudentState.loaded;
      } else {
        _state = StudentState.error;
        _errorMessage = '해당 ID의 학생을 찾을 수 없습니다';
      }

      notifyListeners();
    } catch (e) {
      _state = StudentState.error;
      _errorMessage = '학생 정보를 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  /// 새 학생 생성
  Future<bool> createStudent({
    required String name,
    required int age,
    String? parentId,
    String? grade,
    String? contactNumber,
  }) async {
    try {
      _state = StudentState.loading;
      notifyListeners();

      await _studentService.createStudent(
        name: name,
        age: age,
        parentId: parentId,
        academyId: _academyId,
        grade: grade,
        contactNumber: contactNumber,
      );

      _state = StudentState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = StudentState.error;
      _errorMessage = '학생 생성 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 학생 정보 업데이트
  Future<bool> updateStudent({
    required String id,
    String? name,
    int? age,
    String? parentId,
    String? grade,
    String? contactNumber,
    List<String>? enrolledClasses,
  }) async {
    try {
      _state = StudentState.loading;
      notifyListeners();

      // 현재 학생 정보 로드
      final currentStudent = await _studentService.getStudentById(id);

      if (currentStudent == null) {
        _state = StudentState.error;
        _errorMessage = '학생 정보를 찾을 수 없습니다';
        notifyListeners();
        return false;
      }

      // 업데이트할 학생 정보 생성
      final updatedStudent = currentStudent.copyWith(
        name: name,
        age: age,
        parentId: parentId,
        grade: grade,
        contactNumber: contactNumber,
        enrolledClasses: enrolledClasses,
      );

      // 학생 정보 업데이트
      await _studentService.updateStudent(updatedStudent);

      if (_selectedStudent?.id == id) {
        _selectedStudent = updatedStudent;
      }

      _state = StudentState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = StudentState.error;
      _errorMessage = '학생 정보 업데이트 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 학생 삭제
  Future<bool> deleteStudent(String id) async {
    try {
      _state = StudentState.loading;
      notifyListeners();

      await _studentService.deleteStudent(id);

      if (_selectedStudent?.id == id) {
        _selectedStudent = null;
      }

      _state = StudentState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = StudentState.error;
      _errorMessage = '학생 삭제 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 수업에 학생 등록
  Future<bool> enrollStudentInClass(String studentId, String classId) async {
    try {
      _state = StudentState.loading;
      notifyListeners();

      await _studentService.enrollStudentInClass(
        studentId: studentId,
        classId: classId,
      );

      _state = StudentState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = StudentState.error;
      _errorMessage = '학생 수업 등록 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 오류 메시지 초기화
  void clearError() {
    _errorMessage = null;
    _state = _students.isNotEmpty ? StudentState.loaded : StudentState.initial;
    notifyListeners();
  }
}
