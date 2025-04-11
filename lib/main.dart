import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/student_view_model.dart';
import 'viewmodels/class_view_model.dart';
import 'viewmodels/attendance_view_model.dart';
import 'viewmodels/chat_view_model.dart';
import 'viewmodels/schedule_view_model.dart';
import 'views/common/login_view.dart';
import 'views/academy/academy_home_view.dart';
import 'views/teacher/teacher_home_view.dart';
import 'views/parent/parent_home_view.dart';
import 'views/student/student_home_view.dart';

void main() async {
  // Flutter 엔진이 위젯에 바인딩되도록 보장
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // intl 패키지의 한국어 로케일 초기화
    await initializeDateFormatting('ko_KR', null);
    Intl.defaultLocale = 'ko_KR';
  } catch (e) {
    // Firebase 초기화 실패 (오류 처리)
    print('초기화 오류: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => StudentViewModel()),
        ChangeNotifierProvider(create: (_) => ClassViewModel()),
        ChangeNotifierProvider(create: (_) => AttendanceViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => ScheduleViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return MaterialApp(
      title: 'Smartable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: _buildHomeScreen(authViewModel),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _buildHomeScreen(authViewModel),
        );
      },
    );
  }

  // 사용자 역할에 따라 적절한 홈 화면 반환
  Widget _buildHomeScreen(AuthViewModel authViewModel) {
    // 인증되지 않은 경우 로그인 화면 표시
    if (!authViewModel.isAuthenticated) {
      return const LoginView();
    }

    // 사용자 역할에 따라 적절한 홈 화면 반환
    switch (authViewModel.userRole) {
      case 'academy':
        return const AcademyHomeView();
      case 'teacher':
        return const TeacherHomeView();
      case 'parent':
        return const ParentHomeView();
      case 'student':
        return const StudentHomeView();
      case 'admin':
        return const AcademyHomeView(); // 슈퍼관리자는 학원 관리자와 같은 화면 사용
      default:
        // 역할이 지정되지 않은 경우 기본적으로 학생 화면 반환
        return const StudentHomeView();
    }
  }
}
