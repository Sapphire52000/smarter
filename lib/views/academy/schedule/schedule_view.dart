import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/schedule_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../models/schedule_model.dart';
import '../../../models/user_model.dart';
import '../../../views/schedule/components/schedule_grid_widget.dart';
import '../../../views/schedule/components/date_header_widget.dart';
import '../../../views/schedule/components/color_selector_widget.dart';
import '../../../views/schedule/utils/date_utils.dart';

/// 학원(Academy)용 시간표 화면
class AcademyScheduleView extends StatefulWidget {
  final DateTime? initialDate;

  const AcademyScheduleView({this.initialDate, super.key});

  @override
  State<AcademyScheduleView> createState() => _AcademyScheduleViewState();
}

class _AcademyScheduleViewState extends State<AcademyScheduleView> {
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
  String _selectedColorHex = '#4285F4'; // 기본 색상: 파란색
  Color _selectedColor = Colors.blue; // 기본 색상 객체

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

  // 일정 상세 보기 다이얼로그
  void _showScheduleDetail(BuildContext context, ScheduleModel schedule) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: schedule.color,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                ),
                Expanded(child: Text(schedule.title)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시간: ${ScheduleDateUtils.formatTime(schedule.startTime)} - ${ScheduleDateUtils.formatTime(schedule.endTime)}',
                ),
                const SizedBox(height: 8),
                Text('설명: ${schedule.description}'),
                const SizedBox(height: 8),
                Text('참가자: ${schedule.participants.length}명'),
              ],
            ),
            actions: [
              // 삭제 버튼
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDeleteSchedule(context, schedule);
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
              // 수정 버튼
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditScheduleDialog(context, schedule);
                },
                child: const Text('수정'),
              ),
              // 닫기 버튼
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
    );
  }

  // 일정 삭제 확인 다이얼로그
  void _confirmDeleteSchedule(BuildContext context, ScheduleModel schedule) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('일정 삭제'),
            content: Text('정말로 "${schedule.title}" 일정을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  // 일정 삭제 실행
                  final scheduleViewModel = Provider.of<ScheduleViewModel>(
                    context,
                    listen: false,
                  );
                  scheduleViewModel.deleteSchedule(schedule.id);
                  Navigator.pop(context);

                  // 성공 메시지
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('일정이 삭제되었습니다')));
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // 일정 수정 다이얼로그
  void _showEditScheduleDialog(BuildContext context, ScheduleModel schedule) {
    _titleController.text = schedule.title;
    _descriptionController.text = schedule.description;
    _startDateTime = schedule.startTime;
    _endDateTime = schedule.endTime;
    _selectedColorHex = schedule.colorHex;
    _selectedColor = schedule.color;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('일정 수정'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: '제목'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: '설명'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('시작 시간'),
                    subtitle: Text(
                      _startDateTime != null
                          ? '${_startDateTime?.year}년 ${_startDateTime?.month}월 ${_startDateTime?.day}일 ${_startDateTime?.hour}:${_startDateTime?.minute.toString().padLeft(2, '0')}'
                          : '선택하세요',
                    ),
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: _startDateTime ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null && context.mounted) {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            _startDateTime ?? DateTime.now(),
                          ),
                        );
                        if (time != null && context.mounted) {
                          setState(() {
                            _startDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('종료 시간'),
                    subtitle: Text(
                      _endDateTime != null
                          ? '${_endDateTime?.year}년 ${_endDateTime?.month}월 ${_endDateTime?.day}일 ${_endDateTime?.hour}:${_endDateTime?.minute.toString().padLeft(2, '0')}'
                          : '선택하세요',
                    ),
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: _endDateTime ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null && context.mounted) {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            _endDateTime ?? DateTime.now(),
                          ),
                        );
                        if (time != null && context.mounted) {
                          setState(() {
                            _endDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ColorSelectorWidget(
                    selectedColor: _selectedColor,
                    onColorSelected: (color, hex) {
                      setState(() {
                        _selectedColor = color;
                        _selectedColorHex = hex;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // 입력 필드 초기화
                  _resetInputFields();
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  // 일정 수정 저장
                  _saveEditedSchedule(context, schedule.id);
                },
                child: const Text('저장'),
              ),
            ],
          ),
    );
  }

  // 일정 추가 다이얼로그
  void _showAddScheduleDialog(
    BuildContext context,
    ScheduleViewModel viewModel, {
    TimeOfDay? initialTime,
  }) {
    // 입력 필드 초기화
    _resetInputFields();

    // 초기 시작 시간 설정
    final now = DateTime.now();
    if (initialTime != null) {
      _startDateTime = DateTime(
        viewModel.selectedDate.year,
        viewModel.selectedDate.month,
        viewModel.selectedDate.day,
        initialTime.hour,
        0,
      );
      _endDateTime = DateTime(
        viewModel.selectedDate.year,
        viewModel.selectedDate.month,
        viewModel.selectedDate.day,
        initialTime.hour + 1,
        0,
      );
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('새 일정 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: '제목'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: '설명'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('시작 시간'),
                    subtitle: Text(
                      _startDateTime != null
                          ? '${_startDateTime?.year}년 ${_startDateTime?.month}월 ${_startDateTime?.day}일 ${_startDateTime?.hour}:${_startDateTime?.minute.toString().padLeft(2, '0')}'
                          : '선택하세요',
                    ),
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: _startDateTime ?? viewModel.selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null && context.mounted) {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            _startDateTime ?? DateTime.now(),
                          ),
                        );
                        if (time != null && context.mounted) {
                          setState(() {
                            _startDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('종료 시간'),
                    subtitle: Text(
                      _endDateTime != null
                          ? '${_endDateTime?.year}년 ${_endDateTime?.month}월 ${_endDateTime?.day}일 ${_endDateTime?.hour}:${_endDateTime?.minute.toString().padLeft(2, '0')}'
                          : '선택하세요',
                    ),
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: _endDateTime ?? viewModel.selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null && context.mounted) {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            _endDateTime ??
                                DateTime.now().add(const Duration(hours: 1)),
                          ),
                        );
                        if (time != null && context.mounted) {
                          setState(() {
                            _endDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ColorSelectorWidget(
                    selectedColor: _selectedColor,
                    onColorSelected: (color, hex) {
                      setState(() {
                        _selectedColor = color;
                        _selectedColorHex = hex;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // 입력 필드 초기화
                  _resetInputFields();
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  // 새 일정 저장
                  _saveNewSchedule(context);
                },
                child: const Text('저장'),
              ),
            ],
          ),
    );
  }

  // 입력 필드 초기화
  void _resetInputFields() {
    _titleController.clear();
    _descriptionController.clear();
    _startDateTime = null;
    _endDateTime = null;
    _selectedColorHex = '#4285F4';
    _selectedColor = Colors.blue;
  }

  // 새 일정 저장
  void _saveNewSchedule(BuildContext context) {
    // 입력값 검증
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('시작 시간과 종료 시간을 모두 선택해주세요')));
      return;
    }

    if (_endDateTime!.isBefore(_startDateTime!)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('종료 시간은 시작 시간 이후여야 합니다')));
      return;
    }

    // 새 일정 생성 및 저장
    final scheduleViewModel = Provider.of<ScheduleViewModel>(
      context,
      listen: false,
    );

    scheduleViewModel.createSchedule(
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: _startDateTime!,
      endTime: _endDateTime!,
      colorHex: _selectedColorHex,
    );

    // 다이얼로그 닫기
    Navigator.pop(context);

    // 성공 메시지
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('새 일정이 추가되었습니다')));

    // 입력 필드 초기화
    _resetInputFields();
  }

  // 일정 수정 저장
  void _saveEditedSchedule(BuildContext context, String scheduleId) {
    // 입력값 검증
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('시작 시간과 종료 시간을 모두 선택해주세요')));
      return;
    }

    if (_endDateTime!.isBefore(_startDateTime!)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('종료 시간은 시작 시간 이후여야 합니다')));
      return;
    }

    // 일정 수정 저장
    final scheduleViewModel = Provider.of<ScheduleViewModel>(
      context,
      listen: false,
    );

    scheduleViewModel.editSchedule(
      id: scheduleId,
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: _startDateTime!,
      endTime: _endDateTime!,
      colorHex: _selectedColorHex,
    );

    // 다이얼로그 닫기
    Navigator.pop(context);

    // 성공 메시지
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('일정이 수정되었습니다')));

    // 입력 필드 초기화
    _resetInputFields();
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
