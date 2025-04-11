import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/schedule_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/schedule_model.dart';
import '../../models/user_model.dart';

/// 시간표 화면
class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  // 시간 범위 설정 (오전 7시부터 오후 10시까지)
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

      // 일간 뷰로 설정
      scheduleViewModel.setViewType(ViewType.day);

      await scheduleViewModel.initialize(authViewModel: authViewModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleViewModel = Provider.of<ScheduleViewModel>(context);

    if (scheduleViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scheduleViewModel.error != null) {
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
              '${scheduleViewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 오류 초기화
                scheduleViewModel.clearError();

                // AuthViewModel 다시 불러오기
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );

                // 완전히 초기화
                await scheduleViewModel.initialize(
                  authViewModel: authViewModel,
                );
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 버튼 섹션과 날짜 헤더를 하나의 컨테이너로 합침
        Container(
          color: Colors.blue.shade50,
          child: Column(
            children: [
              // 날짜 선택 및 일정 추가 버튼
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 4.0,
                ),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 2.0,
                  children: [
                    // 날짜 선택 버튼
                    IconButton(
                      icon: const Icon(Icons.calendar_today, size: 20),
                      tooltip: '날짜 선택',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () => _selectDate(context, scheduleViewModel),
                    ),
                    // 일정 추가 버튼
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      tooltip: '일정 추가',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed:
                          () => _showAddScheduleDialog(
                            context,
                            scheduleViewModel,
                          ),
                    ),
                  ],
                ),
              ),

              // 선택된 날짜 표시 및 날짜 네비게이션
              _buildDateHeader(scheduleViewModel),
            ],
          ),
        ),

        // 시간표 그리드
        Expanded(child: _buildScheduleGrid(scheduleViewModel)),
      ],
    );
  }

  // 날짜 헤더 위젯
  Widget _buildDateHeader(ScheduleViewModel viewModel) {
    final date = viewModel.selectedDate;
    final dateFormat = DateFormat('yyyy년 MM월 dd일 (EEE)', 'ko');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _selectDate(context, viewModel),
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

  // 시간표 그리드
  Widget _buildScheduleGrid(ScheduleViewModel viewModel) {
    final schedules = viewModel.getSchedulesForDate(viewModel.selectedDate);

    return Row(
      children: [
        // 왼쪽 시간 칼럼
        SizedBox(
          width: 60,
          child: ListView.builder(
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final time = _timeSlots[index];
              return Container(
                height: 60, // 1시간당 60픽셀
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Text(
                  '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              );
            },
          ),
        ),

        // 오른쪽 일정 컨테이너
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: Stack(
              children: [
                // 시간대 구분선
                ListView.builder(
                  itemCount: _timeSlots.length,
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
                ..._buildScheduleBlocks(schedules),

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
                      _showAddScheduleDialogWithTime(
                        context,
                        viewModel,
                        initialTime: selectedTime,
                      );
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: 60 * _timeSlots.length.toDouble(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 일정 블록 위젯들 생성
  List<Widget> _buildScheduleBlocks(List<ScheduleModel> schedules) {
    return schedules.map((schedule) {
      // 일정 시작 시간에 따른 위치 계산
      final startHour = schedule.startTime.hour;
      final startMinute = schedule.startTime.minute;
      final endHour = schedule.endTime.hour;
      final endMinute = schedule.endTime.minute;

      // 시작 시간과 시간표 시작 시간(7시)의 차이를 픽셀로 계산
      final top = (startHour - 7) * 60 + startMinute.toDouble();

      // 일정 지속 시간을 픽셀로 계산
      final duration =
          (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
      final height = duration.toDouble();

      return Positioned(
        top: top,
        left: 0,
        right: 0,
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: GestureDetector(
            onTap: () => _showScheduleDetailDialog(context, schedule),
            child: Container(
              decoration: BoxDecoration(
                color: schedule.color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3.0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (height > 30) // 충분히 높은 경우에만 추가 정보 표시
                    Text(
                      '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // 시간 표시 포맷
  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
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

  // 특정 시간으로 일정 추가 다이얼로그
  Future<void> _showAddScheduleDialogWithTime(
    BuildContext context,
    ScheduleViewModel viewModel, {
    required TimeOfDay initialTime,
  }) async {
    final selectedDate = viewModel.selectedDate;
    final startTime = initialTime;
    final endTime = TimeOfDay(
      hour: initialTime.hour + 1,
      minute: initialTime.minute,
    );

    _showAddScheduleDialog(
      context,
      viewModel,
      startTime: startTime,
      endTime: endTime,
    );
  }

  // 일정 추가 다이얼로그
  Future<void> _showAddScheduleDialog(
    BuildContext context,
    ScheduleViewModel viewModel, {
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedDate = viewModel.selectedDate;
    TimeOfDay initialStartTime =
        startTime ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay initialEndTime = endTime ?? const TimeOfDay(hour: 10, minute: 0);
    Color selectedColor = Colors.blue;
    String colorHex = '#4285F4'; // 기본 블루

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('일정 추가'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: '일정 제목'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: '일정 설명'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // 시작 시간 선택
                      ListTile(
                        title: const Text('시작 시간'),
                        trailing: Text(_formatTimeOfDay(initialStartTime)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: initialStartTime,
                          );
                          if (time != null && context.mounted) {
                            setState(() {
                              initialStartTime = time;
                            });
                          }
                        },
                      ),
                      // 종료 시간 선택
                      ListTile(
                        title: const Text('종료 시간'),
                        trailing: Text(_formatTimeOfDay(initialEndTime)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: initialEndTime,
                          );
                          if (time != null && context.mounted) {
                            setState(() {
                              initialEndTime = time;
                            });
                          }
                        },
                      ),
                      // 색상 선택
                      const SizedBox(height: 16),
                      const Text('일정 색상'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildColorOption(
                            Colors.blue,
                            '#4285F4',
                            selectedColor,
                            (color, hex) {
                              setState(() {
                                selectedColor = color;
                                colorHex = hex;
                              });
                            },
                          ),
                          _buildColorOption(
                            Colors.red,
                            '#EA4335',
                            selectedColor,
                            (color, hex) {
                              setState(() {
                                selectedColor = color;
                                colorHex = hex;
                              });
                            },
                          ),
                          _buildColorOption(
                            Colors.green,
                            '#34A853',
                            selectedColor,
                            (color, hex) {
                              setState(() {
                                selectedColor = color;
                                colorHex = hex;
                              });
                            },
                          ),
                          _buildColorOption(
                            Colors.amber,
                            '#FBBC05',
                            selectedColor,
                            (color, hex) {
                              setState(() {
                                selectedColor = color;
                                colorHex = hex;
                              });
                            },
                          ),
                          _buildColorOption(
                            Colors.purple,
                            '#A142F4',
                            selectedColor,
                            (color, hex) {
                              setState(() {
                                selectedColor = color;
                                colorHex = hex;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final authViewModel = Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      );

                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('일정 제목을 입력해주세요')),
                        );
                        return;
                      }

                      // 시작 및 종료 시간을 DateTime으로 변환
                      final startDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        initialStartTime.hour,
                        initialStartTime.minute,
                      );

                      final endDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        initialEndTime.hour,
                        initialEndTime.minute,
                      );

                      // 시간 유효성 검사
                      if (endDateTime.isBefore(startDateTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('종료 시간은 시작 시간보다 빠를 수 없습니다'),
                          ),
                        );
                        return;
                      }

                      // 새 일정 생성
                      final newSchedule = ScheduleModel.create(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        startTime: startDateTime,
                        endTime: endDateTime,
                        createdBy: authViewModel.user?.uid ?? '',
                        colorHex: colorHex,
                        participants: [authViewModel.user?.uid ?? ''],
                      );

                      Navigator.pop(context);

                      if (!context.mounted) return;

                      // 로딩 표시
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      // 일정 추가
                      await viewModel.addSchedule(newSchedule);

                      if (!context.mounted) return;
                      Navigator.pop(context); // 로딩 다이얼로그 닫기

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('일정이 추가되었습니다')),
                      );
                    },
                    child: const Text('추가'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // 색상 선택 옵션 위젯
  Widget _buildColorOption(
    Color color,
    String hex,
    Color selectedColor,
    Function(Color, String) onSelect,
  ) {
    final isSelected = color.value == selectedColor.value;

    return GestureDetector(
      onTap: () => onSelect(color, hex),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  // 일정 상세 정보 다이얼로그
  void _showScheduleDetailDialog(BuildContext context, ScheduleModel schedule) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final scheduleViewModel = Provider.of<ScheduleViewModel>(
      context,
      listen: false,
    );

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
                    '${DateFormat('yyyy.MM.dd', 'ko').format(schedule.startTime)}'
                    ' ${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}'
                    ' (${schedule.durationInMinutes ~/ 60}시간 ${schedule.durationInMinutes % 60}분)',
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
              const SizedBox(height: 16),
              // 생성 정보
              Text(
                '생성 일시: ${DateFormat('yyyy.MM.dd HH:mm').format(schedule.createdAt)}',
              ),
            ],
          ),
          actions: [
            // 삭제 버튼 (생성자 또는 관리자만 표시)
            if (schedule.createdBy == authViewModel.user?.uid ||
                authViewModel.user?.role == UserRole.academyOwner)
              TextButton(
                onPressed: () async {
                  // 삭제 확인 다이얼로그
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('일정 삭제'),
                          content: const Text('이 일정을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                '삭제',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirmed == true && context.mounted) {
                    Navigator.pop(context); // 상세 정보 다이얼로그 닫기

                    // 로딩 표시
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) =>
                              const Center(child: CircularProgressIndicator()),
                    );

                    // 일정 삭제
                    await scheduleViewModel.deleteSchedule(schedule.id);

                    if (!context.mounted) return;
                    Navigator.pop(context); // 로딩 다이얼로그 닫기

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('일정이 삭제되었습니다')),
                    );
                  }
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  // TimeOfDay 포맷
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
