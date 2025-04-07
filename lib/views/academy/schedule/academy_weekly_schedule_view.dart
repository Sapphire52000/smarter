import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodels/schedule_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../models/schedule_model.dart';
import '../../../models/user_model.dart';
import './academy_schedule_view.dart';
import './components/date_header_widget.dart';
import './components/week_day_header_widget.dart';
import './components/schedule_block_widget.dart';
import './components/current_time_indicator_widget.dart';

/// 학원 관리자 주간 시간표 화면
class AcademyWeeklyScheduleView extends StatefulWidget {
  const AcademyWeeklyScheduleView({super.key});

  @override
  State<AcademyWeeklyScheduleView> createState() =>
      _AcademyWeeklyScheduleViewState();
}

class _AcademyWeeklyScheduleViewState extends State<AcademyWeeklyScheduleView> {
  // 시간 그리드 상수
  final int _startHour = 7; // 오전 7시부터 시작
  final int _endHour = 22; // 오후 10시까지
  final double _hourHeight = 60.0; // 시간당 60픽셀 높이

  // 테마 색상
  late Color _primaryColor;
  late Color _accentColor;
  late Color _backgroundColor;
  late Color _surfaceColor;
  late Color _timeIndicatorColor;
  late Color _textColor;
  bool _isDarkMode = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateThemeColors();
  }

  void _updateThemeColors() {
    final brightness = Theme.of(context).brightness;
    _isDarkMode = brightness == Brightness.dark;

    if (_isDarkMode) {
      // 다크 테마 색상
      _primaryColor = const Color(0xFF5A5E7A); // 어두운 블루-그레이
      _accentColor = const Color(0xFFEF8354); // 코랄
      _backgroundColor = const Color(0xFF121212); // 어두운 배경
      _surfaceColor = const Color(0xFF242424); // 어두운 표면
      _timeIndicatorColor = const Color(0xFFEF6461); // 부드러운 레드
      _textColor = Colors.white;
    } else {
      // 라이트 테마 색상
      _primaryColor = const Color(0xFF2D3142); // 다크 블루-그레이
      _accentColor = const Color(0xFFEF8354); // 코랄
      _backgroundColor = Colors.white;
      _surfaceColor = const Color(0xFFF9F9F9); // 라이트 그레이
      _timeIndicatorColor = const Color(0xFFEF6461); // 부드러운 레드
      _textColor = Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleViewModel = Provider.of<ScheduleViewModel>(context);

    if (scheduleViewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (scheduleViewModel.error != null) {
      return Scaffold(
        body: Center(
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
        ),
      );
    }

    // weekDates가 비어있는지 확인
    if (scheduleViewModel.weekDates.isEmpty) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: Text(
            '주간 시간표',
            style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: _backgroundColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('일정 데이터를 불러오는 중입니다...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          '주간 시간표',
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          // 오늘 버튼
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: Icon(Icons.today, color: _primaryColor, size: 20),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              onPressed: () => scheduleViewModel.goToToday(),
              tooltip: '오늘',
            ),
          ),
          // 일정 추가 버튼
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              onPressed: () {
                _showAddScheduleDialog(context, scheduleViewModel);
              },
              tooltip: '일정 추가',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 주간 날짜 선택 바
          _buildWeeklyScheduleHeader(scheduleViewModel),
          // 주간 시간표 그리드
          Expanded(child: _buildWeeklyScheduleGrid(scheduleViewModel)),
        ],
      ),
    );
  }

  // 주간 네비게이션 바
  Widget _buildWeeklyScheduleHeader(ScheduleViewModel viewModel) {
    final List<DateTime> weekDates = viewModel.weekDates;
    final DateTime selectedDate = viewModel.selectedDate;

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _backgroundColor,
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
            onPrevious: () => viewModel.previousDay(),
            onNext: () => viewModel.nextDay(),
            onToday: () => viewModel.goToToday(),
            onDateTap: () => _showMonthPicker(), // 월 선택 다이얼로그
            primaryColor: _primaryColor,
          ),
          const SizedBox(height: 8),
          // 요일 표시
          WeekDayHeaderWidget(
            viewModel: viewModel,
            onDateTap: (date) {
              // 선택한 날짜로 변경
              viewModel.changeDate(date);
            },
            onDateDoubleTap: (date) {
              // 선택한 날짜로 변경
              viewModel.changeDate(date);

              // 일간 뷰로 이동 (선택한 날짜 전달)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AcademyScheduleView(initialDate: date),
                ),
              );
            },
            primaryColor: _primaryColor,
            surfaceColor: _surfaceColor,
            timeIndicatorColor: _timeIndicatorColor,
            textColor: _textColor,
          ),
        ],
      ),
    );
  }

  // 주간 시간표 그리드
  Widget _buildWeeklyScheduleGrid(ScheduleViewModel viewModel) {
    final List<DateTime> weekDates = viewModel.weekDates;

    // 날짜 목록이 비어있으면 빈 컨테이너 반환
    if (weekDates.isEmpty) {
      return Container();
    }

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
                  child: Column(
                    children: List.generate(_endHour - _startHour + 1, (index) {
                      final hour = _startHour + index;
                      final timeString = DateFormat(
                        'HH',
                        'ko',
                      ).format(DateTime(2022, 1, 1, hour));

                      return SizedBox(
                        height: _hourHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 시간 레이블
                            SizedBox(
                              width: 60,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  top: 4,
                                ),
                                child: Text(
                                  timeString,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                            // 요일별 그리드 셀
                            ...List.generate(7, (dayIndex) {
                              return Container(
                                width: dayColumnWidth,
                                height: _hourHeight,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                    left: BorderSide(
                                      color: Colors.grey[100]!,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
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
      if (_isSameDay(schedule.startTime, weekDates[i])) {
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

    return Positioned(
      top: startOffset,
      left: leftOffset,
      width: dayColumnWidth - 4, // 약간의 마진
      height: height > 0 ? height : 10, // 최소 높이 10px
      child: ScheduleBlockWidget(
        schedule: schedule,
        onTap: (schedule) => _showScheduleDetailDialog(context, schedule),
        height: height,
        width: dayColumnWidth - 4,
      ),
    );
  }

  // 현재 시간 표시기 위젯
  Widget _buildCurrentTimeIndicator(
    List<DateTime> weekDates,
    double dayColumnWidth,
  ) {
    return CurrentTimeIndicatorWidget(
      weekDates: weekDates,
      dayColumnWidth: dayColumnWidth,
      startHour: _startHour,
      hourHeight: _hourHeight,
      timeIndicatorColor: _timeIndicatorColor,
    );
  }

  // 배경색에 따른 텍스트 색상 계산
  Color _getContrastColor(Color backgroundColor) {
    // 밝기 계산 (표준 공식 사용)
    double brightness =
        (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) /
        1000;

    // 어두운 색상은 흰색, 밝은 색상은 검은색 반환
    return brightness > 160 ? Colors.black : Colors.white;
  }

  // 시간 포맷팅
  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // 같은 날짜인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  // 일정 추가 다이얼로그
  void _showAddScheduleDialog(
    BuildContext context,
    ScheduleViewModel viewModel,
  ) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay initialStartTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay initialEndTime = const TimeOfDay(hour: 10, minute: 0);
    Color selectedColor = Colors.blue;
    String colorHex = '#4285F4'; // 기본 블루

    if (!context.mounted) return;

    showDialog(
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
                      final selectedDate = viewModel.selectedDate;
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

  // TimeOfDay 포맷
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // 일간 시간표와 동일한 방식으로 주차 표시 텍스트 생성하는 메서드 추가
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

  // 월 선택 다이얼로그 표시
  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Text(
                      '월 선택',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    final selectedDate =
                        Provider.of<ScheduleViewModel>(context).selectedDate;
                    final isCurrentMonth = month == selectedDate.month;

                    return GestureDetector(
                      onTap: () {
                        final year = selectedDate.year;
                        final newDate = DateTime(year, month, 1);
                        Navigator.pop(context);

                        final viewModel = Provider.of<ScheduleViewModel>(
                          context,
                          listen: false,
                        );
                        viewModel.changeDate(newDate);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isCurrentMonth
                                  ? _primaryColor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          DateFormat('MMM', 'ko').format(DateTime(2022, month)),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isCurrentMonth ? Colors.white : _textColor,
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
      },
    );
  }
}
