import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/auth_view_model.dart';
import '../academy/academy_home_view.dart';
import '../parent/parent_home_view.dart';
import '../teacher/teacher_home_view.dart';
import '../student/student_home_view.dart';
import '../../models/user_model.dart';

/// 로그인 화면
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    super.initState();
    // 로그인 화면이 표시될 때 이미 로그인된 사용자가 있으면 로그아웃
    _logoutIfAlreadySignedIn();
  }

  // 이미 로그인된 사용자가 있는 경우 로그아웃하여 계정 선택 화면이 표시되도록 함
  Future<void> _logoutIfAlreadySignedIn() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // 이미 로그인되어 있으면 역할에 따라 적절한 홈 화면으로 이동
        if (authViewModel.status == AuthStatus.authenticated) {
          return _buildHomeForRole(authViewModel.user?.role);
        }

        // 로그인 화면
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 앱 로고 및 제목
                  const Icon(Icons.school, size: 80, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Smartable',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '학원 관리 시스템',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 80),

                  // 오류 메시지
                  if (authViewModel.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authViewModel.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: authViewModel.clearError,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 구글 로그인 버튼
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text(
                      '구글 계정으로 로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed:
                        authViewModel.isLoading
                            ? null
                            : () => _handleGoogleSignIn(context, authViewModel),
                  ),
                  const SizedBox(height: 32),

                  // 로딩 인디케이터
                  if (authViewModel.isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 사용자 역할에 따라 적절한 홈 화면 반환
  Widget _buildHomeForRole(UserRole? role) {
    switch (role) {
      case UserRole.academyOwner:
        return const AcademyHomeView();
      case UserRole.teacher:
        return const TeacherHomeView();
      case UserRole.parent:
        return const ParentHomeView();
      case UserRole.student:
        return const StudentHomeView();
      default:
        // 역할이 없거나 알 수 없는 역할인 경우 기본적으로 학생 화면 표시
        return const StudentHomeView();
    }
  }

  /// 구글 로그인 처리
  Future<void> _handleGoogleSignIn(
    BuildContext context,
    AuthViewModel authViewModel,
  ) async {
    try {
      // 로그인 전에 현재 로그인된 사용자가 있으면 로그아웃
      await _logoutIfAlreadySignedIn();

      final success = await authViewModel.signInWithGoogle();

      if (!success && mounted) {
        // 에러가 이미 ViewModel에서 처리되었으므로 추가 작업 불필요
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 예외 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
