import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// 인증 상태 열거형
enum AuthStatus {
  initial, // 초기 상태
  loading, // 로딩 중
  authenticated, // 인증됨
  unauthenticated, // 인증되지 않음
  error, // 오류 발생
}

/// 인증 뷰모델 클래스
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // 상태 변수
  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  UserModel? _user;
  String? _errorMessage;

  // 게터
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // 역할 관련 게터
  bool get isSuperAdmin => _user?.role == UserRole.superAdmin;
  bool get isAcademyOwner => _user?.role == UserRole.academyOwner;
  bool get isTeacher => _user?.role == UserRole.teacher;
  bool get isParent => _user?.role == UserRole.parent;
  bool get isStudent => _user?.role == UserRole.student;

  /// 생성자 - 인증 상태 변화 감지 설정
  AuthViewModel() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Firebase 인증 상태 변경 처리
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;

    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // Firestore에서 사용자 정보 로드
      UserModel? userModel = await _userService.getUserById(firebaseUser.uid);

      // 사용자 정보가 없으면 신규 사용자로 생성
      userModel ??= await _userService.createUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '사용자',
        photoURL: firebaseUser.photoURL,
      );

      _user = userModel;
      _status = AuthStatus.authenticated;
    } catch (e) {
      print('사용자 정보 로드 오류: $e');
      _status = AuthStatus.error;
      _errorMessage = '사용자 정보를 불러오는 중 오류가 발생했습니다';
      // 기본 모델이라도 생성 (오류 복구용)
      _user = UserModel.initial(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '사용자',
        photoURL: firebaseUser.photoURL,
      );
    }

    notifyListeners();
  }

  /// 구글 로그인
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading();
      final error = await _authService.signInWithGoogle();

      if (error != null) {
        _setError(error);
        return false;
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// 애플 로그인 (추후 구현)
  Future<bool> signInWithApple() async {
    try {
      _setLoading();
      // 애플 로그인 구현 예정
      _setError('애플 로그인 기능은 아직 구현되지 않았습니다.');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 사용자 역할 업데이트
  Future<void> updateUserRole(UserRole role) async {
    try {
      if (_user == null || _firebaseUser == null) return;

      _setLoading();
      final updatedUser = await _userService.updateUserRole(_user!.id, role);
      _user = updatedUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _setError('역할 업데이트 오류: ${e.toString()}');
    }
  }

  /// 사용자 학원 연결
  Future<void> updateUserAcademy(String academyId) async {
    try {
      if (_user == null || _firebaseUser == null) return;

      _setLoading();
      final updatedUser = await _userService.updateUserAcademy(
        _user!.id,
        academyId,
      );
      _user = updatedUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _setError('학원 업데이트 오류: ${e.toString()}');
    }
  }

  /// 사용자 역할 초기화
  Future<void> resetUserRole() async {
    try {
      if (_user == null || _firebaseUser == null) return;

      _setLoading();
      // 역할을 null로 설정하여 초기화
      final updatedUser = _user!.copyWith(role: null, academyId: null);
      await _userService.updateUser(updatedUser);
      _user = updatedUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _setError('역할 초기화 오류: ${e.toString()}');
    }
  }

  // 내부 상태 관리 메서드들
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status =
        _firebaseUser != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
    notifyListeners();
  }
}
