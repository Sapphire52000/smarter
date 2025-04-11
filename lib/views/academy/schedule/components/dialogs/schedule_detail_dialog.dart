import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../viewmodels/schedule_view_model.dart';
import '../../../../../viewmodels/auth_view_model.dart';
import '../../../../../models/schedule_model.dart';
import '../../../../../models/user_model.dart';

/// 일정 세부 정보 다이얼로그
class ScheduleDetailDialog extends StatelessWidget {
  final ScheduleModel schedule;
  final ScheduleViewModel scheduleViewModel;

  const ScheduleDetailDialog({
    super.key,
    required this.schedule,
    required this.scheduleViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: schedule.color,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 8),
          ),
          Expanded(child: Text(schedule.title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 일정 시간
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${DateFormat('yyyy.MM.dd', 'ko').format(schedule.startTime)}'
                  ' ${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}'
                  ' (${schedule.durationInMinutes ~/ 60}시간 ${schedule.durationInMinutes % 60}분)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 일정 설명
          const Text('설명:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(schedule.description.isEmpty ? '설명 없음' : schedule.description),
          const SizedBox(height: 16),

          // 생성 정보
          Text(
            '생성 일시: ${DateFormat('yyyy.MM.dd HH:mm').format(schedule.createdAt)}',
          ),
        ],
      ),
      actions: [
        // 삭제 버튼 (생성자 또는 관리자만 표시)
        if (schedule.createdBy == authViewModel.user?.uid ||
            authViewModel.user?.role == UserRole.academyOwner)
          TextButton(
            onPressed: () => _confirmDelete(context),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  // 시간 포맷팅 함수
  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // 일정 삭제 확인 다이얼로그
  Future<void> _confirmDelete(BuildContext context) async {
    // 삭제 확인 다이얼로그
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('일정 삭제'),
            content: const Text('이 일정을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      // 현재 다이얼로그 닫기
      Navigator.pop(context);

      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 일정 삭제
      await scheduleViewModel.deleteSchedule(schedule.id);

      if (!context.mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('일정이 삭제되었습니다')));
    }
  }
}

/// 일정 세부 정보 다이얼로그 호출 함수
Future<void> showScheduleDetailDialog(
  BuildContext context,
  ScheduleModel schedule,
  ScheduleViewModel viewModel,
) async {
  await showDialog(
    context: context,
    builder:
        (context) => ScheduleDetailDialog(
          schedule: schedule,
          scheduleViewModel: viewModel,
        ),
  );
}
