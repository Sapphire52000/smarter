import 'package:flutter/material.dart';
import '../../../../models/schedule_model.dart';

/// 일정 블록 위젯
class ScheduleBlockWidget extends StatelessWidget {
  final ScheduleModel schedule;
  final Function(ScheduleModel) onTap;
  final double height;
  final double width;

  const ScheduleBlockWidget({
    super.key,
    required this.schedule,
    required this.onTap,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        color: schedule.color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onTap(schedule),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 크기에 맞게 내용 표시
                final bool isShortBlock = constraints.maxHeight < 50;
                final timeRangeString =
                    '${_formatTime(schedule.startTime)} ~ ${_formatTime(schedule.endTime)}';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 시간 범위는 충분한 높이가 있을 때만 표시
                    if (!isShortBlock)
                      Text(
                        timeRangeString,
                        style: TextStyle(
                          fontSize: 9,
                          color: _getContrastColor(schedule.color),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                    // 일정 제목
                    Flexible(
                      child: Text(
                        schedule.title,
                        style: TextStyle(
                          fontSize: isShortBlock ? 10 : 11,
                          fontWeight: FontWeight.bold,
                          color: _getContrastColor(schedule.color),
                        ),
                        maxLines: isShortBlock ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // 배경색에 따른 텍스트 색상 계산
  Color _getContrastColor(Color backgroundColor) {
    // 밝기 계산 (표준 공식 사용)
    double brightness =
        (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) /
        1000;

    // 어두운 색상은 흰색, 밝은 색상은 검은색 반환
    return brightness > 160 ? Colors.black : Colors.white;
  }

  // 시간 포맷팅
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
