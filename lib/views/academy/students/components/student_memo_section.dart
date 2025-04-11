import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../student_detail_view.dart';

/// 학생 메모 섹션 컴포넌트
class StudentMemoSection extends StatelessWidget {
  final List<MemoItem> memos;
  final VoidCallback onAddMemo;

  const StudentMemoSection({
    super.key,
    required this.memos,
    required this.onAddMemo,
  });

  @override
  Widget build(BuildContext context) {
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
                  '메모 및 특이사항',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAddMemo,
                  tooltip: '메모 추가',
                ),
              ],
            ),
            const SizedBox(height: 8),
            memos.isEmpty
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('메모가 없습니다'),
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: memos.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return _buildMemoItem(context, memos[index]);
                  },
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoItem(BuildContext context, MemoItem memo) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                dateFormat.format(memo.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditMemo(context, memo);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, memo);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('수정')),
                      const PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(memo.content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showEditMemo(BuildContext context, MemoItem memo) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('메모 수정 기능은 준비 중입니다')));
  }

  void _showDeleteConfirmation(BuildContext context, MemoItem memo) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('메모 삭제 기능은 준비 중입니다')));
  }
}
