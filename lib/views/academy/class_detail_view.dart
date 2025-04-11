import 'package:flutter/material.dart';
import './academy_classes_view.dart'; // ClassData와 StudentData 모델이 포함된 파일

// 출석 상태 열거형
enum AttendanceStatus {
  present, // 출석
  absent, // 결석
  late, // 지각
  excused, // 사유 결석
  unknown, // 미확인
}

/// 수업 상세 보기 화면
class ClassDetailView extends StatefulWidget {
  final ClassData classData;

  const ClassDetailView({super.key, required this.classData});

  @override
  State<ClassDetailView> createState() => _ClassDetailViewState();
}

class _ClassDetailViewState extends State<ClassDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _classroomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 초기 값 설정
    _nameController.text = widget.classData.name;
    _teacherController.text = widget.classData.teacher;
    _classroomController.text = widget.classData.classroom;
    _descriptionController.text = ''; // 설명 필드가 모델에 없으므로 빈 값으로 초기화
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _teacherController.dispose();
    _classroomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '수업 정보 수정' : '수업 상세 정보'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: '기본 정보'),
            Tab(icon: Icon(Icons.people), text: '학생 관리'),
            Tab(icon: Icon(Icons.event_note), text: '출석부'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildStudentsTab(),
          _buildAttendanceTab(),
        ],
      ),
    );
  }

  // 기본 정보 탭
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 수업 정보 카드
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '수업 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 수업명
                  _isEditing
                      ? TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '수업명',
                          border: OutlineInputBorder(),
                        ),
                      )
                      : _buildInfoRow('수업명', widget.classData.name),
                  const SizedBox(height: 12),

                  // 담당 선생님
                  _isEditing
                      ? TextField(
                        controller: _teacherController,
                        decoration: const InputDecoration(
                          labelText: '담당 선생님',
                          border: OutlineInputBorder(),
                        ),
                      )
                      : _buildInfoRow('담당 선생님', widget.classData.teacher),
                  const SizedBox(height: 12),

                  // 교실
                  _isEditing
                      ? TextField(
                        controller: _classroomController,
                        decoration: const InputDecoration(
                          labelText: '교실',
                          border: OutlineInputBorder(),
                        ),
                      )
                      : _buildInfoRow('교실', widget.classData.classroom),
                  const SizedBox(height: 12),

                  // 수업 일정
                  _buildInfoRow(
                    '수업 일정',
                    '${widget.classData.dayOfWeek} ${widget.classData.timeSlot}',
                  ),
                  const SizedBox(height: 12),

                  // 수업 설명
                  _isEditing
                      ? TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '수업 설명',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      )
                      : _buildInfoRow(
                        '수업 설명',
                        _descriptionController.text.isEmpty
                            ? '(설명 없음)'
                            : _descriptionController.text,
                      ),
                ],
              ),
            ),
          ),

          // 추가 정보 카드 (정규수업 여부 등)
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '추가 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 정규 수업 여부
                  Row(
                    children: [
                      const Text(
                        '정규 수업:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      widget.classData.isRegularClass
                          ? const Chip(
                            label: Text('정규'),
                            backgroundColor: Colors.blue,
                            labelStyle: TextStyle(color: Colors.white),
                          )
                          : const Chip(
                            label: Text('비정규'),
                            backgroundColor: Colors.grey,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                    ],
                  ),

                  // 학생 수
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    '등록된 학생 수',
                    '${widget.classData.studentCount}명',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 학생 관리 탭
  Widget _buildStudentsTab() {
    return Column(
      children: [
        // 학생 검색 및 추가 영역
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '학생 검색',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // 학생 추가 다이얼로그 표시
                  _showAddStudentDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('학생 추가'),
              ),
            ],
          ),
        ),

        // 학생 목록
        Expanded(
          child: ListView.builder(
            itemCount: widget.classData.studentsList.length,
            itemBuilder: (context, index) {
              final student = widget.classData.studentsList[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(student.name.substring(0, 1)),
                ),
                title: Text(student.name),
                subtitle: Text(student.grade),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // 학생 제거 확인 다이얼로그
                    _showRemoveStudentDialog(student);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 출석부 탭
  Widget _buildAttendanceTab() {
    // 현재 월의 수업 날짜 계산 (dayOfWeek 기반)
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final List<DateTime> classDateList = _getClassDatesForMonth(
      currentYear,
      currentMonth,
    );

    // 선택된 날짜 (기본값: 오늘 또는 가장 가까운 수업일)
    final today = DateTime.now();
    DateTime selectedDate =
        classDateList.isNotEmpty
            ? classDateList.firstWhere(
              (date) => date.day >= today.day,
              orElse: () => classDateList.first,
            )
            : today;

    // 임시 데이터: 모든 학생에 대한 출석 상태
    // 실제 구현에서는 DB에서 데이터 로드
    Map<String, Map<DateTime, AttendanceStatus>> attendanceData = {};

    // 각 학생에 대한 임의의 출석 데이터 생성
    for (var student in widget.classData.studentsList) {
      Map<DateTime, AttendanceStatus> studentAttendance = {};
      for (var date in classDateList) {
        // 임의의 출석 상태 생성 (실제로는 DB 데이터 사용)
        final random = date.day % 5; // 임시로 패턴 생성
        if (date.isAfter(today)) {
          studentAttendance[date] = AttendanceStatus.unknown;
        } else if (random == 0) {
          studentAttendance[date] = AttendanceStatus.absent;
        } else if (random == 1) {
          studentAttendance[date] = AttendanceStatus.late;
        } else {
          studentAttendance[date] = AttendanceStatus.present;
        }
      }
      attendanceData[student.id] = studentAttendance;
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // 월 선택 및 달력 영역
            _buildMonthSelector(currentYear, currentMonth, classDateList, (
              date,
            ) {
              setState(() {
                selectedDate = date;
              });
            }),

            // 선택된 날짜 표시
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[100],
              child: Center(
                child: Text(
                  '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 (${_getDayOfWeekString(selectedDate.weekday)})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 출석 데이터 테이블 (학생별 행, 날짜별 열)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: _buildAttendanceTable(
                    widget.classData.studentsList,
                    classDateList,
                    attendanceData,
                    selectedDate,
                    (studentId, date, status) {
                      // 상태 변경 로직
                      setState(() {
                        final nextStatus = _getNextAttendanceStatus(status);
                        attendanceData[studentId]?[date] = nextStatus;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 요일별 수업 날짜 구하기
  List<DateTime> _getClassDatesForMonth(int year, int month) {
    // 요일 문자열을 요일 번호로 변환
    final dayNumbers =
        widget.classData.dayOfWeek
            .split(',')
            .map((day) {
              switch (day.trim()) {
                case '월':
                  return DateTime.monday;
                case '화':
                  return DateTime.tuesday;
                case '수':
                  return DateTime.wednesday;
                case '목':
                  return DateTime.thursday;
                case '금':
                  return DateTime.friday;
                case '토':
                  return DateTime.saturday;
                case '일':
                  return DateTime.sunday;
                default:
                  return -1;
              }
            })
            .where((day) => day != -1)
            .toList();

    // 해당 월의 모든 날짜 구하기
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0); // 다음 달의 0일 = 이번 달의 마지막 날

    List<DateTime> classDates = [];
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(year, month, day);
      if (dayNumbers.contains(date.weekday)) {
        classDates.add(date);
      }
    }

    return classDates;
  }

  // 월 선택기 및 달력 위젯
  Widget _buildMonthSelector(
    int year,
    int month,
    List<DateTime> classDates,
    Function(DateTime) onDateSelected,
  ) {
    // 현재 월의 첫날과 마지막 날
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    // 달력에 표시할 날짜들 (이전 달, 현재 달, 다음 달의 일부 포함)
    final calendarDays = <DateTime>[];

    // 첫 주의 이전 달 날짜 추가
    final firstWeekday = firstDayOfMonth.weekday;
    for (int i = 1; i < firstWeekday; i++) {
      calendarDays.add(
        firstDayOfMonth.subtract(Duration(days: firstWeekday - i)),
      );
    }

    // 현재 달 날짜 추가
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      calendarDays.add(DateTime(year, month, i));
    }

    // 마지막 주 다음 달 날짜 추가 (42개 셀 채우기, 6주)
    final remainingDays = 42 - calendarDays.length;
    for (int i = 1; i <= remainingDays; i++) {
      calendarDays.add(lastDayOfMonth.add(Duration(days: i)));
    }

    // 요일 헤더
    final dayHeaders = ['월', '화', '수', '목', '금', '토', '일'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // 월 이동 네비게이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  // 이전 달로 이동 로직
                },
              ),
              Text(
                '$year년 $month월',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  // 다음 달로 이동 로직
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 요일 헤더
          Row(
            children:
                dayHeaders
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  day == '토'
                                      ? Colors.blue
                                      : (day == '일'
                                          ? Colors.red
                                          : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 4),

          // 달력 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.3,
            ),
            itemCount: 42, // 6주 x 7일
            itemBuilder: (context, index) {
              final date = calendarDays[index];
              final isCurrentMonth = date.month == month;
              final isToday = _isSameDay(date, DateTime.now());
              final isClassDay = classDates.any((d) => _isSameDay(d, date));

              return InkWell(
                onTap: isClassDay ? () => onDateSelected(date) : null,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color:
                        isClassDay
                            ? (isToday
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1))
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border:
                        isToday
                            ? Border.all(color: Colors.blue, width: 1)
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color:
                            !isCurrentMonth
                                ? Colors.grey.withOpacity(0.5)
                                : (date.weekday == 6
                                    ? Colors.blue
                                    : (date.weekday == 7
                                        ? Colors.red
                                        : Colors.black)),
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 출석 테이블 위젯
  Widget _buildAttendanceTable(
    List<StudentData> students,
    List<DateTime> dates,
    Map<String, Map<DateTime, AttendanceStatus>> attendanceData,
    DateTime selectedDate,
    Function(String, DateTime, AttendanceStatus) onStatusChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DataTable(
        columnSpacing: 15,
        headingRowHeight: 40,
        dataRowHeight: 60,
        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
        columns: [
          // 학생명 컬럼
          const DataColumn(
            label: Text('학생', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          // 선택된 날짜 컬럼
          DataColumn(
            label: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${selectedDate.month}/${selectedDate.day}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '(${_getDayOfWeekString(selectedDate.weekday)})',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          // 출석률 컬럼
          const DataColumn(
            label: Text('출석률', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows:
            students.map((student) {
              // 학생별 출석 상태
              final studentAttendance = attendanceData[student.id] ?? {};
              final selectedDayStatus =
                  studentAttendance[selectedDate] ?? AttendanceStatus.unknown;

              // 출석률 계산
              int presentCount = 0;
              int totalCheckedDays = 0;

              studentAttendance.forEach((date, status) {
                if (status != AttendanceStatus.unknown &&
                    !date.isAfter(DateTime.now())) {
                  totalCheckedDays++;
                  if (status == AttendanceStatus.present) {
                    presentCount++;
                  }
                }
              });

              final attendanceRate =
                  totalCheckedDays > 0
                      ? '${(presentCount / totalCheckedDays * 100).toStringAsFixed(0)}%'
                      : 'N/A';

              return DataRow(
                cells: [
                  // 학생 정보 셀
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          child: Text(student.name.substring(0, 1)),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              student.grade,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 출석 상태 셀
                  DataCell(
                    InkWell(
                      onTap:
                          () => onStatusChanged(
                            student.id,
                            selectedDate,
                            selectedDayStatus,
                          ),
                      child: _buildAttendanceStatusCell(selectedDayStatus),
                    ),
                  ),
                  // 출석률 셀
                  DataCell(
                    Text(
                      attendanceRate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            totalCheckedDays > 0
                                ? (int.parse(
                                          attendanceRate.replaceAll('%', ''),
                                        ) >
                                        80
                                    ? Colors.green
                                    : (int.parse(
                                              attendanceRate.replaceAll(
                                                '%',
                                                '',
                                              ),
                                            ) >
                                            60
                                        ? Colors.orange
                                        : Colors.red))
                                : Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  // 출석 상태 셀 위젯
  Widget _buildAttendanceStatusCell(AttendanceStatus status) {
    final IconData icon;
    final Color color;
    final String text;

    switch (status) {
      case AttendanceStatus.present:
        icon = Icons.check_circle;
        color = Colors.green;
        text = '출석';
        break;
      case AttendanceStatus.absent:
        icon = Icons.cancel;
        color = Colors.red;
        text = '결석';
        break;
      case AttendanceStatus.late:
        icon = Icons.access_time;
        color = Colors.orange;
        text = '지각';
        break;
      case AttendanceStatus.excused:
        icon = Icons.medical_services;
        color = Colors.blue;
        text = '사유결석';
        break;
      case AttendanceStatus.unknown:
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        text = '미확인';
        break;
    }

    return SizedBox(
      width: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 다음 출석 상태로 변경
  AttendanceStatus _getNextAttendanceStatus(AttendanceStatus current) {
    switch (current) {
      case AttendanceStatus.unknown:
        return AttendanceStatus.present;
      case AttendanceStatus.present:
        return AttendanceStatus.late;
      case AttendanceStatus.late:
        return AttendanceStatus.absent;
      case AttendanceStatus.absent:
        return AttendanceStatus.excused;
      case AttendanceStatus.excused:
        return AttendanceStatus.unknown;
    }
  }

  // 요일 문자열 변환
  String _getDayOfWeekString(int weekday) {
    switch (weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '';
    }
  }

  // 같은 날짜인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  // 학생 추가 다이얼로그
  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('학생 추가'),
            content: const SizedBox(
              width: double.maxFinite,
              child: Text('여기에 학생 선택 UI가 들어갑니다.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  // 학생 추가 로직 구현
                  Navigator.pop(context);
                },
                child: const Text('추가'),
              ),
            ],
          ),
    );
  }

  // 학생 제거 다이얼로그
  void _showRemoveStudentDialog(StudentData student) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('학생 제거'),
            content: Text('${student.name} 학생을 이 수업에서 제거하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  // 학생 제거 로직 구현
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('제거'),
              ),
            ],
          ),
    );
  }

  // 변경사항 저장
  void _saveChanges() {
    // 여기에 변경사항 저장 로직 구현
    // 실제로는 ViewModel을 통해 데이터 업데이트
    setState(() {
      _isEditing = false;
    });

    // 저장 완료 메시지
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('변경사항이 저장되었습니다')));
  }
}
