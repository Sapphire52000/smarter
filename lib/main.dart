import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';
import 'viewmodels/auth_view_model.dart';
import 'utils/theme.dart';

// 전역 변수로 선언하여 앱 전체에서 재사용 가능하도록 합니다
final GoogleSignIn googleSignIn = GoogleSignIn();

void main() async {
  // Flutter 엔진이 위젯에 바인딩되도록 보장
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase 초기화 성공');

    // Google Sign In 초기화는 나중에 필요할 때 수행
  } catch (e) {
    print('Firebase 초기화 오류: $e');
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pingtelligent',
      theme: AppTheme.lightTheme,
      home: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          // 인증 상태에 따라 화면 분기
          switch (authViewModel.status) {
            case AuthStatus.authenticated:
              return const HomeView();
            case AuthStatus.unauthenticated:
              return const LoginView();
            case AuthStatus.loading:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case AuthStatus.error:
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text('오류가 발생했습니다', style: AppTheme.headingMedium),
                      const SizedBox(height: 8),
                      Text(
                        authViewModel.errorMessage ?? '알 수 없는 오류',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => authViewModel.clearError(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              );
            case AuthStatus.initial:
            default:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
          }
        },
      ),
      routes: {
        // 추후 라우트 정의 예정
        '/home': (context) => const HomeView(),
      },
    );
  }
}
