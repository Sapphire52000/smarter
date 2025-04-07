import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../viewmodels/schedule_view_model.dart';

/// 주간 뷰의 요일 헤더 위젯
class WeekDayHeaderWidget extends StatelessWidget {
  final ScheduleViewModel viewModel;
  final Function(DateTime) onDateTap;
  final Function(DateTime) onDateDoubleTap;
  final Color primaryColor;
  final Color surfaceColor;
  final Color timeIndicatorColor;
  final Color textColor;

  const WeekDayHeaderWidget({
    super.key,
    required this.viewModel,
    required this.onDateTap,
    required this.onDateDoubleTap,
    required this.primaryColor,
    required this.surfaceColor,
    required this.timeIndicatorColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final weekDates = viewModel.weekDates;
    final selectedDate = viewModel.selectedDate;

    return Row(
      children: [
        // 시간 레이블 공간
        SizedBox(width: 60, child: Container()),
        // 요일 레이블들
        ...List.generate(7, (index) {
          final date = weekDates[index];
          final isToday = _isSameDay(date, DateTime.now());
          final isSelected = _isSameDay(date, selectedDate);
          final dayName = DateFormat('E', 'ko').format(date);
          final dayNum = DateFormat('d').format(date);

          return Expanded(
            child: GestureDetector(
              onTap: () => onDateTap(date),
              onDoubleTap: () => onDateDoubleTap(date),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? primaryColor
                          : (isToday ? surfaceColor : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? Colors.white
                                : (date.weekday == 6
                                    ? Colors.blue
                                    : (date.weekday == 7
                                        ? Colors.red
                                        : primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isToday ? timeIndicatorColor : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dayNum,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Colors.white
                                  : (isToday ? Colors.white : textColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // 날짜 비교 (연/월/일만 비교)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
