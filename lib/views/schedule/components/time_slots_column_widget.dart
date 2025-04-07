import 'package:flutter/material.dart';

/// 시간 슬롯 컬럼 위젯 (왼쪽 시간대 표시)
class TimeSlotsColumnWidget extends StatelessWidget {
  final List<TimeOfDay> timeSlots;

  const TimeSlotsColumnWidget({super.key, required this.timeSlots});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: ListView.builder(
        itemCount: timeSlots.length,
        itemBuilder: (context, index) {
          final time = timeSlots[index];
          return Container(
            height: 60, // 1시간당 60픽셀
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          );
        },
      ),
    );
  }
}
