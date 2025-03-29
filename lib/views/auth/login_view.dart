import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../utils/platform_utils.dart';

/// 로그인 화면
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          // 로딩 상태면 로딩 인디케이터 표시
          if (authViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 에러 메시지가 있으면 표시
          if (authViewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authViewModel.errorMessage!),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: '확인',
                    textColor: Colors.white,
                    onPressed: () {
                      authViewModel.clearError();
                    },
                  ),
                ),
              );
              authViewModel.clearError();
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 앱 로고 또는 아이콘
                const Icon(
                  Icons.sports_tennis,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),

                // 앱 이름
                const Text(
                  'Pingtelligent',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // 앱 설명
                const Text(
                  '스마트 탁구장 시스템',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),

                // 구글 로그인 버튼
                ElevatedButton.icon(
                  onPressed: () => _handleGoogleSignIn(context, authViewModel),
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                  ),
                  label: const Text('Google로 계속하기'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 애플 로그인 버튼 (iOS/macOS에서만 표시)
                if (PlatformUtils.isIOS || PlatformUtils.isMacOS)
                  ElevatedButton.icon(
                    onPressed: () => _handleAppleSignIn(context, authViewModel),
                    icon: const Icon(Icons.apple, color: Colors.white),
                    label: const Text('Apple로 계속하기'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 구글 로그인 처리
  Future<void> _handleGoogleSignIn(
    BuildContext context,
    AuthViewModel authViewModel,
  ) async {
    final result = await authViewModel.signInWithGoogle();
    if (!result && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('구글 로그인에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  // 애플 로그인 처리 (미구현)
  Future<void> _handleAppleSignIn(
    BuildContext context,
    AuthViewModel authViewModel,
  ) async {
    final result = await authViewModel.signInWithApple();
    if (!result && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('애플 로그인은 아직 준비 중입니다.')));
    }
  }
}
