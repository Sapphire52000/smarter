import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/schedule_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../models/schedule_model.dart';
import '../../../models/user_model.dart';
import '../../../views/schedule/components/date_header_widget.dart';
import '../../../views/schedule/utils/date_utils.dart';
import './schedule_view.dart';

/// 학부모용 주간 시간표 화면
class ParentWeeklyScheduleView extends StatefulWidget {
  const ParentWeeklyScheduleView({super.key});

  @override
  State<ParentWeeklyScheduleView> createState() =>
      _ParentWeeklyScheduleViewState();
}

class _ParentWeeklyScheduleViewState extends State<ParentWeeklyScheduleView> {
  // 시간 그리드 상수
  final int _startHour = 8; // 오전 8시부터 시작
  final int _endHour = 20; // 오후 8시까지
  final double _hourHeight = 60.0; // 시간당 60픽셀 높이

  @override
  void initState() {
    super.initState();

    // ViewModel 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final scheduleViewModel = Provider.of<ScheduleViewModel>(
        context,
        listen: false,
      );

      // 뷰 타입을 주간으로 설정
      scheduleViewModel.setViewType(ViewType.week);

      // 일단 빈 weekDates로 초기화할 수 있도록 날짜 선택
      scheduleViewModel.goToToday(); // 오늘 날짜로 설정하여 weekDates 초기화

      // 완전한 초기화
      await scheduleViewModel.initialize(authViewModel: authViewModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleViewModel = Provider.of<ScheduleViewModel>(context);
    final primaryColor = Theme.of(context).primaryColor;

    if (scheduleViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scheduleViewModel.error != null) {
      return buildErrorWidget(context, scheduleViewModel);
    }

    // weekDates가 비어있는지 확인
    if (scheduleViewModel.weekDates.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('일정 데이터를 불러오는 중입니다...'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 주간 날짜 선택 바
        _buildWeeklyScheduleHeader(scheduleViewModel),
        // 주간 시간표 그리드
        Expanded(child: _buildWeeklyScheduleGrid(scheduleViewModel)),
      ],
    );
  }

