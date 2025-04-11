import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartable/views/common/chat_view.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/chat_view_model.dart';
import 'academy_dashboard_view.dart';
import 'academy_classes_view.dart';
import 'academy_students_view.dart';
import '../common/profile_view.dart';
import 'schedule/academy_schedule_view.dart';
import 'schedule/academy_weekly_schedule_view.dart';

/// 학원 관리자 홈 화면
class AcademyHomeView extends StatefulWidget {
  const AcademyHomeView({super.key});

  @override
  State<AcademyHomeView> createState() => _AcademyHomeViewState();
}

class _AcademyHomeViewState extends State<AcademyHomeView> {
  int _selectedIndex = 0;

  // 탭 화면 목록
  final List<Widget> _screens = [
    const AcademyDashboardView(),
    const AcademyWeeklyScheduleView(),
    const ChatView(),
    const AcademyClassesView(),
    const AcademyStudentsView(),
  ];

  // 탭 제목 목록
  final List<String> _titles = ['대시보드', '시간표', '채팅', '수업 관리', '학생 관리'];

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.user;

    return Scaffold(
      appBar:
          _selectedIndex == 0
              ? AppBar(
                title: Text(_titles[_selectedIndex]),
                actions: [
                  // 사용자 프로필 아이콘 버튼
                  IconButton(
                    icon: CircleAvatar(
                      backgroundImage:
                          user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  )
                                  as ImageProvider,
                      radius: 14,
                    ),
                    onPressed: () => _navigateToProfile(context),
                    tooltip: '프로필',
                  ),
                  // 로그아웃 버튼
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed:
                        () => _showLogoutConfirmation(context, authViewModel),
                    tooltip: '로그아웃',
                  ),
                ],
              )
              : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: '대시보드'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: '시간표'),
          NavigationDestination(icon: Icon(Icons.chat), label: '채팅'),
          NavigationDestination(icon: Icon(Icons.class_), label: '수업'),
          NavigationDestination(icon: Icon(Icons.people), label: '학생'),
        ],
      ),
    );
  }

  // 프로필 화면으로 이동
  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileView()),
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    AuthViewModel authViewModel,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  authViewModel.signOut();
                  Navigator.pop(context);
                },
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );
  }
}
