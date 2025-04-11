import 'package:flutter/material.dart';
import '../../academy_students_view.dart';

/// 학생 출석 요약 컴포넌트
class StudentAttendanceSummary extends StatelessWidget {
  final Student student;

  const StudentAttendanceSummary({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '출석 현황',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAttendanceProgress(context),
            const SizedBox(height: 16),
            _buildAttendanceStats(context),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('상세 출석 기록'),
                  onPressed: () => _navigateToDetailAttendance(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceProgress(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: student.attendanceRate / 100,
            minHeight: 16,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getAttendanceColor(student.attendanceRate),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Text(
            '${student.attendanceRate}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black,
                  offset: Offset(0.5, 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceStats(BuildContext context) {
    // 출석, 결석, 미확인 데이터는 예시 데이터입니다.
    // 실제 구현에서는 API나 DB에서 가져온 데이터를 사용해야 합니다.
    const totalClasses = 12; // 이번달 수업 횟수
    final attendCount = (student.attendanceRate * totalClasses / 100).round();
    final uncheckedCount = 2; // 아직 확인되지 않은 출석 횟수
    final absentCount = totalClasses - attendCount - uncheckedCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          Icons.calendar_month,
          '이번달 수업',
          '$totalClasses회',
          Colors.blue,
        ),
        _buildStatItem(
          context,
          Icons.check_circle_outline,
          '출석',
          '$attendCount회',
          Colors.green,
        ),
        _buildStatItem(
          context,
          Icons.cancel_outlined,
          '결석',
          '$absentCount회',
          Colors.red,
        ),
        _buildStatItem(
          context,
          Icons.help_outline,
          '미확인',
          '$uncheckedCount회',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getAttendanceColor(int rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 80) return Colors.lightGreen;
    if (rate >= 70) return Colors.orange;
    return Colors.red;
  }

  void _navigateToDetailAttendance(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('상세 출석 기록 기능은 준비 중입니다')));
  }
}
