import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/schedule_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../models/schedule_model.dart';
import '../../../views/schedule/components/schedule_grid_widget.dart';
import '../../../views/schedule/components/date_header_widget.dart';
import '../../../views/schedule/components/color_selector_widget.dart';
import '../../../views/schedule/utils/date_utils.dart';
import './components/dialogs/index.dart';

/// 학원(Academy)용 일간 시간표 화면
class AcademyDayScheduleView extends StatefulWidget {
  final DateTime? initialDate;

  const AcademyDayScheduleView({this.initialDate, super.key});

  @override
  State<AcademyDayScheduleView> createState() => _AcademyDayScheduleViewState();
}

class _AcademyDayScheduleViewState extends State<AcademyDayScheduleView> {
  // 시간 그리드 상수
  final int _startHour = 7; // 오전 7시부터 시작
  final int _endHour = 22; // 오후 10시까지
  final List<TimeOfDay> _timeSlots = List.generate(
    16,
    (index) => TimeOfDay(hour: index + 7, minute: 0),
  );

  // 새 일정 생성 관련 상태
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final String _selectedColorHex = '#4285F4'; // 기본 색상: 파란색
  final Color _selectedColor = Colors.blue; // 기본 색상 객체

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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          color: Colors.indigo.shade50,
          child: Column(
            children: [
              // 학원 관리자용 컨트롤 버튼
              buildAcademyControls(scheduleViewModel),

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

  // 학원 관리자용 컨트롤 버튼
  Widget buildAcademyControls(ScheduleViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽: 일정 필터링 옵션들
          Row(
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list, size: 20),
                tooltip: '필터',
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(value: 'all', child: Text('모든 일정')),
                      const PopupMenuItem(
                        value: 'classes',
                        child: Text('수업 일정만'),
                      ),
                      const PopupMenuItem(value: 'events', child: Text('이벤트만')),
                    ],
                onSelected: (value) {
                  // 필터 기능 구현 (추후 구현)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$value 필터가 선택되었습니다 (개발 중)')),
                  );
                },
              ),
              const SizedBox(width: 8),
              // 추가 필터 버튼들
            ],
          ),

          // 오른쪽: 일정 관리 버튼들
          Row(
            children: [
              // 새 일정 추가 버튼
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                tooltip: '새 일정 추가',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => _showAddScheduleDialog(context, viewModel),
              ),

              // 날짜 선택 버튼
              IconButton(
                icon: const Icon(Icons.calendar_today, size: 20),
                tooltip: '날짜 선택',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => _selectDate(context, viewModel),
              ),

              // 뷰 모드 전환 버튼
              IconButton(
                icon: const Icon(Icons.view_week, size: 20),
                tooltip: '주간/일간 보기 전환',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  viewModel.setViewType(
                    viewModel.currentViewType == ViewType.day
                        ? ViewType.week
                        : ViewType.day,
                  );
                },
              ),
            ],
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
    await selectDate(context, viewModel);
  }

  // 일정 상세 보기 다이얼로그
  void _showScheduleDetail(BuildContext context, ScheduleModel schedule) {
    final scheduleViewModel = Provider.of<ScheduleViewModel>(
      context,
      listen: false,
    );

    showScheduleDetailDialog(context, schedule, scheduleViewModel);
  }

  // 일정 추가 다이얼로그
  Future<void> _showAddScheduleDialog(
    BuildContext context,
    ScheduleViewModel viewModel, {
    TimeOfDay? initialTime,
  }) async {
    await showAddScheduleDialog(context, viewModel, initialTime: initialTime);
  }

  // 오류 표시 위젯
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
