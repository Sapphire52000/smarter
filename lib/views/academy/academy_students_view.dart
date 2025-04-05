import 'package:flutter/material.dart';

/// 학원 관리자 학생 관리 화면
class AcademyStudentsView extends StatefulWidget {
  const AcademyStudentsView({super.key});

  @override
  State<AcademyStudentsView> createState() => _AcademyStudentsViewState();
}

class _AcademyStudentsViewState extends State<AcademyStudentsView> {
  final List<Student> _students = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = '전체';
  final List<String> _filterOptions = ['전체', '초등학생', '중학생', '고등학생'];

  @override
  void initState() {
    super.initState();
    _loadStudents();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    // 실제 구현에서는 API 또는 로컬 데이터베이스에서 데이터를 로드
    // 임시 데이터 생성
    await Future.delayed(const Duration(milliseconds: 800));

    // 위젯이 여전히 트리에 마운트되어 있는지 확인
    if (!mounted) return;

    setState(() {
      _students.addAll([
        Student(
          id: '1',
          name: '김민수',
          grade: '고등학교 2학년',
          classes: ['수학 기초반', '영어 중급반'],
          phoneNumber: '010-1234-5678',
          parentName: '김철수',
          parentPhoneNumber: '010-8765-4321',
          attendanceRate: 95,
          note: '수학에 어려움을 겪고 있어 추가 지도 필요',
        ),
        Student(
          id: '2',
          name: '이지은',
          grade: '중학교 3학년',
          classes: ['영어 중급반', '과학 실험반'],
          phoneNumber: '010-2345-6789',
          parentName: '이영희',
          parentPhoneNumber: '010-9876-5432',
          attendanceRate: 98,
          note: '과학 분야에 재능이 있음',
        ),
        Student(
          id: '3',
          name: '박준호',
          grade: '고등학교 1학년',
          classes: ['수학 기초반'],
          phoneNumber: '010-3456-7890',
          parentName: '박미영',
          parentPhoneNumber: '010-0987-6543',
          attendanceRate: 90,
          note: '집중력이 부족함, 수업 중 자주 딴짓을 함',
        ),
        Student(
          id: '4',
          name: '최유진',
          grade: '초등학교 6학년',
          classes: ['영어 중급반', '코딩 기초반'],
          phoneNumber: '010-4567-8901',
          parentName: '최민준',
          parentPhoneNumber: '010-1098-7654',
          attendanceRate: 100,
          note: '성실하고 학습 의욕이 높음',
        ),
        Student(
          id: '5',
          name: '정민준',
          grade: '중학교 2학년',
          classes: ['수학 기초반', '영어 중급반', '과학 실험반'],
          phoneNumber: '010-5678-9012',
          parentName: '정영수',
          parentPhoneNumber: '010-2109-8765',
          attendanceRate: 85,
          note: '결석이 잦아 학부모 상담 필요',
        ),
        Student(
          id: '6',
          name: '한소희',
          grade: '고등학교 3학년',
          classes: ['수학 기초반'],
          phoneNumber: '010-6789-0123',
          parentName: '한지훈',
          parentPhoneNumber: '010-3210-9876',
          attendanceRate: 92,
          note: '수능 준비로 인한 스트레스 관리 필요',
        ),
        Student(
          id: '7',
          name: '김태희',
          grade: '초등학교 5학년',
          classes: ['코딩 기초반', '미술 창작반'],
          phoneNumber: '010-7890-1234',
          parentName: '김재현',
          parentPhoneNumber: '010-4321-0987',
          attendanceRate: 97,
          note: '창의적이고 손재주가 좋음',
        ),
        Student(
          id: '8',
          name: '이준우',
          grade: '중학교 1학년',
          classes: ['영어 중급반', '미술 창작반'],
          phoneNumber: '010-8901-2345',
          parentName: '이민지',
          parentPhoneNumber: '010-5432-1098',
          attendanceRate: 94,
          note: '영어 실력이 빠르게 향상 중',
        ),
        Student(
          id: '9',
          name: '박서연',
          grade: '초등학교 4학년',
          classes: ['미술 창작반'],
          phoneNumber: '010-9012-3456',
          parentName: '박지민',
          parentPhoneNumber: '010-6543-2109',
          attendanceRate: 99,
          note: '미술에 재능이 있음',
        ),
        Student(
          id: '10',
          name: '최민석',
          grade: '고등학교 2학년',
          classes: ['수학 기초반', '과학 실험반'],
          phoneNumber: '010-0123-4567',
          parentName: '최유나',
          parentPhoneNumber: '010-7654-3210',
          attendanceRate: 88,
          note: '과학에 관심이 많으나 기초가 부족함',
        ),
      ]);
      _isLoading = false;
    });
  }

