import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartable/views/common/chat_view.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/chat_view_model.dart';
import '../academy/academy_dashboard_view.dart';
import '../academy/academy_students_view.dart';
import '../academy/academy_classes_view.dart';
import '../academy/academy_schedule_view.dart';
import 'profile_view.dart';

/// 홈 화면
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // 탭 화면 목록
  final List<Widget> _screens = [
    const AcademyDashboardView(),
    const AcademyScheduleView(),
    ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: const ChatView(),
    ),
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
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          // 현재 탭에 따라 추가 버튼 표시
          if (_selectedIndex > 0 && _selectedIndex != 2) // 대시보드와 채팅이 아닐 때만 표시
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _handleAddAction(context),
            ),
          // 사용자 프로필 아이콘 버튼
          IconButton(
            icon: CircleAvatar(
              backgroundImage:
                  user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
              radius: 14,
            ),
            onPressed: () => _navigateToProfile(context),
          ),
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context, authViewModel),
          ),
        ],
      ),
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

  // 각 탭에 맞는 추가 기능 처리
  void _handleAddAction(BuildContext context) {
    switch (_selectedIndex) {
      case 1: // 시간표
        _showAddScheduleDialog(context);
        break;
      case 3: // 수업
        _showAddClassDialog(context);
        break;
      case 4: // 학생
        _showAddStudentDialog(context);
        break;
    }
  }

  // 시간표 추가 다이얼로그
  void _showAddScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('수업 시간표 설정'),
          content: const Text('수업 관리 메뉴에서 수업을 등록하고 시간표를 설정할 수 있습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 수업 추가 다이얼로그 처리
  void _showAddClassDialog(BuildContext context) {
    // ClassesView 내부 메서드에 접근할 수 없으므로, Navigator를 이용해 새 화면으로 이동하거나
    // Provider를 통해 직접 클래스 추가 다이얼로그를 보여주는 방식으로 구현 가능
    // 여기서는 간단한 메시지만 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('수업 추가 기능은 수업 관리 화면에서 사용할 수 있습니다')),
    );
  }

  // 학생 추가 다이얼로그 처리
  void _showAddStudentDialog(BuildContext context) {
    // StudentsView 내부 메서드에 접근할 수 없으므로, Navigator를 이용해 새 화면으로 이동하거나
    // Provider를 통해 직접 학생 추가 다이얼로그를 보여주는 방식으로 구현 가능
    // 여기서는 간단한 메시지만 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('학생 추가 기능은 학생 관리 화면에서 사용할 수 있습니다')),
    );
  }

  // 프로필 화면으로 이동
  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileView()),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
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
