import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// 인증 관련 서비스 클래스
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // 매번 계정 선택 화면이 표시되도록 설정
    scopes: ['email'],
    // 다시 로그인하도록 강제하는 설정은 선언적으로는 없어서 signIn() 전에 signOut()을 호출합니다
  );

  // 인증 상태 변화 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 현재 로그인된 사용자
  User? get currentUser => _auth.currentUser;

  /// 구글 로그인
  Future<String?> signInWithGoogle() async {
    try {
      // iOS 시뮬레이터에서는 직접 Firebase 로그인 사용
      if (kIsWeb || (Platform.isIOS && !kIsWeb && kDebugMode)) {
        try {
          // 시뮬레이터에서는 Firebase Auth 직접 사용
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          // 사용자에게 항상 계정 선택 화면을 표시하도록 설정
          googleProvider.setCustomParameters({'prompt': 'select_account'});

          final UserCredential userCredential = await _auth.signInWithProvider(
            googleProvider,
          );

          return null;
        } catch (e) {
          return '시뮬레이터에서 로그인 실패: $e';
        }
      }

      // 일반적인 구글 로그인 플로우 (실제 기기에서)
      // 로그인 전에 기존 계정 정보를 삭제하여 항상 계정 선택 화면이 표시되도록 함
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // 사용자가 로그인 취소한 경우
      if (googleUser == null) {
        return '로그인이 취소되었습니다';
      }

      // 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 인증 정보 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 인증
      await _auth.signInWithCredential(credential);

      return null; // 성공 시 null 반환
    } catch (e) {
      return '로그인 중 오류가 발생했습니다: ${e.toString()}';
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
