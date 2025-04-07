import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 현재 시간 표시기 위젯
class CurrentTimeIndicatorWidget extends StatelessWidget {
  final List<DateTime> weekDates;
  final double dayColumnWidth;
  final int startHour;
  final double hourHeight;
  final Color timeIndicatorColor;

  const CurrentTimeIndicatorWidget({
    super.key,
    required this.weekDates,
    required this.dayColumnWidth,
    required this.startHour,
    required this.hourHeight,
    required this.timeIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    // 현재 시간
    final now = DateTime.now();
    final currentHourDecimal = now.hour + (now.minute / 60.0);

    // 시각화 가능한 범위 안에 있는 경우에만 표시
    if (currentHourDecimal < startHour) {
      return Container(); // 시각화 범위 밖이면 표시하지 않음
    }

    final topOffset = (currentHourDecimal - startHour) * hourHeight;
    final timeString = DateFormat('HH:mm').format(now);

    // 오늘이 주간 뷰에 포함되는지 확인
    int todayIndex = -1;
    for (int i = 0; i < weekDates.length; i++) {
      if (_isSameDay(weekDates[i], now)) {
        todayIndex = i;
        break;
      }
    }

    // 오늘이 주간 뷰에 포함되지 않으면 표시하지 않음
    if (todayIndex == -1) return Container();

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Row(
        children: [
          // 시간 레이블
          Container(
            width: 60,
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Text(
              timeString,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: timeIndicatorColor,
              ),
            ),
          ),
          // 현재 요일 위치까지 투명 공간
          SizedBox(width: dayColumnWidth * todayIndex),
          // 해당 요일 칼럼에만 현재 시간 표시선
          Container(
            width: dayColumnWidth,
            height: 2,
            color: timeIndicatorColor,
          ),
        ],
      ),
    );
  }

  // 날짜 비교 (연/월/일만 비교)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
