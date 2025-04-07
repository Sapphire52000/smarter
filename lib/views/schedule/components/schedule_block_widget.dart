import 'package:flutter/material.dart';
import '../../../../models/schedule_model.dart';

/// 개별 일정 블록 위젯
class ScheduleBlockWidget extends StatelessWidget {
  final ScheduleModel schedule;
  final Function(ScheduleModel) onTap;

  const ScheduleBlockWidget({
    super.key,
    required this.schedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 일정 시작 시간에 따른 위치 계산
    final startHour = schedule.startTime.hour;
    final startMinute = schedule.startTime.minute;
    final endHour = schedule.endTime.hour;
    final endMinute = schedule.endTime.minute;

    // 시작 시간과 시간표 시작 시간(7시)의 차이를 픽셀로 계산
    final top = (startHour - 7) * 60 + startMinute.toDouble();

    // 일정 지속 시간을 픽셀로 계산
    final duration =
        (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
    final height = duration.toDouble();

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: GestureDetector(
          onTap: () => onTap(schedule),
          child: Container(
            decoration: BoxDecoration(
              color: schedule.color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (height > 30) // 충분히 높은 경우에만 추가 정보 표시
                  Text(
                    '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 시간 표시 포맷
  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
