import 'package:flutter/material.dart';

/// 학원 관리자 수업 관리 화면
class AcademyClassesView extends StatefulWidget {
  const AcademyClassesView({super.key});

  @override
  State<AcademyClassesView> createState() => _AcademyClassesViewState();
}

class _AcademyClassesViewState extends State<AcademyClassesView> {
  final List<ClassData> _classes = [];
  bool _isLoading = true;
  String _selectedFilter = '전체';
  final List<String> _filterOptions = ['전체', '진행 중', '예정', '종료'];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    // 실제 구현에서는 API 또는 로컬 데이터베이스에서 데이터를 로드
    // 임시 데이터 생성
    await Future.delayed(const Duration(milliseconds: 800));

    // 위젯이 여전히 트리에 마운트되어 있는지 확인
    if (!mounted) return;

    setState(() {
      _classes.addAll([
        ClassData(
          id: '1',
          name: '수학 기초반',
          teacher: '김영희',
          students: 12,
          dayOfWeek: '월,수,금',
          timeSlot: '14:00 - 15:30',
          classroom: '제1교실',
          status: ClassStatus.active,
          startDate: DateTime(2023, 3, 2),
          endDate: DateTime(2023, 12, 20),
        ),
        ClassData(
          id: '2',
          name: '영어 중급반',
          teacher: '박철수',
          students: 15,
          dayOfWeek: '화,목',
          timeSlot: '16:00 - 17:30',
          classroom: '제2교실',
          status: ClassStatus.active,
          startDate: DateTime(2023, 3, 3),
          endDate: DateTime(2023, 12, 21),
        ),
        ClassData(
          id: '3',
          name: '과학 실험반',
          teacher: '이지훈',
          students: 8,
          dayOfWeek: '토',
          timeSlot: '10:00 - 12:30',
          classroom: '실험실',
          status: ClassStatus.active,
          startDate: DateTime(2023, 3, 4),
          endDate: DateTime(2023, 12, 23),
        ),
        ClassData(
          id: '4',
          name: '코딩 기초반',
          teacher: '최민수',
          students: 10,
          dayOfWeek: '토',
          timeSlot: '13:00 - 15:00',
          classroom: '컴퓨터실',
          status: ClassStatus.active,
          startDate: DateTime(2023, 3, 4),
          endDate: DateTime(2023, 12, 23),
        ),
        ClassData(
          id: '5',
          name: '미술 창작반',
          teacher: '김미정',
          students: 12,
          dayOfWeek: '화,목',
          timeSlot: '14:30 - 16:00',
          classroom: '미술실',
          status: ClassStatus.active,
          startDate: DateTime(2023, 3, 7),
          endDate: DateTime(2023, 12, 19),
        ),
        ClassData(
          id: '6',
          name: '겨울방학 특강',
          teacher: '정은지',
          students: 0,
          dayOfWeek: '월,화,수,목,금',
          timeSlot: '09:00 - 12:00',
          classroom: '제3교실',
          status: ClassStatus.planned,
          startDate: DateTime(2023, 12, 26),
          endDate: DateTime(2024, 1, 31),
        ),
        ClassData(
          id: '7',
          name: '봄학기 입시반',
          teacher: '미정',
          students: 0,
          dayOfWeek: '월,수,금',
          timeSlot: '17:00 - 19:00',
          classroom: '미정',
          status: ClassStatus.planned,
          startDate: DateTime(2024, 3, 4),
          endDate: DateTime(2024, 6, 28),
        ),
        ClassData(
          id: '8',
          name: '여름방학 특강',
          teacher: '미정',
          students: 0,
          dayOfWeek: '월,화,수,목,금',
          timeSlot: '10:00 - 13:00',
          classroom: '미정',
          status: ClassStatus.planned,
          startDate: DateTime(2024, 7, 24),
          endDate: DateTime(2024, 8, 23),
        ),
      ]);
      _isLoading = false;
    });
  }

  List<ClassData> _getFilteredClasses() {
    if (_selectedFilter == '전체') {
      return _classes;
    } else if (_selectedFilter == '진행 중') {
      return _classes.where((c) => c.status == ClassStatus.active).toList();
    } else if (_selectedFilter == '예정') {
      return _classes.where((c) => c.status == ClassStatus.planned).toList();
    } else {
      return _classes.where((c) => c.status == ClassStatus.completed).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildFilterSection(),
                  Expanded(child: _buildClassList()),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClassDialog(context),
        tooltip: '수업 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Text('필터: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Wrap(
            spacing: 8,
            children:
                _filterOptions.map((option) {
                  final isSelected = _selectedFilter == option;
                  return FilterChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = option;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
            tooltip: '정렬',
          ),
        ],
      ),
    );
  }

  Widget _buildClassList() {
    final filteredClasses = _getFilteredClasses();

    if (filteredClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '등록된 수업이 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddClassDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('수업 추가하기'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredClasses.length,
      itemBuilder: (context, index) {
        final classData = filteredClasses[index];
        return _buildClassCard(classData);
      },
    );
  }

  Widget _buildClassCard(ClassData classData) {
    Color statusColor;
    String statusText;

    switch (classData.status) {
      case ClassStatus.active:
        statusColor = Colors.green;
        statusText = '진행 중';
        break;
      case ClassStatus.planned:
        statusColor = Colors.orange;
        statusText = '예정';
        break;
      case ClassStatus.completed:
        statusColor = Colors.grey;
        statusText = '종료';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToClassDetail(classData),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      classData.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${classData.teacher} 선생님',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '학생 ${classData.students}명',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    classData.dayOfWeek,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    classData.timeSlot,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.room, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    classData.classroom,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToAttendance(classData),
                    icon: const Icon(Icons.checklist, size: 18),
                    label: const Text('출석부'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  _buildMoreMenu(classData),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMenu(ClassData classData) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditClassDialog(classData);
            break;
          case 'delete':
            _showDeleteConfirmation(classData);
            break;
          case 'students':
            _navigateToClassStudents(classData);
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
              value: 'students',
              child: Row(
                children: [
                  Icon(Icons.people, size: 18),
                  SizedBox(width: 8),
                  Text('학생 관리'),
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

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('이름순'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () {
                  // 정렬 로직 구현
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('날짜순'),
                leading: const Icon(Icons.calendar_today),
                onTap: () {
                  // 정렬 로직 구현
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('상태순'),
                leading: const Icon(Icons.label),
                onTap: () {
                  // 정렬 로직 구현
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddClassDialog(BuildContext context) {
    // 이 기능은 준비 중입니다 메시지 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showEditClassDialog(ClassData classData) {
    // 이 기능은 준비 중입니다 메시지 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showDeleteConfirmation(ClassData classData) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('수업 삭제'),
            content: Text('${classData.name} 수업을 정말 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  // 임시 기능: 삭제 로직 대신 메시지만 표시
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

  void _navigateToClassDetail(ClassData classData) {
    // 수업 상세 화면으로 이동하는 로직
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _navigateToAttendance(ClassData classData) {
    // 출석부 화면으로 이동하는 로직
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _navigateToClassStudents(ClassData classData) {
    // 학생 관리 화면으로 이동하는 로직
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }
}

/// 수업 상태 열거형
enum ClassStatus {
  active, // 진행 중
  planned, // 예정
  completed, // 종료
}

/// 수업 데이터 모델
class ClassData {
  final String id;
  final String name;
  final String teacher;
  final int students;
  final String dayOfWeek;
  final String timeSlot;
  final String classroom;
  final ClassStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRegularClass;
  final int studentCount;
  final List<StudentData> studentsList;

  ClassData({
    required this.id,
    required this.name,
    required this.teacher,
    required this.students,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.classroom,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.isRegularClass = true,
    this.studentCount = 0,
    this.studentsList = const [],
  });
}

/// 학생 데이터 모델
class StudentData {
  final String id;
  final String name;
  final String grade;

  StudentData({required this.id, required this.name, required this.grade});
}
