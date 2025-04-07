import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 학부모용 시간표 화면
class ParentScheduleView extends StatefulWidget {
  final DateTime? initialDate;

  const ParentScheduleView({this.initialDate, super.key});

  @override
  State<ParentScheduleView> createState() => _ParentScheduleViewState();
}

class _ParentScheduleViewState extends State<ParentScheduleView> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  // 임시 데이터 - 자녀별 수업 일정
  final Map<String, List<Map<String, dynamic>>> _childrenSchedules = {
    '김민준': [
      {
        'title': '수학 기초반',
        'location': '중앙학원 301호',
        'startTime': '14:00',
        'endTime': '15:30',
        'day': 1, // 월요일
        'color': Colors.blue,
      },
      {
        'title': '영어 중급반',
        'location': '영어마을 2층',
        'startTime': '16:00',
        'endTime': '17:30',
        'day': 3, // 수요일
        'color': Colors.green,
      },
      {
        'title': '과학 실험반',
        'location': '중앙학원 과학실',
        'startTime': '15:00',
        'endTime': '16:30',
        'day': 5, // 금요일
        'color': Colors.orange,
      },
    ],
    '김서연': [
      {
        'title': '코딩 기초반',
        'location': '코딩학원 1반',
        'startTime': '14:00',
        'endTime': '15:30',
        'day': 2, // 화요일
        'color': Colors.purple,
      },
      {
        'title': '미술 창작반',
        'location': '예술학원 A실',
        'startTime': '16:00',
        'endTime': '17:30',
        'day': 4, // 목요일
        'color': Colors.pink,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate ?? DateTime.now();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendar(),
        const Divider(height: 1),
        Expanded(child: _buildScheduleList()),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      eventLoader: _getSchedulesForDay,
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
      headerStyle: const HeaderStyle(
        formatButtonShowsNext: false,
        titleCentered: true,
        formatButtonVisible: true,
      ),
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
              width: 6.0 * events.length > 18.0 ? 18.0 : 6.0 * events.length,
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

  List<dynamic> _getSchedulesForDay(DateTime day) {
    // 해당 요일(1: 월요일, 7: 일요일)에 해당하는 수업 필터링
    int weekday = day.weekday; // 1 (월요일) ~ 7 (일요일)

    List<dynamic> schedules = [];

    // 모든 자녀의 해당 요일 수업 추가
    _childrenSchedules.forEach((childName, childSchedules) {
      final daySchedules =
          childSchedules
              .where((schedule) => schedule['day'] == weekday)
              .toList();
      for (var schedule in daySchedules) {
        // 각 자녀의 수업 정보에 자녀 이름 추가
        schedules.add({...schedule, 'childName': childName});
      }
    });

    return schedules;
  }

  Widget _buildScheduleList() {
    final schedules = _getSchedulesForDay(_selectedDay!);

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '이 날에는 수업이 없습니다',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 시간순으로 정렬
    schedules.sort((a, b) => a['startTime'].compareTo(b['startTime']));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _buildScheduleItem(schedule);
      },
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: schedule['color'],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule['title'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${schedule['startTime']} - ${schedule['endTime']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    schedule['childName'],
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  schedule['location'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // 수업 상세 정보 보기
                    _showClassDetails(context, schedule);
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('상세정보'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClassDetails(BuildContext context, Map<String, dynamic> schedule) {
    // 요일 이름 구하기
    final dayNames = ['', '월', '화', '수', '목', '금', '토', '일'];
    final dayName = dayNames[schedule['day']];

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
                  CircleAvatar(
                    backgroundColor: schedule['color'].withOpacity(0.2),
                    child: Icon(Icons.school, color: schedule['color']),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule['title'],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${schedule['childName']} 수업',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailItem(
                Icons.schedule,
                '수업 시간',
                '매주 $dayName요일 ${schedule['startTime']} - ${schedule['endTime']}',
              ),
              const SizedBox(height: 16),
              _buildDetailItem(Icons.location_on, '장소', schedule['location']),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