  // 주간 네비게이션 바
  Widget _buildWeeklyScheduleHeader(ScheduleViewModel viewModel) {
    final DateTime selectedDate = viewModel.selectedDate;

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // 날짜 네비게이션
          DateHeaderWidget(
            viewModel: viewModel,
            onDatePickerTap: () => _selectDate(context, viewModel),
          ),
          const SizedBox(height: 8),
          // 요일 표시
          _buildWeekDayHeader(viewModel),
        ],
      ),
    );
  }

  // 요일 헤더 위젯
  Widget _buildWeekDayHeader(ScheduleViewModel viewModel) {
    final List<DateTime> weekDates = viewModel.weekDates;
    final DateTime selectedDate = viewModel.selectedDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: List.generate(7, (index) {
          final date = weekDates[index];
          final isSelected = ScheduleDateUtils.isSameDay(date, selectedDate);
          final isToday = ScheduleDateUtils.isSameDay(date, DateTime.now());

          // 주말은 다른 색상으로 표시
          final bool isWeekend = date.weekday >= 6; // 토요일(6) 또는 일요일(7)

          return Expanded(
            child: GestureDetector(
              onTap: () => viewModel.changeDate(date),
              onDoubleTap: () => _navigateToDaily(context, date),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.blue.withOpacity(0.1)
                          : isToday
                          ? Colors.green.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isWeekend
                                ? date.weekday == 6
                                    ? Colors.blue
                                    : Colors.red
                                : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSelected
                                ? Colors.blue
                                : isToday
                                ? Colors.green
                                : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected || isToday ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 주간 시간표 그리드
  Widget _buildWeeklyScheduleGrid(ScheduleViewModel viewModel) {
    final List<DateTime> weekDates = viewModel.weekDates;
    final schedules = viewModel.getSchedulesForDateRange(weekDates);

    // 하루 전체를 위한 총 높이 계산
    final totalHeight = (_endHour - _startHour + 1) * _hourHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 각 요일 칼럼의 너비 계산
        final dayColumnWidth = (constraints.maxWidth - 60) / 7;

        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 시간과 30분 그리드 라인
                SizedBox(
                  height: totalHeight,
                  child: Row(
                    children: [
                      // 시간 레이블 컬럼
                      SizedBox(
                        width: 60,
                        child: Column(
                          children: List.generate(_endHour - _startHour + 1, (
                            index,
                          ) {
                            final hour = _startHour + index;
                            return SizedBox(
                              height: _hourHeight,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '$hour:00',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // 요일별 그리드
                      Expanded(
                        child: Column(
                          children: List.generate(_endHour - _startHour + 1, (
                            hourIndex,
                          ) {
                            return Container(
                              height: _hourHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: List.generate(
                                  7,
                                  (dayIndex) => Container(
                                    width: dayColumnWidth,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: Colors.grey[100]!,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                // 일정 블록들
                ...schedules.map(
                  (schedule) =>
                      _buildScheduleBlock(schedule, weekDates, dayColumnWidth),
                ),

                // 현재 시간 표시기
                _buildCurrentTimeIndicator(weekDates, dayColumnWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  // 일정 블록 위젯
  Widget _buildScheduleBlock(
    ScheduleModel schedule,
    List<DateTime> weekDates,
    double dayColumnWidth,
  ) {
    // 시작 날짜가 주간 뷰에 포함되는지 확인
    int dayIndex = -1;
    for (int i = 0; i < weekDates.length; i++) {
      if (ScheduleDateUtils.isSameDay(schedule.startTime, weekDates[i])) {
        dayIndex = i;
        break;
      }
    }

    // 주간 뷰에 포함되지 않으면 표시하지 않음
    if (dayIndex == -1) return Container();

    // 위치 및 높이 계산
    final startHourDecimal =
        schedule.startTime.hour + (schedule.startTime.minute / 60.0);
    final endHourDecimal =
        schedule.endTime.hour + (schedule.endTime.minute / 60.0);

    final startOffset = (startHourDecimal - _startHour) * _hourHeight;
    final height = (endHourDecimal - startHourDecimal) * _hourHeight;

    // 좌측 위치 계산 (시간 레이블 60px + 해당 요일의 위치)
    final leftOffset = 60 + (dayColumnWidth * dayIndex);

    // 텍스트 색상 계산
    final contrastColor =
        (schedule.color.red * 0.299 +
                    schedule.color.green * 0.587 +
                    schedule.color.blue * 0.114) >
                155
            ? Colors.black
            : Colors.white;

    return Positioned(
      top: startOffset,
      left: leftOffset,
      width: dayColumnWidth - 4, // 약간의 마진
      height: height > 0 ? height : 10, // 최소 높이 10px
      child: GestureDetector(
        onTap: () => _showScheduleDetailDialog(context, schedule),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: schedule.color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시간 표시
              Text(
                '${ScheduleDateUtils.formatTime(schedule.startTime)}-${ScheduleDateUtils.formatTime(schedule.endTime)}',
                style: TextStyle(
                  fontSize: 10,
                  color: contrastColor.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              // 일정 제목
              Flexible(
                child: Text(
                  schedule.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: contrastColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 현재 시간 표시기
  Widget _buildCurrentTimeIndicator(
    List<DateTime> weekDates,
    double dayColumnWidth,
  ) {
    final now = DateTime.now();

    // 현재 날짜가 표시된 주간 내에 있는지 확인
    int dayIndex = -1;
    for (int i = 0; i < weekDates.length; i++) {
      if (ScheduleDateUtils.isSameDay(now, weekDates[i])) {
        dayIndex = i;
        break;
      }
    }

    // 오늘 날짜가 표시된 주간에 없으면 표시하지 않음
    if (dayIndex == -1) return Container();

    // 현재 시간이 표시 범위 내에 있는지 확인
    final currentHour = now.hour + (now.minute / 60.0);
    if (currentHour < _startHour || currentHour > _endHour) {
      return Container();
    }

    // 위치 계산
    final topOffset = (currentHour - _startHour) * _hourHeight;
    final leftOffset = 60.0; // 시간 레이블 60px

    return Positioned(
      top: topOffset,
      left: leftOffset,
      right: 0,
      child: Container(
        height: 2,
        color: Colors.red,
        child: Row(
          children: [
            Container(
              width: dayColumnWidth * dayIndex,
              color: Colors.transparent,
            ),
            Container(
              width: dayColumnWidth,
              color: Colors.red.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // 날짜 선택 다이얼로그
  Future<void> _selectDate(
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

  // 일정 상세 정보 다이얼로그
  void _showScheduleDetailDialog(BuildContext context, ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(schedule.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 일정 시간
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${schedule.startTime.month}월 ${schedule.startTime.day}일 '
                    '${ScheduleDateUtils.formatTime(schedule.startTime)} - ${ScheduleDateUtils.formatTime(schedule.endTime)}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 일정 설명
              const Text('설명:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                schedule.description.isEmpty ? '설명 없음' : schedule.description,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  // 일간 뷰로 이동
  void _navigateToDaily(BuildContext context, DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParentScheduleView(initialDate: date),
      ),
    );
  }

  // 오류 화면
  Widget buildErrorWidget(BuildContext context, ScheduleViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '시간표 로드 중 문제가 발생했습니다',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${viewModel.error}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // 오류 초기화
              viewModel.clearError();

              // AuthViewModel 다시 불러오기
              final authViewModel = Provider.of<AuthViewModel>(
                context,
                listen: false,
              );

              // 완전히 초기화
              await viewModel.initialize(authViewModel: authViewModel);
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
