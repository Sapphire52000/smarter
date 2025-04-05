import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/attendance_view_model.dart';
import '../../viewmodels/class_view_model.dart';
import '../../viewmodels/student_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/attendance_model.dart';
import '../../models/class_model.dart';
import '../../models/student_model.dart';
import '../../models/user_model.dart';

/// 학원용 출석 관리 화면
class AcademyAttendanceView extends StatefulWidget {
  const AcademyAttendanceView({super.key});

  @override
  State<AcademyAttendanceView> createState() => _AcademyAttendanceViewState();
}

class _AcademyAttendanceViewState extends State<AcademyAttendanceView> {
  String? _selectedClassId;
  String? _selectedStudentId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 클래스 목록을 불러옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final classViewModel = Provider.of<ClassViewModel>(context, listen: false);
    final studentViewModel = Provider.of<StudentViewModel>(
      context,
      listen: false,
    );

    // 학원 ID가 있을 경우 해당 학원의 클래스만 불러옵니다.
    final academyId = authViewModel.user?.academyId;
    final teacherId =
        authViewModel.user?.role == UserRole.teacher
            ? authViewModel.user?.uid
            : null;

    // 데이터 로딩 중 에러 처리 추가
    try {
      classViewModel.loadClasses(academyId: academyId, teacherId: teacherId);
      studentViewModel.loadStudents(academyId: academyId);
    } catch (e) {
      // 에러 처리
      print('데이터 로딩 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ClassViewModel, StudentViewModel, AttendanceViewModel>(
      builder: (
        context,
        classViewModel,
        studentViewModel,
        attendanceViewModel,
        _,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('출석 관리'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadInitialData,
              ),
            ],
          ),
          body: Column(
            children: [
              // 필터 옵션
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '필터 옵션',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 수업 선택 드롭다운
                    DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: '수업 선택',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      value: _selectedClassId,
                      hint: const Text('수업을 선택하세요'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('모든 수업'),
                        ),
                        ...classViewModel.classes.map((classItem) {
                          return DropdownMenuItem<String>(
                            value: classItem.id,
                            child: Text(classItem.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedClassId = value;
                        });
                        _loadAttendanceData();
                      },
                    ),
                    const SizedBox(height: 8),
                    // 학생 선택 드롭다운
                    DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: '학생 선택',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      value: _selectedStudentId,
                      hint: const Text('학생을 선택하세요'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('모든 학생'),
                        ),
                        ...studentViewModel.students.map((student) {
                          return DropdownMenuItem<String>(
                            value: student.id,
                            child: Text(student.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStudentId = value;
                        });
                        _loadAttendanceData();
                      },
                    ),
                    const SizedBox(height: 8),
                    // 날짜 선택 버튼
                    Row(
                      children: [
                        const Text('날짜: ', style: TextStyle(fontSize: 16)),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_formatDate(_selectedDate)),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null && context.mounted) {
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                              _loadAttendanceData();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 출석 리스트
              Expanded(
                child: _buildAttendanceList(
                  attendanceViewModel,
                  classViewModel,
                  studentViewModel,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddAttendanceDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  // 날짜 포맷 함수
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  // 출석 데이터 로드
  Future<void> _loadAttendanceData() async {
    final attendanceViewModel = Provider.of<AttendanceViewModel>(
      context,
      listen: false,
    );

    // 선택한 날짜의 출석 데이터 로드
    attendanceViewModel.loadAttendanceByDate(
      _selectedDate,
      classId: _selectedClassId,
      studentId: _selectedStudentId,
    );
  }

  // 출석 리스트 위젯
  Widget _buildAttendanceList(
    AttendanceViewModel attendanceViewModel,
    ClassViewModel classViewModel,
    StudentViewModel studentViewModel,
  ) {
    if (attendanceViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (attendanceViewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '오류: ${attendanceViewModel.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAttendanceData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (attendanceViewModel.attendanceList.isEmpty) {
      return const Center(child: Text('해당 조건에 맞는 출석 기록이 없습니다.'));
    }

    // 출석 상태별 색상 설정
    final statusColors = {
      AttendanceStatus.present: Colors.green,
      AttendanceStatus.absent: Colors.red,
      AttendanceStatus.late: Colors.orange,
      AttendanceStatus.excused: Colors.blue,
      AttendanceStatus.cancelled: Colors.grey,
      AttendanceStatus.makeup: Colors.purple,
    };

    return ListView.builder(
      itemCount: attendanceViewModel.attendanceList.length,
      itemBuilder: (context, index) {
        final attendance = attendanceViewModel.attendanceList[index];

        // 수업 이름 찾기
        final classItem = classViewModel.classes.firstWhere(
          (c) => c.id == attendance.classId,
          orElse:
              () => ClassModel(
                id: '',
                name: '알 수 없음',
                academyId: '',
                maxStudents: 0,
                sessionsPerMonth: 0,
                startDate: DateTime.now(),
                status: ClassStatus.onHold,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        );

        // 학생 이름 찾기
        final student = studentViewModel.students.firstWhere(
          (s) => s.id == attendance.studentId,
          orElse:
              () => StudentModel(
                id: '',
                name: '알 수 없음',
                age: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        );

        // 출석 상태 텍스트
        final statusTexts = {
          AttendanceStatus.present: '출석',
          AttendanceStatus.absent: '결석',
          AttendanceStatus.late: '지각',
          AttendanceStatus.excused: '사유결석',
          AttendanceStatus.cancelled: '수업 취소',
          AttendanceStatus.makeup: '보충 수업',
        };

        // 출석 일시 표시
        final attendanceDate = attendance.date;
        final dateText =
            '${attendanceDate.year}년 ${attendanceDate.month}월 ${attendanceDate.day}일';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColors[attendance.status] ?? Colors.grey,
              child: Icon(
                _getStatusIcon(attendance.status),
                color: Colors.white,
              ),
            ),
            title: Text('${student.name} - ${classItem.name}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('날짜: $dateText'),
                Text('상태: ${statusTexts[attendance.status] ?? '알 수 없음'}'),
                if (attendance.note?.isNotEmpty ?? false)
                  Text('비고: ${attendance.note}'),
              ],
            ),
            isThreeLine: attendance.note?.isNotEmpty ?? false,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed:
                      () => _showEditAttendanceDialog(context, attendance),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed:
                      () => _showDeleteConfirmationDialog(context, attendance),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 출석 상태에 따른 아이콘 가져오기
  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.excused:
        return Icons.assignment_late;
      case AttendanceStatus.cancelled:
        return Icons.block;
      case AttendanceStatus.makeup:
        return Icons.repeat;
      default:
        return Icons.help;
    }
  }

  // 출석 추가 다이얼로그
  Future<void> _showAddAttendanceDialog(BuildContext context) async {
    final classViewModel = Provider.of<ClassViewModel>(context, listen: false);
    final studentViewModel = Provider.of<StudentViewModel>(
      context,
      listen: false,
    );

    // 초기값 설정
    String? selectedClassId = _selectedClassId;
    String? selectedStudentId = _selectedStudentId;
    AttendanceStatus selectedStatus = AttendanceStatus.present;
    DateTime selectedDate = _selectedDate;
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('출석 기록 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 수업 선택
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '수업',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedClassId,
                      items:
                          classViewModel.classes.map((classItem) {
                            return DropdownMenuItem<String>(
                              value: classItem.id,
                              child: Text(classItem.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClassId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '수업을 선택해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 학생 선택
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '학생',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStudentId,
                      items:
                          studentViewModel.students.map((student) {
                            return DropdownMenuItem<String>(
                              value: student.id,
                              child: Text(student.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStudentId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '학생을 선택해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 날짜
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '날짜',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDate(selectedDate)),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 출석 상태
                    DropdownButtonFormField<AttendanceStatus>(
                      decoration: const InputDecoration(
                        labelText: '출석 상태',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStatus,
                      items:
                          AttendanceStatus.values.map((status) {
                            return DropdownMenuItem<AttendanceStatus>(
                              value: status,
                              child: Text(_getStatusText(status)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 비고
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: '비고',
                        border: OutlineInputBorder(),
                        hintText: '특이사항이 있다면 입력하세요',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedClassId != null && selectedStudentId != null) {
                      _addAttendance(
                        classId: selectedClassId!,
                        studentId: selectedStudentId!,
                        date: selectedDate,
                        status: selectedStatus,
                        note: noteController.text,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('수업과 학생을 선택해주세요')),
                      );
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );

    // 컨트롤러 해제
    noteController.dispose();
  }

  // 출석 상태 텍스트
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
        return '수업 취소';
      case AttendanceStatus.makeup:
        return '보충 수업';
      default:
        return '알 수 없음';
    }
  }

  // 출석 추가 처리
  Future<void> _addAttendance({
    required String classId,
    required String studentId,
    required DateTime date,
    required AttendanceStatus status,
    String? note,
  }) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final attendanceViewModel = Provider.of<AttendanceViewModel>(
      context,
      listen: false,
    );

    final teacherId = authViewModel.user?.uid;

    // 출석 생성
    final success = await attendanceViewModel.createAttendance(
      classId: classId,
      studentId: studentId,
      date: date,
      status: status,
      teacherId: teacherId,
      note: note,
      isCarriedOver: false,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('출석 기록이 추가되었습니다')));
      // 출석 목록 다시 로드
      _loadAttendanceData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attendanceViewModel.errorMessage ?? '출석 기록 추가 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 출석 수정 다이얼로그
  Future<void> _showEditAttendanceDialog(
    BuildContext context,
    AttendanceModel attendance,
  ) async {
    // 현재 값으로 초기화
    AttendanceStatus selectedStatus = attendance.status;
    DateTime selectedDate = attendance.date;
    final noteController = TextEditingController(text: attendance.note);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('출석 기록 수정'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 날짜 선택
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '날짜',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDate(selectedDate)),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 출석 상태 선택
                    DropdownButtonFormField<AttendanceStatus>(
                      decoration: const InputDecoration(
                        labelText: '출석 상태',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStatus,
                      items:
                          AttendanceStatus.values.map((status) {
                            return DropdownMenuItem<AttendanceStatus>(
                              value: status,
                              child: Text(_getStatusText(status)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 비고 입력
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: '비고',
                        border: OutlineInputBorder(),
                        hintText: '특이사항이 있다면 입력하세요',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateAttendance(
                      attendance: attendance,
                      date: selectedDate,
                      status: selectedStatus,
                      note: noteController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    // 컨트롤러 해제
    noteController.dispose();
  }

  // 출석 수정 처리
  Future<void> _updateAttendance({
    required AttendanceModel attendance,
    required DateTime date,
    required AttendanceStatus status,
    String? note,
  }) async {
    final attendanceViewModel = Provider.of<AttendanceViewModel>(
      context,
      listen: false,
    );

    // 출석 업데이트
    final success = await attendanceViewModel.updateAttendance(
      id: attendance.id,
      status: status,
      note: note,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('출석 기록이 수정되었습니다')));
      // 출석 목록 다시 로드
      _loadAttendanceData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attendanceViewModel.errorMessage ?? '출석 기록 수정 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 출석 삭제 확인 다이얼로그
  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    AttendanceModel attendance,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('출석 기록 삭제'),
          content: const Text('이 출석 기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAttendance(attendance);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  // 출석 삭제 처리
  Future<void> _deleteAttendance(AttendanceModel attendance) async {
    final attendanceViewModel = Provider.of<AttendanceViewModel>(
      context,
      listen: false,
    );

    // 출석 삭제
    final success = await attendanceViewModel.deleteAttendance(attendance.id);

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('출석 기록이 삭제되었습니다')));
      // 출석 목록 다시 로드
      _loadAttendanceData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attendanceViewModel.errorMessage ?? '출석 기록 삭제 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
