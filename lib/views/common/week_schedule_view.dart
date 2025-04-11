import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../viewmodels/schedule_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/schedule_model.dart';
import '../../models/user_model.dart';

/// 주간 시간표 화면
class WeekScheduleView extends StatefulWidget {
  const WeekScheduleView({super.key});

  @override
  State<WeekScheduleView> createState() => _WeekScheduleViewState();
}

class _WeekScheduleViewState extends State<WeekScheduleView> {
  final CalendarController _calendarController = CalendarController();
  late ScheduleViewModel _scheduleViewModel;
  // 더블 탭 감지를 위한 타이머
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    // ViewModel 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _scheduleViewModel = Provider.of<ScheduleViewModel>(
        context,
        listen: false,
      );

      // 주간 뷰로 설정
      _scheduleViewModel.setViewType(ViewType.week);

      await _scheduleViewModel.initialize(authViewModel: authViewModel);
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // listen: false로 설정하여 setState 충돌 방지
    final scheduleViewModel = Provider.of<ScheduleViewModel>(
      context,
      listen: false,
    );

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
        // 헤더: 날짜 네비게이션 및 일정 추가 버튼
        _buildHeader(scheduleViewModel),

        // 주간 시간표 캘린더
        Expanded(
          child: Stack(
            children: [
              // 캘린더 기본 위젯
              SfCalendar(
                controller: _calendarController,
                view: CalendarView.week,
                firstDayOfWeek: 1, // 월요일부터 시작
                timeSlotViewSettings: const TimeSlotViewSettings(
                  startHour: 7,
                  endHour: 22,
                  timeFormat: 'HH:mm',
                  timeIntervalHeight: 60,
                  timeTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                headerHeight: 0, // 캘린더 자체 헤더 숨기기
                viewHeaderHeight: 40, // 요일 헤더 높이
                viewHeaderStyle: const ViewHeaderStyle(
                  backgroundColor: Colors.transparent, // 배경을 투명하게 설정
                  dayTextStyle: TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                  ),
                  dateTextStyle: TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                  ),
                ),
                appointmentBuilder: _appointmentBuilder,
                dataSource: _getCalendarDataSource(scheduleViewModel.schedules),
                onTap: _handleCalendarTap,
                onViewChanged: _handleViewChanged,
                todayHighlightColor: Theme.of(context).primaryColor,
                showNavigationArrow: false, // 네비게이션 화살표 숨기기
                cellBorderColor: Colors.grey.shade300,
              ),

              // 커스텀 요일 헤더 (GestureDetector 처리용)
              Positioned(
                top: 0,
                left: 60, // 시간 열 너비만큼 오른쪽으로 이동
                right: 0,
                height: 40, // viewHeaderHeight와 동일하게 설정
                child: _buildCustomViewHeader(scheduleViewModel),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 커스텀 요일 헤더 (GestureDetector 처리용)
  Widget _buildCustomViewHeader(ScheduleViewModel viewModel) {
    // 주간 날짜 목록
    final dates = viewModel.weekDates;
    if (dates.isEmpty) return const SizedBox.shrink();

    // 요일별 너비 계산
    final dayWidth = (MediaQuery.of(context).size.width - 60) / 7;

    return Row(
      children:
          dates.map((date) {
            // 요일 및 날짜 포맷
            final dayFormat = DateFormat('E', 'ko');
            final dateFormat = DateFormat('d', 'ko');

            final dayText = dayFormat.format(date);
            final dateText = '${dateFormat.format(date)}일';

            // 현재 날짜 및 선택된 날짜 확인
            final isToday =
                DateTime.now().year == date.year &&
                DateTime.now().month == date.month &&
                DateTime.now().day == date.day;

            final isSelected =
                viewModel.selectedDate.year == date.year &&
                viewModel.selectedDate.month == date.month &&
                viewModel.selectedDate.day == date.day;

            return GestureDetector(
              onTap: () {
                // 날짜 선택 처리
                viewModel.changeDate(date);
              },
              onDoubleTap: () {
                // 더블 탭 시 일간 뷰로 전환
                viewModel.changeDate(date);
                viewModel.setViewType(ViewType.day);
              },
              child: Container(
                width: dayWidth,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.blue.shade100
                          : isToday
                          ? Colors.blue.shade50
                          : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color: isToday ? Colors.blue : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color: isToday ? Colors.blue : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  // 캘린더 탭 이벤트 처리
  void _handleCalendarTap(CalendarTapDetails details) {
    if (!mounted) return;

    // setState 중 충돌 방지를 위해 마이크로태스크로 예약
    Future.microtask(() {
      if (!mounted) return;

      final scheduleViewModel = Provider.of<ScheduleViewModel>(
        context,
        listen: false,
      );

      if (details.targetElement == CalendarElement.appointment) {
        // 일정 탭 시 상세 정보 표시
        final ScheduleModel schedule = details.appointments!.first;
        _showScheduleDetailDialog(context, schedule);
      } else if (details.targetElement == CalendarElement.calendarCell) {
        // 빈 셀 탭 시 새 일정 추가
        if (details.date != null) {
          _showAddScheduleDialog(
            context,
            scheduleViewModel,
            initialDate: details.date,
          );
        }
      } else if (details.targetElement == CalendarElement.viewHeader) {
        // 요일 헤더 탭은 커스텀 레이어에서 처리하므로 여기서는 무시
      }
    });
  }

  // 뷰 변경 이벤트 처리
  void _handleViewChanged(ViewChangedDetails details) {
    if (!mounted) return;

    // 비동기적으로 처리하여 빌드 충돌 방지
    Future.microtask(() {
      if (!mounted) return;

      final scheduleViewModel = Provider.of<ScheduleViewModel>(
        context,
        listen: false,
      );
      if (details.visibleDates.isNotEmpty) {
        // 날짜 범위가 변경되면 뷰모델의 선택된 날짜 업데이트
        scheduleViewModel.changeDate(
          details.visibleDates[details.visibleDates.length ~/ 2],
        );
      }
    });
  }

  // 헤더 위젯 (날짜 네비게이션 + 추가 버튼)
  Widget _buildHeader(ScheduleViewModel viewModel) {
    final weekDates = viewModel.weekDates;
    final startDate =
        weekDates.isNotEmpty ? weekDates.first : viewModel.selectedDate;
    final endDate =
        weekDates.isNotEmpty ? weekDates.last : viewModel.selectedDate;

    final dateFormat = DateFormat('yyyy년 MM월 dd일', 'ko');
    final weekRangeText =
        '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          // 이전 주 버튼
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              // setState 충돌 방지
              Future.microtask(() => viewModel.previousDay());
            },
          ),

          // 날짜 범위 표시
          Expanded(
            child: Text(
              weekRangeText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // 다음 주 버튼
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              // setState 충돌 방지
              Future.microtask(() => viewModel.nextDay());
            },
          ),

          // 오늘 버튼
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              // setState 충돌 방지
              Future.microtask(() => viewModel.goToToday());
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: const Size(60, 36),
            ),
            child: const Text('오늘'),
          ),

          // 일정 추가 버튼
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // setState 충돌 방지
              Future.microtask(
                () => _showAddScheduleDialog(context, viewModel),
              );
            },
          ),
        ],
      ),
    );
  }

  // 캘린더 일정 데이터 소스
  _AppointmentDataSource _getCalendarDataSource(List<ScheduleModel> schedules) {
    List<Appointment> appointments = [];

    for (var schedule in schedules) {
      appointments.add(
        Appointment(
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          subject: schedule.title,
          color: schedule.color,
          notes: schedule.description,
          id: schedule, // ScheduleModel 객체 직접 저장
        ),
      );
    }

    return _AppointmentDataSource(appointments);
  }

  // 커스텀 일정 위젯 빌더
  Widget _appointmentBuilder(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final Appointment appointment = details.appointments.first;
    final ScheduleModel schedule = appointment.id as ScheduleModel;

    return Container(
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
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schedule.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (details.bounds.height > 30) // 높이가 충분하면 시간 표시
            Text(
              '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
        ],
      ),
    );
  }

  // 시간 표시 포맷
  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 일정 추가 다이얼로그
  Future<void> _showAddScheduleDialog(
    BuildContext context,
    ScheduleViewModel viewModel, {
    DateTime? initialDate,
  }) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedDate = initialDate ?? viewModel.selectedDate;
    TimeOfDay startTime = TimeOfDay.fromDateTime(selectedDate);
    TimeOfDay endTime = TimeOfDay(
      hour: startTime.hour + 1,
      minute: startTime.minute,
    );
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
                      // 날짜 선택
                      ListTile(
                        title: const Text('날짜'),
                        trailing: Text(
                          DateFormat(
                            'yyyy년 MM월 dd일',
                            'ko',
                          ).format(selectedDate),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            locale: const Locale('ko', 'KR'),
                          );
                          if (date != null && context.mounted) {
                            setState(() {
                              // 날짜만 업데이트하고 시간은 유지
                              startTime = TimeOfDay.fromDateTime(
                                DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  startTime.hour,
                                  startTime.minute,
                                ),
                              );
                              endTime = TimeOfDay.fromDateTime(
                                DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  endTime.hour,
                                  endTime.minute,
                                ),
                              );
                            });
                          }
                        },
                      ),
                      // 시작 시간 선택
                      ListTile(
                        title: const Text('시작 시간'),
                        trailing: Text(_formatTimeOfDay(startTime)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (time != null && context.mounted) {
                            setState(() {
                              startTime = time;
                              // 종료 시간이 시작 시간보다 빠르면 자동 조정
                              if (_timeToMinutes(endTime) <=
                                  _timeToMinutes(startTime)) {
                                endTime = TimeOfDay(
                                  hour: startTime.hour + 1,
                                  minute: startTime.minute,
                                );
                              }
                            });
                          }
                        },
                      ),
                      // 종료 시간 선택
                      ListTile(
                        title: const Text('종료 시간'),
                        trailing: Text(_formatTimeOfDay(endTime)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (time != null && context.mounted) {
                            setState(() {
                              endTime = time;
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
                        startTime.hour,
                        startTime.minute,
                      );

                      final endDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        endTime.hour,
                        endTime.minute,
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

  // TimeOfDay를 분으로 변환 (비교용)
  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }
}

// 캘린더 데이터 소스 클래스
class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
