import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 학원 관리자 시간표 화면
class AcademyScheduleView extends StatefulWidget {
  const AcademyScheduleView({super.key});

  @override
  State<AcademyScheduleView> createState() => _AcademyScheduleViewState();
}

class _AcademyScheduleViewState extends State<AcademyScheduleView> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 임시 수업 일정 데이터
  final Map<DateTime, List<ClassSchedule>> _scheduleEvents = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // 임시 데이터 초기화
    _initializeScheduleData();
  }

  void _initializeScheduleData() {
    // 현재 날짜 기준으로 이번 주 수업 데이터 생성
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 위젯이 여전히 트리에 마운트되어 있는지 확인 (비동기 작업 전에 체크)
    if (!mounted) return;

    // 오늘 수업
    _scheduleEvents[today] = [
      ClassSchedule(
        className: '수학 기초반',
        startTime: '14:00',
        endTime: '15:30',
        teacher: '김영희',
        classroom: '제1교실',
        color: Colors.blue,
      ),
      ClassSchedule(
        className: '영어 중급반',
        startTime: '16:00',
        endTime: '17:30',
        teacher: '박철수',
        classroom: '제2교실',
        color: Colors.green,
      ),
      ClassSchedule(
        className: '과학 실험반',
        startTime: '18:00',
        endTime: '19:30',
        teacher: '이지훈',
        classroom: '실험실',
        color: Colors.orange,
      ),
    ];

    // 내일 수업
    final tomorrow = today.add(const Duration(days: 1));
    _scheduleEvents[tomorrow] = [
      ClassSchedule(
        className: '국어 고급반',
        startTime: '15:00',
        endTime: '16:30',
        teacher: '정은지',
        classroom: '제3교실',
        color: Colors.purple,
      ),
      ClassSchedule(
        className: '코딩 기초반',
        startTime: '17:00',
        endTime: '18:30',
        teacher: '최민수',
        classroom: '컴퓨터실',
        color: Colors.teal,
      ),
    ];

    // 어제 수업
    final yesterday = today.subtract(const Duration(days: 1));
    _scheduleEvents[yesterday] = [
      ClassSchedule(
        className: '미술 창작반',
        startTime: '14:30',
        endTime: '16:00',
        teacher: '김미정',
        classroom: '미술실',
        color: Colors.pink,
      ),
      ClassSchedule(
        className: '영어 회화반',
        startTime: '16:30',
        endTime: '18:00',
        teacher: '박철수',
        classroom: '제2교실',
        color: Colors.indigo,
      ),
    ];
  }

  List<ClassSchedule> _getScheduleForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _scheduleEvents[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendar(),
        const Divider(height: 1),
        Expanded(
          child:
              _selectedDay == null
                  ? const Center(child: Text('날짜를 선택하세요'))
                  : _buildScheduleList(),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      eventLoader: _getScheduleForDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: const CalendarStyle(
        markersMaxCount: 3,
        markersAlignment: Alignment.bottomCenter,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;

          return Positioned(
            bottom: 1,
            child: Container(
              width:
                  (6 * events.length > 18 ? 18 : 6 * events.length).toDouble(),
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleList() {
    final schedules = _getScheduleForDay(_selectedDay!);

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '${_selectedDay!.month}월 ${_selectedDay!.day}일에 예정된 수업이 없습니다',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddScheduleDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('수업 추가하기'),
            ),
          ],
        ),
      );
    }

    // 시간순으로 정렬
    schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 80,
            top: 8,
            left: 16,
            right: 16,
          ),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return _buildScheduleItem(schedule, index);
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddScheduleDialog(context),
            tooltip: '수업 추가',
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(ClassSchedule schedule, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showScheduleDetails(schedule),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: schedule.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          schedule.className,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        _buildMoreMenu(schedule),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${schedule.startTime} - ${schedule.endTime}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${schedule.teacher} 선생님',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.room, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          schedule.classroom,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMenu(ClassSchedule schedule) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditScheduleDialog(schedule);
            break;
          case 'delete':
            _showDeleteConfirmation(schedule);
            break;
          case 'attendance':
            _navigateToAttendance(schedule);
            break;
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('수정'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'attendance',
              child: Row(
                children: [
                  Icon(Icons.people, size: 18),
                  SizedBox(width: 8),
                  Text('출석부'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('삭제', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
    );
  }

  void _showScheduleDetails(ClassSchedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: schedule.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    schedule.className,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailItem(
                Icons.access_time,
                '수업 시간',
                '${schedule.startTime} - ${schedule.endTime}',
              ),
              _buildDetailItem(
                Icons.person,
                '담당 교사',
                '${schedule.teacher} 선생님',
              ),
              _buildDetailItem(Icons.room, '강의실', schedule.classroom),
              _buildDetailItem(
                Icons.calendar_today,
                '수업 날짜',
                '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditScheduleDialog(schedule);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('수정'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToAttendance(schedule);
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('출석부'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(schedule);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('삭제'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context) {
    // 임시 기능: 스낵바 메시지만 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showEditScheduleDialog(ClassSchedule schedule) {
    // 임시 기능: 스낵바 메시지만 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showDeleteConfirmation(ClassSchedule schedule) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('수업 삭제'),
            content: Text('${schedule.className} 수업을 정말 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  // 임시 기능: 스낵바 메시지만 표시
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이 기능은 준비 중입니다')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  void _navigateToAttendance(ClassSchedule schedule) {
    // 임시 기능: 스낵바 메시지만 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }
}

/// 수업 일정 데이터 모델
class ClassSchedule {
  final String className;
  final String startTime;
  final String endTime;
  final String teacher;
  final String classroom;
  final Color color;

  ClassSchedule({
    required this.className,
    required this.startTime,
    required this.endTime,
    required this.teacher,
    required this.classroom,
    required this.color,
  });
}
