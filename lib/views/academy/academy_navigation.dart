import 'package:flutter/material.dart';
import './academy_dashboard_view.dart';
import './schedule/academy_schedule_view.dart';
import './academy_students_view.dart';
import './academy_classes_view.dart';
import './attendance/academy_monthly_attendance_view.dart';
import '../common/chat_view.dart';
import '../../viewmodels/chat_view_model.dart';
import 'package:provider/provider.dart';

/// 학원 관리자 네비게이션 메뉴
class AcademyNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AcademyNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          label: Text('대시보드'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_today),
          label: Text('시간표'),
        ),
        NavigationRailDestination(icon: Icon(Icons.chat), label: Text('채팅')),
        NavigationRailDestination(
          icon: Icon(Icons.class_),
          label: Text('수업 관리'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('학생 관리'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.fact_check),
          label: Text('출석 관리'),
        ),
      ],
    );
  }
}

/// 학원 관리자 하단 네비게이션 바
class AcademyBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AcademyBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onDestinationSelected,
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: '대시보드'),
        NavigationDestination(icon: Icon(Icons.calendar_today), label: '시간표'),
        NavigationDestination(icon: Icon(Icons.chat), label: '채팅'),
        NavigationDestination(icon: Icon(Icons.class_), label: '수업'),
        NavigationDestination(icon: Icon(Icons.people), label: '학생'),
        NavigationDestination(icon: Icon(Icons.fact_check), label: '출석'),
      ],
    );
  }
}

/// 네비게이션에 따른 화면 생성
Widget buildScreen(int index) {
  switch (index) {
    case 0:
      return const AcademyDashboardView();
    case 1:
      return const AcademyScheduleView();
    case 2:
      return ChangeNotifierProvider(
        create: (_) => ChatViewModel(),
        child: const ChatView(),
      );
    case 3:
      return const AcademyClassesView();
    case 4:
      return const AcademyStudentsView();
    case 5:
      return const AcademyMonthlyAttendanceView();
    default:
      return const AcademyDashboardView();
  }
}