  List<Student> _getFilteredStudents() {
    // 검색어와 필터 모두 적용
    return _students.where((student) {
      // 검색어 필터링
      final matchesQuery =
          _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.grade.toLowerCase().contains(_searchQuery.toLowerCase());

      // 학년 필터링
      final matchesFilter =
          _selectedFilter == '전체' ||
          (_selectedFilter == '초등학생' && student.grade.contains('초등학교')) ||
          (_selectedFilter == '중학생' && student.grade.contains('중학교')) ||
          (_selectedFilter == '고등학생' && student.grade.contains('고등학교'));

      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildSearchAndFilterBar(),
                  Expanded(child: _buildStudentList()),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        tooltip: '학생 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '이름 또는 학년으로 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('필터: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _filterOptions.map((option) {
                          final isSelected = _selectedFilter == option;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
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
                              checkmarkColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => _showSortOptions(context),
                tooltip: '정렬',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    final filteredStudents = _getFilteredStudents();

    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? '등록된 학생이 없습니다' : '검색 결과가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddStudentDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('학생 등록하기'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToStudentDetail(student),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      student.name.substring(0, 1),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          student.grade,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              student.phoneNumber,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildAttendanceIndicator(student.attendanceRate),
                ],
              ),
              const Divider(height: 24),
              Text(
                '수강 중인 수업',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    student.classes.map((className) {
                      return Chip(
                        label: Text(
                          className,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue[50],
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showAttendanceDialog(student),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('출결'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showGradesDialog(student),
                    icon: const Icon(Icons.assessment, size: 18),
                    label: const Text('성적'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  _buildMoreMenu(student),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceIndicator(int attendanceRate) {
    Color color;
    if (attendanceRate >= 95) {
      color = Colors.green;
    } else if (attendanceRate >= 85) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '출석률 $attendanceRate%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMoreMenu(Student student) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditStudentDialog(student);
            break;
          case 'delete':
            _showDeleteConfirmation(student);
            break;
          case 'contact':
            _showContactDialog(student);
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
                  Text('학생 정보 수정'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'contact',
              child: Row(
                children: [
                  Icon(Icons.contact_phone, size: 18),
                  SizedBox(width: 8),
                  Text('학부모 연락처'),
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
                title: const Text('학년순'),
                leading: const Icon(Icons.school),
                onTap: () {
                  // 정렬 로직 구현
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('출석률순'),
                leading: const Icon(Icons.calendar_today),
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

  void _showAddStudentDialog(BuildContext context) {
    // 이 기능은 준비 중입니다 메시지 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showEditStudentDialog(Student student) {
    // 이 기능은 준비 중입니다 메시지 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showDeleteConfirmation(Student student) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('학생 삭제'),
            content: Text('${student.name} 학생을 정말 삭제하시겠습니까?'),
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

  void _navigateToStudentDetail(Student student) {
    // 학생 상세 화면으로 이동하는 로직
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showAttendanceDialog(Student student) {
    // 출결 현황 보기 기능
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showGradesDialog(Student student) {
    // 성적 확인 기능
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showContactDialog(Student student) {
    // 학부모 연락처 정보 확인 기능
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${student.name} 학생 학부모 연락처'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('학부모: ${student.parentName}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('연락처: ${student.parentPhoneNumber}'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
              TextButton(
                onPressed: () {
                  // 전화 걸기 기능 (실제로는 url_launcher 패키지 사용 필요)
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이 기능은 준비 중입니다')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Text('전화 걸기'),
              ),
            ],
          ),
    );
  }
}

/// 학생 데이터 모델
class Student {
  final String id;
  final String name;
  final String grade;
  final List<String> classes;
  final String phoneNumber;
  final String parentName;
  final String parentPhoneNumber;
  final int attendanceRate;
  final String note;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.classes,
    required this.phoneNumber,
    required this.parentName,
    required this.parentPhoneNumber,
    required this.attendanceRate,
    required this.note,
  });
}
