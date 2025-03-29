import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

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

  /// 생성자 - 인증 상태 변화 감지 설정
  AuthViewModel() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Firebase 인증 상태 변경 처리
  void _onAuthStateChanged(User? firebaseUser) {
    _firebaseUser = firebaseUser;

    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      _status = AuthStatus.authenticated;
      // 기본적으로 유저 모델 생성 (Firestore에서 가져오는 로직은 추후 추가)
      _user = UserModel.fromFirebaseUser(firebaseUser);
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

  /// 사용자 역할 업데이트 (Firestore 연동 예정)
  Future<void> updateUserRole(UserRole role) async {
    // Firestore 연동 코드는 추후 구현
    // 현재는 로컬에서만 업데이트
    if (_user != null) {
      _user = _user!.copyWith(role: role);
      notifyListeners();
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
