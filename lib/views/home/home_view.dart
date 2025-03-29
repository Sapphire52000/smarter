import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';

/// 홈 화면
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pingtelligent'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _handleSignOut(context, authViewModel),
                tooltip: '로그아웃',
              ),
            ],
          ),
          drawer: _buildDrawer(context, user),
          body: _buildBody(context, user),
        );
      },
    );
  }

  // 본문 영역 구성
  Widget _buildBody(BuildContext context, UserModel? user) {
    if (user == null) {
      return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자 정보 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                    child:
                        user.photoUrl == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                  ),
                  const SizedBox(width: 16),

                  // 사용자 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? '이름 없음',
                          style: AppTheme.headingSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(user.email ?? '', style: AppTheme.bodyMedium),
                        const SizedBox(height: 8),
                        _buildRoleChip(user.role),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 빠른 액세스 영역
          Text('빠른 액세스', style: AppTheme.headingSmall),
          const SizedBox(height: 16),

          // 역할별 메뉴 표시
          _buildRoleBasedMenuGrid(context, user.role),
        ],
      ),
    );
  }

  // 역할별 메뉴 그리드 구성
  Widget _buildRoleBasedMenuGrid(BuildContext context, UserRole role) {
    final List<Map<String, dynamic>> menuItems;

    // 역할에 따라 다른 메뉴 표시
    switch (role) {
      case UserRole.admin:
        menuItems = [
          {'icon': Icons.people, 'title': '사용자 관리', 'route': '/users'},
          {'icon': Icons.table_chart, 'title': '테이블 관리', 'route': '/tables'},
          {'icon': Icons.bar_chart, 'title': '통계', 'route': '/statistics'},
          {'icon': Icons.settings, 'title': '시스템 설정', 'route': '/settings'},
        ];
        break;
      case UserRole.coach:
        menuItems = [
          {'icon': Icons.schedule, 'title': '시간표', 'route': '/schedule'},
          {'icon': Icons.people, 'title': '학생 관리', 'route': '/students'},
          {'icon': Icons.sports_tennis, 'title': '경기 관리', 'route': '/matches'},
          {'icon': Icons.analytics, 'title': '분석', 'route': '/analysis'},
        ];
        break;
      case UserRole.student:
      default:
        menuItems = [
          {
            'icon': Icons.calendar_today,
            'title': '출석 현황',
            'route': '/attendance',
          },
          {'icon': Icons.schedule, 'title': '레슨 일정', 'route': '/lessons'},
          {
            'icon': Icons.sports_tennis,
            'title': '경기 참여',
            'route': '/join-match',
          },
          {'icon': Icons.analytics, 'title': '내 통계', 'route': '/my-stats'},
        ];
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children:
          menuItems.map((menu) {
            return _buildMenuCard(
              context,
              icon: menu['icon'],
              title: menu['title'],
              onTap: () => Navigator.pushNamed(context, menu['route']),
            );
          }).toList(),
    );
  }

  // 메뉴 카드 아이템
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppTheme.primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 역할 표시 칩
  Widget _buildRoleChip(UserRole role) {
    final String roleText;
    final Color chipColor;

    switch (role) {
      case UserRole.admin:
        roleText = '관리자';
        chipColor = Colors.red.shade200;
        break;
      case UserRole.coach:
        roleText = '코치';
        chipColor = Colors.blue.shade200;
        break;
      case UserRole.student:
      default:
        roleText = '학생';
        chipColor = Colors.green.shade200;
    }

    return Chip(
      label: Text(roleText),
      backgroundColor: chipColor,
      labelStyle: const TextStyle(color: Colors.black87),
    );
  }

  // 사이드 메뉴 구성
  Widget _buildDrawer(BuildContext context, UserModel? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 헤더 영역
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? '이름 없음'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null ? const Icon(Icons.person) : null,
            ),
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
          ),

          // 메뉴 항목
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('홈'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // 역할별 메뉴 항목
          if (user?.role == UserRole.admin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('사용자 관리'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('테이블 관리'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tables');
              },
            ),
          ],

          if (user?.role == UserRole.coach || user?.role == UserRole.admin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('시간표 관리'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/schedule');
              },
            ),
          ],

          const Divider(),
          ListTile(
            leading: const Icon(Icons.sports_tennis),
            title: const Text('스마트 점수판'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/scoreboard');
            },
          ),

          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('분석'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/analysis');
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              Navigator.pop(context);
              _handleSignOut(context, context.read<AuthViewModel>());
            },
          ),
        ],
      ),
    );
  }

  // 로그아웃 처리
  Future<void> _handleSignOut(
    BuildContext context,
    AuthViewModel authViewModel,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await authViewModel.signOut();
    }
  }
}
