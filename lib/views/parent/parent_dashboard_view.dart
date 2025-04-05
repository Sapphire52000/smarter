import 'package:flutter/material.dart';

/// 학부모용 대시보드 화면
class ParentDashboardView extends StatefulWidget {
  const ParentDashboardView({super.key});

  @override
  State<ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends State<ParentDashboardView> {
  // 임시 데이터
  final List<Map<String, dynamic>> _children = [
    {
      'name': '김민준',
      'grade': '중학교 2학년',
      'classes': ['수학 기초반', '영어 중급반', '과학 실험반'],
      'nextClass': '오늘 16:00 - 영어 중급반',
      'attendance': 85,
      'academyCount': 2,
    },
    {
      'name': '김서연',
      'grade': '초등학교 5학년',
      'classes': ['코딩 기초반', '미술 창작반'],
      'nextClass': '내일 14:00 - 코딩 기초반',
      'attendance': 95,
      'academyCount': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildChildrenSummary(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 24),
          _buildNotiBoard(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange[400], size: 24),
                const SizedBox(width: 8),
                Text(
                  '안녕하세요!',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '자녀의 학습 현황을 확인해보세요',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  Icons.child_care,
                  '자녀',
                  '${_children.length}명',
                  Colors.blue,
                ),
                _buildInfoChip(
                  Icons.school,
                  '학원',
                  '${_getTotalAcademyCount()}개',
                  Colors.green,
                ),
                _buildInfoChip(
                  Icons.class_,
                  '수업',
                  '${_getTotalClassCount()}개',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '자녀 현황',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // 자녀 관리 탭으로 이동
                // 3번째 탭(index 2)으로 이동하는 로직이 필요합니다.
              },
              child: const Text('전체보기'),
            ),
          ],
        ),
        ..._children.map((child) => _buildChildCard(child)),
      ],
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    child['name'].substring(0, 1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child['name'],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        child['grade'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAttendanceIndicator(child['attendance']),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '다음 수업',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        child['nextClass'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // 수업 시간표 확인 화면으로 이동
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('시간표'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceIndicator(int attendanceRate) {
    Color color;
    if (attendanceRate >= 95) {
      color = Colors.green;
    } else if (attendanceRate >= 85) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '출석률 $attendanceRate%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최근 활동',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              '김민준 영어 중급반 출석',
              '오늘 16:30',
              Icons.check_circle,
              Colors.green,
            ),
            _buildActivityItem(
              '김서연 코딩 기초반 숙제 제출',
              '어제',
              Icons.assignment_turned_in,
              Colors.blue,
            ),
            _buildActivityItem(
              '김민준 수학 기초반 시험 결과 확인',
              '3일 전',
              Icons.assignment,
              Colors.orange,
            ),
            _buildActivityItem(
              '김서연 미술 창작반 작품 업로드',
              '5일 전',
              Icons.brush,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  time,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotiBoard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '공지사항',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 공지사항 전체보기
                  },
                  child: const Text('전체보기'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildNoticeItem('2023년 여름방학 특강 안내', '중앙학원', '3일 전'),
            _buildNoticeItem('6월 학부모 상담 일정 안내', '영어마을', '1주일 전'),
            _buildNoticeItem('중간고사 대비 특강 안내', '중앙학원', '2주일 전'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeItem(String title, String academy, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$academy • $time'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // 공지사항 상세 보기
      },
    );
  }

  // 총 학원 수 계산
  int _getTotalAcademyCount() {
    return _children.fold(
      0,
      (sum, child) => sum + (child['academyCount'] as int),
    );
  }

  // 총 수업 수 계산
  int _getTotalClassCount() {
    return _children.fold(
      0,
      (sum, child) => sum + (child['classes'] as List).length,
    );
  }
}
