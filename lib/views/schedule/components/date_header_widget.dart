import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../viewmodels/schedule_view_model.dart';

/// 날짜 헤더 위젯 (날짜 표시 및 이동 버튼)
class DateHeaderWidget extends StatelessWidget {
  final ScheduleViewModel viewModel;
  final Function() onDatePickerTap;

  const DateHeaderWidget({
    super.key,
    required this.viewModel,
    required this.onDatePickerTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = viewModel.selectedDate;
    final dateFormat = DateFormat('yyyy년 MM월 dd일 (EEE)', 'ko');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onDatePickerTap,
            child: Text(
              dateFormat.format(date),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4.0,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => viewModel.previousDay(),
              ),
              TextButton(
                onPressed: () => viewModel.goToToday(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('오늘', style: TextStyle(fontSize: 14)),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => viewModel.nextDay(),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed:
                    () => viewModel.setViewType(
                      viewModel.currentViewType == ViewType.day
                          ? ViewType.week
                          : ViewType.day,
                    ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  viewModel.currentViewType == ViewType.day ? '월 보기' : '일 보기',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
