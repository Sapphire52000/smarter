import 'package:flutter/material.dart';
import 'components/student_attendance_summary.dart';
import 'components/student_memo_section.dart';
import '../academy_students_view.dart';

/// 학생 상세 정보 화면
class StudentDetailView extends StatefulWidget {
  final Student student;

  const StudentDetailView({super.key, required this.student});

  @override
  State<StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends State<StudentDetailView> {
  bool _isLoading = false;
  List<MemoItem> _memos = [];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
    });

    // 실제 구현에서는 API 또는 로컬 데이터베이스에서 데이터를 로드
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _memos = [
        MemoItem(
          id: '1',
          content: widget.student.note,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        MemoItem(
          id: '2',
          content: '수업 중 집중력이 향상되고 있음',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student.name} 학생 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editStudent(),
            tooltip: '학생 정보 수정',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildStudentDetailBody(),
    );
  }

  Widget _buildStudentDetailBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentBasicInfo(),
          const SizedBox(height: 24),
          _buildClassesList(),
          const SizedBox(height: 24),
          StudentAttendanceSummary(student: widget.student),
          const SizedBox(height: 24),
          StudentMemoSection(memos: _memos, onAddMemo: _addNewMemo),
        ],
      ),
    );
  }

  Widget _buildStudentBasicInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  child: Text(
                    widget.student.name.substring(0, 1),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.student.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.student.grade,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _infoRow(
                        Icons.phone_android,
                        '학부모 연락처',
                        widget.student.parentPhoneNumber,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text('메시지 보내기'),
                  onPressed: () => _sendMessage(),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text('전화하기'),
                  onPressed: () => _contactParent(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildClassesList() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '수강 수업',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '총 ${widget.student.classes.length}개 수업',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            widget.student.classes.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      '등록된 수업이 없습니다',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.student.classes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.class_outlined),
                      title: Text(widget.student.classes[index]),
                      dense: true,
                      onTap:
                          () => _navigateToClassDetail(
                            widget.student.classes[index],
                          ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }

  void _editStudent() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('학생 정보 수정 기능은 준비 중입니다')));
  }

  void _addNewMemo() {
    final TextEditingController memoController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('메모 추가'),
            content: TextField(
              controller: memoController,
              decoration: const InputDecoration(
                hintText: '메모 내용을 입력하세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (memoController.text.trim().isNotEmpty) {
                    setState(() {
                      _memos.insert(
                        0,
                        MemoItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          content: memoController.text.trim(),
                          createdAt: DateTime.now(),
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('저장'),
              ),
            ],
          ),
    );
  }

  void _sendMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('메시지 보내기 기능은 준비 중입니다')));
  }

  void _contactParent() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('전화하기 기능은 준비 중입니다')));
  }

  void _navigateToClassDetail(String className) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$className 수업 정보 확인 기능은 준비 중입니다')));
  }
}

/// 메모 아이템 데이터 모델
class MemoItem {
  final String id;
  final String content;
  final DateTime createdAt;

  MemoItem({required this.id, required this.content, required this.createdAt});
}
