import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/schedule_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../models/schedule_model.dart';
import '../../../models/user_model.dart';
import '../../../views/schedule/components/schedule_grid_widget.dart';
import '../../../views/schedule/components/date_header_widget.dart';
import '../../../views/schedule/utils/date_utils.dart';

/// 선생님용 시간표 화면
class TeacherScheduleView extends StatefulWidget {
  final DateTime? initialDate;

  const TeacherScheduleView({this.initialDate, super.key});

  @override
  State<TeacherScheduleView> createState() => _TeacherScheduleViewState();
}

class _TeacherScheduleViewState extends State<TeacherScheduleView> {
  // 시간 그리드 상수
  final int _startHour = 7; // 오전 7시부터 시작
  final int _endHour = 22; // 오후 10시까지
  final List<TimeOfDay> _timeSlots = List.generate(
    16,
    (index) => TimeOfDay(hour: index + 7, minute: 0),
  );

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

      // ViewModel에 선택된 날짜 설정
      if (widget.initialDate != null) {
        scheduleViewModel.changeDate(widget.initialDate!);
      }

      // 뷰 타입을 일간으로 설정
      scheduleViewModel.setViewType(ViewType.day);

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

    return Column(
      children: [
        Container(
          color: Colors.blue.shade50,
          child: Column(
            children: [
              // 선생님용 컨트롤 버튼
              buildTeacherControls(scheduleViewModel),

              // 날짜 헤더
              DateHeaderWidget(
                viewModel: scheduleViewModel,
                onDatePickerTap: () => _selectDate(context, scheduleViewModel),
              ),
            ],
          ),
        ),

        // 시간표 그리드
        Expanded(
          child: ScheduleGridWidget(
            viewModel: scheduleViewModel,
            timeSlots: _timeSlots,
            onScheduleTap: (schedule) => _showScheduleDetail(context, schedule),
            onTimeSlotTap:
                (time) => _showAddScheduleDialog(
                  context,
                  scheduleViewModel,
                  initialTime: time,
                ),
          ),
        ),
      ],
    );
  }

  // 선생님용 컨트롤 버튼
  Widget buildTeacherControls(ScheduleViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 수업 목록 필터링 버튼
          IconButton(
            icon: const Icon(Icons.filter_list, size: 20),
            tooltip: '수업 필터링',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            onPressed: () {
              // 필터링 기능 (구현 필요)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('수업 필터링 기능은 개발 중입니다')),
              );
            },
          ),

          // 날짜 선택 버튼
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            tooltip: '날짜 선택',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            onPressed: () => _selectDate(context, viewModel),
          ),
        ],
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

  // 일정 상세 보기 (구현 필요)
  void _showScheduleDetail(BuildContext context, ScheduleModel schedule) {
    // 일정 상세 다이얼로그 표시 (구현 필요)
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(schedule.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시간: ${ScheduleDateUtils.formatTime(schedule.startTime)} - ${ScheduleDateUtils.formatTime(schedule.endTime)}',
                ),
                const SizedBox(height: 8),
                Text('설명: ${schedule.description}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
    );
  }

  // 일정 추가 다이얼로그 (구현 필요)
  void _showAddScheduleDialog(
    BuildContext context,
    ScheduleViewModel viewModel, {
    TimeOfDay? initialTime,
  }) {
    // 일정 추가 다이얼로그 표시 (구현 필요)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('일정 추가 기능은 개발 중입니다')));
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
