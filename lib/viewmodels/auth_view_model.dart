import 'dart:io';
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
  bool _isUpdatingProfile = false;
  bool _isUploadingImage = false;

  // 게터
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isUpdatingProfile => _isUpdatingProfile;
  bool get isUploadingImage => _isUploadingImage;

  /// 사용자 역할 문자열 반환
  String get userRole {
    if (_user == null) return '';

    switch (_user!.role) {
      case UserRole.academyOwner:
        return 'academy';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.parent:
        return 'parent';
      case UserRole.student:
        return 'student';
      case UserRole.superAdmin:
        return 'admin';
      default:
        return '';
    }
  }

  /// 생성자 - 인증 상태 변화 감지 설정
  AuthViewModel() {
    _status = AuthStatus.loading;
    notifyListeners();

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
      if (userModel == null) {
        try {
          userModel = await _userService.createUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
          );
        } catch (e) {
          // 사용자 생성 실패 시에도 임시 사용자 모델 생성
          userModel = UserModel.initial(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
          );
        }
      }

      _user = userModel;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = '사용자 정보를 불러오는 중 오류가 발생했습니다';

      // 오류 발생 시에도 임시 사용자 모델 생성하여 기본 기능 유지
      try {
        _user = UserModel.initial(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
        );
        _status = AuthStatus.authenticated;
      } catch (e) {
        // 임시 사용자 모델 생성 실패
      }
    }

    notifyListeners();
  }

  /// 구글 로그인
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading();

      // 먼저 기존에 로그인된 계정이 있으면 로그아웃
      try {
        if (_firebaseUser != null) {
          await _authService.signOut();
        }
      } catch (e) {
        // 로그아웃 중 오류(무시됨)
      }

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

  /// 로그아웃
  Future<void> signOut() async {
    try {
      _setLoading();
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 사용자 프로필 업데이트
  Future<bool> updateProfile({
    String? displayName,
    String? academyName,
    String? academyAddress,
    String? academyPhone,
    UserRole? role,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      if (_firebaseUser == null || _user == null) {
        _setError('로그인이 필요합니다');
        return false;
      }

      _isUpdatingProfile = true;
      notifyListeners();

      final updatedUser = await _userService.updateUserProfile(
        uid: _firebaseUser!.uid,
        displayName: displayName,
        academyName: academyName,
        academyAddress: academyAddress,
        academyPhone: academyPhone,
        role: role,
        additionalInfo: additionalInfo,
      );

      _user = updatedUser;
      _isUpdatingProfile = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUpdatingProfile = false;
      _setError('프로필 업데이트 실패: ${e.toString()}');
      return false;
    }
  }

  /// 프로필 이미지 업로드
  Future<bool> uploadProfileImage(File imageFile) async {
    try {
      if (_firebaseUser == null || _user == null) {
        _setError('로그인이 필요합니다');
        return false;
      }

      _isUploadingImage = true;
      notifyListeners();

      final photoURL = await _userService.uploadProfileImage(
        _firebaseUser!.uid,
        imageFile,
      );

      // 사용자 모델 업데이트
      _user = _user!.copyWith(photoURL: photoURL);
      _isUploadingImage = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUploadingImage = false;
      _setError('이미지 업로드 실패: ${e.toString()}');
      return false;
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
