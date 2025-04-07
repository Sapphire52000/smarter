import 'package:flutter/material.dart';
import '../../../../models/schedule_model.dart';
import '../../../../viewmodels/schedule_view_model.dart';
import 'time_slots_column_widget.dart';
import 'schedule_block_widget.dart';

/// 스케줄 그리드 위젯 (일정을 표시하는 그리드)
class ScheduleGridWidget extends StatelessWidget {
  final ScheduleViewModel viewModel;
  final List<TimeOfDay> timeSlots;
  final Function(ScheduleModel) onScheduleTap;
  final Function(TimeOfDay) onTimeSlotTap;

  const ScheduleGridWidget({
    super.key,
    required this.viewModel,
    required this.timeSlots,
    required this.onScheduleTap,
    required this.onTimeSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final schedules = viewModel.getSchedulesForDate(viewModel.selectedDate);

    return Row(
      children: [
        // 왼쪽 시간 칼럼
        TimeSlotsColumnWidget(timeSlots: timeSlots),

        // 오른쪽 일정 컨테이너
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: Stack(
              children: [
                // 시간대 구분선
                ListView.builder(
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    );
                  },
                ),

                // 일정 블록들
                ...schedules.map(
                  (schedule) => ScheduleBlockWidget(
                    schedule: schedule,
                    onTap: onScheduleTap,
                  ),
                ),

                // 빈 영역 터치 감지 (일정 추가 다이얼로그 표시)
                GestureDetector(
                  onTapDown: (details) {
                    // 터치 위치에서 시간 계산
                    final ScrollableState scrollable = Scrollable.of(context);

                    // 스크롤 위치 계산
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    final position = box.globalToLocal(details.globalPosition);
                    final scrollOffset = scrollable.position.pixels;

                    // 시간 위치 계산 (1픽셀 = 1분/60)
                    final timePosition = (position.dy + scrollOffset) / 60;
                    final hour = 7 + timePosition.floor(); // 7시부터 시작
                    final minute =
                        ((timePosition - timePosition.floor()) * 60).round();

                    // 유효한 시간 범위 확인
                    if (hour >= 7 && hour <= 22) {
                      // 선택한 시간으로 다이얼로그 열기
                      final selectedTime = TimeOfDay(
                        hour: hour,
                        minute: minute,
                      );
                      onTimeSlotTap(selectedTime);
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: 60 * timeSlots.length.toDouble(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
