import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../viewmodels/schedule_view_model.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../models/schedule_model.dart';
import '../../../models/user_model.dart';
import './academy_weekly_schedule_view.dart';

/// 학원 관리자 시간표 화면
class AcademyScheduleView extends StatefulWidget {
  final DateTime? initialDate; // 선택한 초기 날짜

  const AcademyScheduleView({this.initialDate, super.key});

  @override
  State<AcademyScheduleView> createState() => _AcademyScheduleViewState();
}

class _AcademyScheduleViewState extends State<AcademyScheduleView> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 시간 그리드 상수
  final int _startHour = 7; // 오전 7시부터 시작
  final int _endHour = 22; // 오후 10시까지
  final double _hourHeight = 60.0; // 시간당 60픽셀 높이

  // 현재 시간 표시기 타이머
  final DateTime _currentTime = DateTime.now();

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
    // 전달된 초기 날짜가 있으면 사용, 없으면 현재 날짜 사용
    _selectedDay = widget.initialDate ?? DateTime.now();
    _focusedDay = widget.initialDate ?? DateTime.now();

    // ViewModel 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final scheduleViewModel = Provider.of<ScheduleViewModel>(
        context,
        listen: false,
      );

      // ViewModel에도 선택된 날짜 설정
      if (widget.initialDate != null) {
        scheduleViewModel.changeDate(widget.initialDate!);
      }

      await scheduleViewModel.initialize(authViewModel: authViewModel);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Theme.of(context)를 안전하게 사용할 수 있는 위치
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

  void _toggleCalendarFormat() {
    setState(() {
      _calendarFormat =
          _calendarFormat == CalendarFormat.week
              ? CalendarFormat.month
              : CalendarFormat.week;
    });
  }

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
                    final isCurrentMonth = month == _focusedDay.month;

                    return GestureDetector(
                      onTap: () {
                        final newDate = DateTime(_focusedDay.year, month, 1);
                        Navigator.pop(context);
                        setState(() {
                          _focusedDay = newDate;
                          // 선택된 날짜가 이 달에 없으면 1일로 설정
                          if (_selectedDay.month != month) {
                            _selectedDay = newDate;
                          }
                        });
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

  @override
  Widget build(BuildContext context) {
    final scheduleViewModel = Provider.of<ScheduleViewModel>(context);
    // 중복 호출 제거
    // _updateThemeColors();

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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: _backgroundColor,
        foregroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
          tooltip: '주간 보기로 돌아가기',
        ),
        leadingWidth: 56, // leading 영역 폭 조정
        title: GestureDetector(
          onTap: _showMonthPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('yyyy년 MM월', 'ko').format(_focusedDay),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16, // 폰트 크기 축소
                  color: _primaryColor,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 18, color: _primaryColor),
            ],
          ),
        ),
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
              onPressed: () {
                setState(() {
                  _selectedDay = DateTime.now();
                  _focusedDay = DateTime.now();
                });
              },
              tooltip: '오늘',
            ),
          ),
          // 캘린더 뷰 전환 버튼
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: Icon(
                _calendarFormat == CalendarFormat.week
                    ? Icons.calendar_view_month
                    : Icons.calendar_view_week,
                color: _primaryColor,
                size: 20,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              onPressed: _toggleCalendarFormat,
              tooltip:
                  _calendarFormat == CalendarFormat.week
                      ? '월간 보기로 전환'
                      : '주간 보기로 전환',
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
          // 상단에 구분선 추가
          Container(height: 1, color: Colors.grey[200]),
          Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1.0),
              ),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                // 페이지가 변경되면 포커스 날짜 업데이트
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return scheduleViewModel.getSchedulesForDate(day);
              },
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                // 오늘 날짜 원은 밝은 회색
                todayDecoration: BoxDecoration(
                  color: _surfaceColor,
                  shape: BoxShape.circle,
                ),
                // 선택된 날짜 원은 기본 색상
                selectedDecoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: TextStyle(color: _primaryColor),
                weekendTextStyle: TextStyle(
                  color: _primaryColor.withOpacity(0.7),
                ),
                outsideTextStyle: const TextStyle(color: Colors.grey),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(fontSize: 0), // 제목 숨기기
                leftChevronIcon: Icon(Icons.chevron_left, color: _primaryColor),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: _primaryColor,
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 4.0),
                // 헤더 중앙에 주차 정보 표시
                headerMargin: const EdgeInsets.only(bottom: 8.0),
              ),
              // 헤더 빌더 추가하여 주차 정보 표시
              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, day) {
                  // 캘린더 포맷이 주간일 때만 표시
                  if (_calendarFormat == CalendarFormat.week) {
                    // 해당 주의 월요일 찾기
                    final monday = day.subtract(
                      Duration(days: day.weekday - 1),
                    );
                    // 해당 월의 첫 날
                    final firstDayOfMonth = DateTime(day.year, day.month, 1);
                    // 해당 월의 첫 번째 월요일 찾기
                    final firstMonday = firstDayOfMonth.subtract(
                      Duration(days: (firstDayOfMonth.weekday - 1) % 7),
                    );
                    // 첫 번째 월요일이 해당 월보다 이전이면 다음 주 월요일을 첫 주차로 계산
                    final adjustedFirstMonday =
                        firstMonday.month < firstDayOfMonth.month
                            ? firstMonday.add(const Duration(days: 7))
                            : firstMonday;

                    // 주차 계산
                    final int weekDiff =
                        monday.difference(adjustedFirstMonday).inDays ~/ 7 + 1;

                    // 월이 바뀌는 주인 경우
                    final String monthText =
                        monday.month !=
                                monday.add(const Duration(days: 6)).month
                            ? '${DateFormat('M월', 'ko').format(monday)} - ${DateFormat('M월', 'ko').format(monday.add(const Duration(days: 6)))}'
                            : DateFormat('M월', 'ko').format(monday);

                    return Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Text(
                        '$monthText $weekDiff주차',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              locale: 'ko_KR',
            ),
          ),
          Expanded(child: _buildScheduleGrid(scheduleViewModel)),
        ],
      ),
    );
  }

  // 시간표 그리드 위젯
  Widget _buildScheduleGrid(ScheduleViewModel viewModel) {
    final schedules = viewModel.getSchedulesForDate(_selectedDay);

    // 일정이 없는 경우
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(
              '이 날짜에는 일정이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: _primaryColor.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _showAddScheduleDialog(context, viewModel);
              },
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
                backgroundColor: _surfaceColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '일정 추가',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // 시간순으로 일정 정렬
    schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    // 하루 전체를 위한 총 높이 계산
    final totalHeight = (_endHour - _startHour + 1) * _hourHeight;

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
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
                    child: Column(
                      children: [
                        // 시간 라인
                        Container(
                          height: _hourHeight / 2,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              Expanded(child: Container()),
                            ],
                          ),
                        ),
                        // 30분 라인 (더 얇게)
                        Container(
                          height: _hourHeight / 2,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey[100]!,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 60),
                              Expanded(child: Container()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // 일정 블록들
            ...schedules.map((schedule) => _buildScheduleBlock(schedule)),

            // 현재 시간 표시기 (오늘의 경우에만)
            if (isSameDay(_selectedDay, DateTime.now()))
              _buildCurrentTimeIndicator(),
          ],
        ),
      ),
    );
  }

  // 일정 블록 위젯
  Widget _buildScheduleBlock(ScheduleModel schedule) {
    // 시간 포맷
    final String timeRangeString =
        '${_formatTime(schedule.startTime)} ~ ${_formatTime(schedule.endTime)}';

    // 위치 및 높이 계산
    final startHourDecimal =
        schedule.startTime.hour + (schedule.startTime.minute / 60.0);
    final endHourDecimal =
        schedule.endTime.hour + (schedule.endTime.minute / 60.0);

    final startOffset = (startHourDecimal - _startHour) * _hourHeight;
    final height = (endHourDecimal - startHourDecimal) * _hourHeight;

    // 일정 지속 시간 계산
    final int durationMinutes = schedule.durationInMinutes;
    final String durationText =
        durationMinutes >= 60
            ? '${durationMinutes ~/ 60}시간${durationMinutes % 60 > 0 ? ' ${durationMinutes % 60}분' : ''}'
            : '$durationMinutes분';

    return Positioned(
      top: startOffset,
      left: 60, // 시간 레이블 이후
      right: 16,
      height: height,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        decoration: BoxDecoration(
          color: schedule.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              _showScheduleDetailDialog(context, schedule);
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 크기에 맞게 내용 표시
                  final bool isShortBlock = constraints.maxHeight < 50;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 레이아웃 변경: 지속시간, 시간 범위, 그리고 일정 제목
                      if (!isShortBlock) ...[
                        Row(
                          children: [
                            // 지속 시간 배지
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getOverlayColor(schedule.color),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                durationText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: _getContrastColor(schedule.color),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 시간 범위
                            Text(
                              timeRangeString,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getContrastColor(schedule.color),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],

                      // 일정 제목 (크고 굵게)
                      Text(
                        schedule.title,
                        style: TextStyle(
                          fontSize: isShortBlock ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: _getContrastColor(schedule.color),
                        ),
                        maxLines: isShortBlock ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 설명은 짧게만 표시
                      if (schedule.description.isNotEmpty &&
                          !isShortBlock &&
                          constraints.maxHeight > 70)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            schedule.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getContrastColor(
                                schedule.color,
                              ).withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 현재 시간 표시기 위젯
  Widget _buildCurrentTimeIndicator() {
    // 현재 시간 기준 위치 계산
    final now = DateTime.now();
    final currentHourDecimal = now.hour + (now.minute / 60.0);

    // 시각화 가능한 범위 안에 있는 경우에만 표시
    if (currentHourDecimal < _startHour || currentHourDecimal > _endHour) {
      return Container(); // 시각화 범위 밖이면 표시하지 않음
    }

    final topOffset = (currentHourDecimal - _startHour) * _hourHeight;
    final timeString = _formatTime(now);

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Row(
        children: [
          // 시간 레이블
          Container(
            width: 60,
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Text(
              timeString,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _timeIndicatorColor,
              ),
            ),
          ),
          // 빨간 선
          Expanded(child: Container(height: 2, color: _timeIndicatorColor)),
        ],
      ),
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

  // 배지/태그에 사용할 오버레이 색상 생성
  Color _getOverlayColor(Color baseColor) {
    // 약간 투명한 색상 생성
    return baseColor.withOpacity(0.7);
  }

  // 시간 포맷팅
  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // 일정 추가 다이얼로그
  Future<void> _showAddScheduleDialog(
    BuildContext context,
    ScheduleViewModel viewModel,
  ) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay initialStartTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay initialEndTime = const TimeOfDay(hour: 10, minute: 0);
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
                        _selectedDay.year,
                        _selectedDay.month,
                        _selectedDay.day,
                        initialStartTime.hour,
                        initialStartTime.minute,
                      );

                      final endDateTime = DateTime(
                        _selectedDay.year,
                        _selectedDay.month,
                        _selectedDay.day,
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
}
