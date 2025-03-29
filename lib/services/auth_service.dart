import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// main.dart에서 가져온 전역 googleSignIn 변수를 사용합니다
import '../main.dart' show googleSignIn;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 현재 유저 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/비밀번호로 로그인
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // 회원가입
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // 구글 로그인
  Future<String?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // 웹 환경에서는 GoogleAuthProvider와 signInWithPopup 사용
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(googleProvider);
      } else {
        // 모바일 환경에서는 GoogleSignIn 사용
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return '구글 로그인이 취소되었습니다.';
        }

        // 인증 정보 획득
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // 크레덴셜 생성
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 파이어베이스 인증 진행
        await _auth.signInWithCredential(credential);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    // Firebase 로그아웃만 실행 (구글 로그아웃은 자동으로 처리됨)
    await _auth.signOut();
  }
}
