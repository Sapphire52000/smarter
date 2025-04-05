import 'package:flutter/material.dart';

/// 학부모용 자녀 관리 화면
class ParentChildrenView extends StatefulWidget {
  const ParentChildrenView({super.key});

  @override
  State<ParentChildrenView> createState() => _ParentChildrenViewState();
}

class _ParentChildrenViewState extends State<ParentChildrenView> {
  // 임시 데이터 - 자녀 목록
  final List<Map<String, dynamic>> _children = [
    {
      'name': '김민준',
      'age': 14,
      'grade': '중학교 2학년',
      'profileImage': null,
      'academies': [
        {
          'name': '중앙학원',
          'subjects': ['수학', '영어', '과학'],
          'startDate': '2023-03-01',
        },
        {
          'name': '영어마을',
          'subjects': ['영어 회화'],
          'startDate': '2023-04-15',
        },
      ],
      'attendance': 85,
      'testScore': 92,
    },
    {
      'name': '김서연',
      'age': 11,
      'grade': '초등학교 5학년',
      'profileImage': null,
      'academies': [
        {
          'name': '코딩학원',
          'subjects': ['코딩'],
          'startDate': '2023-05-10',
        },
        {
          'name': '예술학원',
          'subjects': ['미술'],
          'startDate': '2023-02-20',
        },
      ],
      'attendance': 95,
      'testScore': 88,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children.isEmpty ? _buildEmptyState() : _buildChildrenList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChildDialog(context),
        tooltip: '자녀 등록',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '등록된 자녀가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오른쪽 하단의 + 버튼을 눌러 자녀를 등록해주세요',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _children.length,
      itemBuilder: (context, index) {
        return _buildChildItem(_children[index]);
      },
    );
  }

  Widget _buildChildItem(Map<String, dynamic> child) {
    // 과목 목록 문자열로 변환
    List<String> allSubjects = [];
    for (var academy in child['academies']) {
      allSubjects.addAll(academy['subjects'] as List<String>);
    }
    String subjectsText = allSubjects.join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToChildDetail(context, child),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      child['name'].substring(0, 1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child['name'],
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          child['grade'],
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '수강 과목: $subjectsText',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(
                    '출석률',
                    '${child['attendance']}%',
                    _getAttendanceColor(child['attendance']),
                  ),
                  _buildStat(
                    '학원 수',
                    '${child['academies'].length}개',
                    Colors.blue,
                  ),
                  _buildStat(
                    '평균 점수',
                    '${child['testScore']}점',
                    _getScoreColor(child['testScore']),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // 시간표 화면으로 이동
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('시간표'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _navigateToChildDetail(context, child),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('상세정보'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Color _getAttendanceColor(int attendance) {
    if (attendance >= 95) return Colors.green;
    if (attendance >= 85) return Colors.orange;
    return Colors.red;
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  void _navigateToChildDetail(
    BuildContext context,
    Map<String, dynamic> child,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _ChildDetailView(child: child)),
    );
  }

  void _showAddChildDialog(BuildContext context) {
    // 임시 메시지 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }
}

/// 자녀 상세 정보 화면
class _ChildDetailView extends StatelessWidget {
  final Map<String, dynamic> child;

  const _ChildDetailView({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${child['name']} 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 자녀 정보 수정 기능
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
            },
            tooltip: '수정',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildAcademiesSection(context),
            const SizedBox(height: 24),
            _buildPerformanceSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 정보',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    child['name'].substring(0, 1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem('이름', child['name']),
                      const SizedBox(height: 8),
                      _buildInfoItem('나이', '${child['age']}세'),
                      const SizedBox(height: 8),
                      _buildInfoItem('학년', child['grade']),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademiesSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '학원 정보',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...child['academies'].map<Widget>((academy) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          academy['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem('과목', academy['subjects'].join(', ')),
                    const SizedBox(height: 4),
                    _buildInfoItem('등록일', academy['startDate']),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '학습 현황',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPerformanceItem(
                  context,
                  Icons.check_circle,
                  '출석률',
                  '${child['attendance']}%',
                  _getAttendanceColor(child['attendance']),
                ),
                _buildPerformanceItem(
                  context,
                  Icons.score,
                  '평균 점수',
                  '${child['testScore']}점',
                  _getScoreColor(child['testScore']),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // 성적 및 출석 상세 조회 화면으로 이동
              },
              icon: const Icon(Icons.assessment),
              label: const Text('상세 성적 및 출석 조회'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Color _getAttendanceColor(int attendance) {
    if (attendance >= 95) return Colors.green;
    if (attendance >= 85) return Colors.orange;
    return Colors.red;
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
