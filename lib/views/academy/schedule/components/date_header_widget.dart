import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../viewmodels/schedule_view_model.dart';

/// 날짜 헤더 위젯
class DateHeaderWidget extends StatelessWidget {
  final ScheduleViewModel viewModel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onDateTap;
  final Color primaryColor;

  const DateHeaderWidget({
    super.key,
    required this.viewModel,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onDateTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDate = viewModel.selectedDate;
    final dateFormat =
        viewModel.currentViewType == ViewType.week
            ? _buildWeekHeaderText(viewModel.weekDates.first)
            : DateFormat('yyyy년 M월 d일 (E)', 'ko').format(selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.navigate_before, color: primaryColor),
            onPressed: onPrevious,
            tooltip:
                viewModel.currentViewType == ViewType.week ? '이전 주' : '이전 날짜',
          ),
          Expanded(
            child: GestureDetector(
              onTap: onDateTap,
              child: Text(
                dateFormat,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.today, color: primaryColor),
            onPressed: onToday,
            tooltip: '오늘',
          ),
          IconButton(
            icon: Icon(Icons.navigate_next, color: primaryColor),
            onPressed: onNext,
            tooltip:
                viewModel.currentViewType == ViewType.week ? '다음 주' : '다음 날짜',
          ),
        ],
      ),
    );
  }

  // 주간 헤더 텍스트 생성
  String _buildWeekHeaderText(DateTime date) {
    // 해당 주의 월요일 찾기
    final monday = date.subtract(Duration(days: date.weekday - 1));

    // 해당 주의 일요일 찾기
    final sunday = monday.add(const Duration(days: 6));

    // 월-일 형식으로 표시 (월이 같으면 월 표시 한 번만)
    if (monday.month == sunday.month) {
      return '${DateFormat('M월 d일', 'ko').format(monday)} ~ ${DateFormat('d일', 'ko').format(sunday)}';
    } else {
      return '${DateFormat('M월 d일', 'ko').format(monday)} ~ ${DateFormat('M월 d일', 'ko').format(sunday)}';
    }
  }
}
