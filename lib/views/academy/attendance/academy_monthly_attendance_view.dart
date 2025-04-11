import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/class_view_model.dart';
import '../../../viewmodels/student_view_model.dart';
import '../../../viewmodels/attendance_view_model.dart';
import '../../../models/attendance_model.dart';
import '../../../models/class_model.dart';
import '../../../models/student_model.dart';

/// 학원 월별 출석부 화면
class AcademyMonthlyAttendanceView extends StatefulWidget {
  final String? initialClassId;
  final DateTime? initialMonth;

  const AcademyMonthlyAttendanceView({
    super.key,
    this.initialClassId,
    this.initialMonth,
  });

  @override
  State<AcademyMonthlyAttendanceView> createState() =>
      _AcademyMonthlyAttendanceViewState();
}

class _AcademyMonthlyAttendanceViewState
    extends State<AcademyMonthlyAttendanceView> {
  late DateTime _selectedMonth;
  String? _selectedClassId;
  bool _isLoading = true;
  List<DateTime> _daysInMonth = [];
  Map<String, Map<String, AttendanceStatus>> _attendanceData = {};
  final Map<AttendanceStatus, Color> _statusColors = {
    AttendanceStatus.present: Colors.green,
    AttendanceStatus.absent: Colors.red,
    AttendanceStatus.late: Colors.orange,
    AttendanceStatus.excused: Colors.blue,
    AttendanceStatus.cancelled: Colors.grey,
    AttendanceStatus.makeup: Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth ?? DateTime.now();
    _selectedClassId = widget.initialClassId;
    _updateDaysInMonth();

    // 초기 데이터 로드는 didChangeDependencies에서 수행
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final classViewModel = Provider.of<ClassViewModel>(context);
    final studentViewModel = Provider.of<StudentViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    // 학원 ID 설정
    final academyId = authViewModel.user?.academyId;

    // 클래스 및 학생 데이터 로드
    if (!classViewModel.isLoading && classViewModel.classes.isEmpty) {
      classViewModel.loadClasses(academyId: academyId);
    }

    if (!studentViewModel.isLoading && studentViewModel.students.isEmpty) {
      studentViewModel.loadStudents(academyId: academyId);
    }

    // 초기 수업 ID가 없는 경우 첫 번째 수업 선택
    if (_selectedClassId == null &&
        !classViewModel.isLoading &&
        classViewModel.classes.isNotEmpty) {
      setState(() {
        _selectedClassId = classViewModel.classes.first.id;
      });
    }

    // 출석 데이터 로드
    if (_selectedClassId != null) {
      _loadAttendanceData();
    }
  }

  // 월의 모든 날짜 계산
  void _updateDaysInMonth() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    _daysInMonth = List.generate(
      lastDay.day,
      (index) => DateTime(_selectedMonth.year, _selectedMonth.month, index + 1),
    );
  }

  // 출석 데이터 로드
  Future<void> _loadAttendanceData() async {
    if (_selectedClassId == null) return;

    setState(() {
      _isLoading = true;
    });

    final attendanceViewModel = Provider.of<AttendanceViewModel>(
      context,
      listen: false,
    );
    final studentViewModel = Provider.of<StudentViewModel>(
      context,
      listen: false,
    );

    // 선택한 월의 시작일과 종료일 설정
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    // 수업에 등록된 학생 목록 가져오기
    final classViewModel = Provider.of<ClassViewModel>(context, listen: false);
    final selectedClass = classViewModel.classes.firstWhere(
      (c) => c.id == _selectedClassId,
      orElse:
          () => ClassModel(
            id: '',
            name: '',
            maxStudents: 0,
            sessionsPerMonth: 0,
            startDate: DateTime.now(),
            status: ClassStatus.active,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );

    final enrolledStudentIds = selectedClass.enrolledStudentIds ?? [];
    final Map<String, Map<String, AttendanceStatus>> attendanceData = {};

    // 각 학생별 출석 데이터 로드
    for (var studentId in enrolledStudentIds) {
      final student = studentViewModel.students.firstWhere(
        (s) => s.id == studentId,
        orElse:
            () => StudentModel(
              id: studentId,
              name: '불명학생',
              age: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      );

      // 학생별 날짜별 출석 상태 맵 초기화
      attendanceData[studentId] = {};

      // 기본값으로 모든 일자에 결석 처리
      for (var day in _daysInMonth) {
        attendanceData[studentId]![day.toIso8601String()] =
            AttendanceStatus.absent;
      }
    }

    // 출석 데이터 가져오기
    attendanceViewModel.loadAttendanceByClass(
      _selectedClassId!,
      startDate: firstDayOfMonth,
      endDate: lastDayOfMonth,
    );

    // 출석 데이터가 로드되길 기다림
    await Future.delayed(const Duration(milliseconds: 500));

    // 실제 출석 정보로 업데이트
    for (var attendance in attendanceViewModel.attendanceList) {
      final dateStr =
          DateTime(
            attendance.date.year,
            attendance.date.month,
            attendance.date.day,
          ).toIso8601String();

      if (attendanceData.containsKey(attendance.studentId)) {
        attendanceData[attendance.studentId]![dateStr] = attendance.status;
      }
    }

    setState(() {
      _attendanceData = attendanceData;
      _isLoading = false;
    });
  }

  // 이전 달로 이동
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
      _updateDaysInMonth();
    });
    _loadAttendanceData();
  }

  // 다음 달로 이동
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
      _updateDaysInMonth();
    });
    _loadAttendanceData();
  }

  // 출석 상태 변경 다이얼로그
  Future<void> _showAttendanceStatusDialog(
    BuildContext context,
    String studentId,
    String studentName,
    DateTime date,
    AttendanceStatus currentStatus,
  ) async {
    AttendanceStatus selectedStatus = currentStatus;
    final TextEditingController noteController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('출석 상태 변경'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$studentName - ${DateFormat('yyyy년 M월 d일').format(date)}',
                ),
                const SizedBox(height: 16),
                // 출석 상태 라디오 버튼
                ...AttendanceStatus.values.map((status) {
                  return RadioListTile<AttendanceStatus>(
                    title: Text(_getStatusText(status)),
                    value: status,
                    groupValue: selectedStatus,
                    activeColor: _statusColors[status],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  );
                }),
                const SizedBox(height: 16),
                // 메모 입력
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: '메모',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 출석 상태 업데이트 로직
                  _updateAttendanceStatus(
                    studentId,
                    date,
                    selectedStatus,
                    noteController.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text('저장'),
              ),
            ],
          ),
    );
  }

  // 출석 상태 업데이트
  Future<void> _updateAttendanceStatus(
    String studentId,
    DateTime date,
    AttendanceStatus status,
    String note,
  ) async {
    if (_selectedClassId == null) return;

    final attendanceViewModel = Provider.of<AttendanceViewModel>(
      context,
      listen: false,
    );
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // 기존 출석 데이터에서 해당 날짜의 출석 기록 찾기
    final existingAttendance = attendanceViewModel.attendanceList.firstWhere(
      (a) =>
          a.studentId == studentId &&
          a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day,
      orElse:
          () => AttendanceModel(
            id: '',
            classId: _selectedClassId!,
            studentId: studentId,
            date: date,
            status: AttendanceStatus.absent,
            isCarriedOver: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );

    // 출석 기록이 있으면 업데이트, 없으면 새로 생성
    if (existingAttendance.id.isNotEmpty) {
      await attendanceViewModel.updateAttendance(
        id: existingAttendance.id,
        status: status,
        note: note,
      );
    } else {
      await attendanceViewModel.createAttendance(
        classId: _selectedClassId!,
        studentId: studentId,
        date: date,
        status: status,
        teacherId: authViewModel.user?.uid,
        note: note,
      );
    }

    // 출석 데이터 다시 로드
    _loadAttendanceData();
  }

  // 수업 변경 처리
  void _onClassChanged(String? newClassId) {
    if (newClassId != null && newClassId != _selectedClassId) {
      setState(() {
        _selectedClassId = newClassId;
      });
      _loadAttendanceData();
    }
  }

  // 출석 상태 텍스트 반환
  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return '출석';
      case AttendanceStatus.absent:
        return '결석';
      case AttendanceStatus.late:
        return '지각';
      case AttendanceStatus.excused:
        return '사유결석';
      case AttendanceStatus.cancelled:
        return '취소';
      case AttendanceStatus.makeup:
        return '보충';
    }
  }

  // 출석 상태 아이콘 반환
  Widget _buildStatusIcon(AttendanceStatus status) {
    IconData iconData;
    Color color = _statusColors[status] ?? Colors.grey;

    switch (status) {
      case AttendanceStatus.present:
        iconData = Icons.check_circle;
        break;
      case AttendanceStatus.absent:
        iconData = Icons.cancel;
        break;
      case AttendanceStatus.late:
        iconData = Icons.access_time;
        break;
      case AttendanceStatus.excused:
        iconData = Icons.medical_services;
        break;
      case AttendanceStatus.cancelled:
        iconData = Icons.event_busy;
        break;
      case AttendanceStatus.makeup:
        iconData = Icons.replay;
        break;
    }

    return Icon(iconData, color: color, size: 18);
  }

  // 학생별 통계 계산
  Map<String, int> _calculateStudentStatistics(String studentId) {
    final statCount = <String, int>{
      'present': 0,
      'absent': 0,
      'late': 0,
      'excused': 0,
      'total': 0,
    };

    if (_attendanceData.containsKey(studentId)) {
      _attendanceData[studentId]!.forEach((date, status) {
        statCount['total'] = (statCount['total'] ?? 0) + 1;

        switch (status) {
          case AttendanceStatus.present:
            statCount['present'] = (statCount['present'] ?? 0) + 1;
            break;
          case AttendanceStatus.absent:
            statCount['absent'] = (statCount['absent'] ?? 0) + 1;
            break;
          case AttendanceStatus.late:
            statCount['late'] = (statCount['late'] ?? 0) + 1;
            break;
          case AttendanceStatus.excused:
            statCount['excused'] = (statCount['excused'] ?? 0) + 1;
            break;
          default:
            break;
        }
      });
    }

    return statCount;
  }

  @override
  Widget build(BuildContext context) {
    final classViewModel = Provider.of<ClassViewModel>(context);
    final studentViewModel = Provider.of<StudentViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('월별 출석부'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('출석 통계 저장 기능은 준비중입니다')),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // 월 선택 및 이동 버튼
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          DateFormat('yyyy년 M월').format(_selectedMonth),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                  ),

                  // 수업 선택 드롭다운
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '수업 선택',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedClassId,
                      items:
                          classViewModel.classes.map((classModel) {
                            return DropdownMenuItem<String>(
                              value: classModel.id,
                              child: Text(classModel.name),
                            );
                          }).toList(),
                      onChanged: _onClassChanged,
                    ),
                  ),

                  // 출석부 테이블
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Colors.grey[200],
                            ),
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                            ),
                            columnSpacing: 8,
                            columns: [
                              const DataColumn(label: Text('학생')),
                              const DataColumn(label: Text('통계')),
                              // 날짜별 열
                              ..._daysInMonth.map((date) {
                                return DataColumn(
                                  label: Container(
                                    width: 36,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color:
                                            date.weekday == 6
                                                ? Colors.blue
                                                : date.weekday == 7
                                                ? Colors.red
                                                : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                            rows:
                                _attendanceData.entries.map((entry) {
                                  final studentId = entry.key;
                                  final attendanceMap = entry.value;

                                  // 학생 정보 가져오기
                                  final student = studentViewModel.students
                                      .firstWhere(
                                        (s) => s.id == studentId,
                                        orElse:
                                            () => StudentModel(
                                              id: studentId,
                                              name: '불명학생',
                                              age: 0,
                                              createdAt: DateTime.now(),
                                              updatedAt: DateTime.now(),
                                            ),
                                      );

                                  // 통계 계산
                                  final stats = _calculateStudentStatistics(
                                    studentId,
                                  );

                                  return DataRow(
                                    cells: [
                                      // 학생 이름
                                      DataCell(
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            student.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 통계
                                      DataCell(
                                        SizedBox(
                                          width: 120,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Tooltip(
                                                message: '출석',
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${stats['present']}',
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Tooltip(
                                                message: '결석',
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${stats['absent']}',
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Tooltip(
                                                message: '지각',
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${stats['late']}',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // 날짜별 출석 상태
                                      ..._daysInMonth.map((date) {
                                        final dateStr =
                                            DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                            ).toIso8601String();

                                        final status =
                                            attendanceMap[dateStr] ??
                                            AttendanceStatus.absent;

                                        return DataCell(
                                          GestureDetector(
                                            onTap: () {
                                              _showAttendanceStatusDialog(
                                                context,
                                                studentId,
                                                student.name,
                                                date,
                                                status,
                                              );
                                            },
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              alignment: Alignment.center,
                                              child: _buildStatusIcon(status),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 범례
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 16,
                      children: [
                        ...AttendanceStatus.values.map((status) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStatusIcon(status),
                              const SizedBox(width: 4),
                              Text(_getStatusText(status)),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 일괄 출석 체크 기능 (향후 구현)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('일괄 출석 체크 기능은 준비중입니다')));
        },
        child: const Icon(Icons.playlist_add_check),
      ),
    );
  }
}
