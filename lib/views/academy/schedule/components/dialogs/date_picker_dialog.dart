import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../viewmodels/schedule_view_model.dart';

/// 월 선택 다이얼로그 호출 함수
Future<void> showMonthPickerDialog(
  BuildContext context,
  DateTime focusedDay,
  Function(DateTime) onSelect,
) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder:
        (context) =>
            MonthPickerDialog(focusedDay: focusedDay, onSelect: onSelect),
  );
}

/// 월 선택 다이얼로그
class MonthPickerDialog extends StatelessWidget {
  final DateTime focusedDay;
  final Function(DateTime) onSelect;

  const MonthPickerDialog({
    super.key,
    required this.focusedDay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  '월 선택',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isCurrentMonth = month == focusedDay.month;

                return GestureDetector(
                  onTap: () {
                    final newDate = DateTime(focusedDay.year, month, 1);
                    Navigator.pop(context);
                    onSelect(newDate);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrentMonth ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat('MMM', 'ko').format(DateTime(2022, month)),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isCurrentMonth ? Colors.white : textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 날짜 선택 다이얼로그 호출 함수
Future<void> selectDate(
  BuildContext context,
  ScheduleViewModel viewModel,
) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: viewModel.selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    locale: const Locale('ko', 'KR'),
  );

  if (picked != null && context.mounted) {
    viewModel.changeDate(picked);
  }
}
