import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../viewmodels/schedule_view_model.dart';
import '../../../../../models/schedule_model.dart';

/// 일정 추가 다이얼로그
class AddScheduleDialog extends StatefulWidget {
  final ScheduleViewModel viewModel;
  final TimeOfDay? initialTime;

  const AddScheduleDialog({
    super.key,
    required this.viewModel,
    this.initialTime,
  });

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String _selectedColorHex = '#4285F4'; // 기본 색상: 파란색

  @override
  void initState() {
    super.initState();
    _initializeTimes();
  }

  void _initializeTimes() {
    // 초기 시작 시간 설정
    final now = DateTime.now();
    if (widget.initialTime != null) {
      _startDateTime = DateTime(
        widget.viewModel.selectedDate.year,
        widget.viewModel.selectedDate.month,
        widget.viewModel.selectedDate.day,
        widget.initialTime!.hour,
        0,
      );
      _endDateTime = DateTime(
        widget.viewModel.selectedDate.year,
        widget.viewModel.selectedDate.month,
        widget.viewModel.selectedDate.day,
        widget.initialTime!.hour + 1,
        0,
      );
    } else {
      // 기본 시간 설정 (현재 시간에서 가장 가까운 시간으로)
      final currentHour = now.hour;
      _startDateTime = DateTime(
        widget.viewModel.selectedDate.year,
        widget.viewModel.selectedDate.month,
        widget.viewModel.selectedDate.day,
        currentHour + 1,
        0,
      );
      _endDateTime = DateTime(
        widget.viewModel.selectedDate.year,
        widget.viewModel.selectedDate.month,
        widget.viewModel.selectedDate.day,
        currentHour + 2,
        0,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('일정 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 입력
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '일정 제목',
                hintText: '예: 수학 수업, 상담 일정 등',
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 12),

            // 설명 입력
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명 (선택사항)',
                hintText: '일정에 대한 간략한 설명을 입력하세요',
              ),
              maxLength: 200,
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // 시작 시간 선택
            _buildTimeSelector(
              label: '시작 시간',
              selectedTime: _startDateTime,
              onTap: () => _selectTime(context, isStart: true),
            ),
            const SizedBox(height: 12),

            // 종료 시간 선택
            _buildTimeSelector(
              label: '종료 시간',
              selectedTime: _endDateTime,
              onTap: () => _selectTime(context, isStart: false),
            ),
            const SizedBox(height: 16),

            // 색상 선택기
            _buildColorSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _isValidInput() ? () => _addSchedule(context) : null,
          child: const Text('추가'),
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required DateTime? selectedTime,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        child: Text(
          selectedTime != null
              ? DateFormat('yyyy.MM.dd HH:mm').format(selectedTime)
              : '시간 선택',
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    // 선택 가능한 색상 리스트
    final colors = [
      Color(int.parse('4285F4', radix: 16) | 0xFF000000), // blue
      Color(int.parse('EA4335', radix: 16) | 0xFF000000), // red
      Color(int.parse('34A853', radix: 16) | 0xFF000000), // green
      Color(int.parse('FBBC05', radix: 16) | 0xFF000000), // orange
      Color(int.parse('9C27B0', radix: 16) | 0xFF000000), // purple
      Color(int.parse('009688', radix: 16) | 0xFF000000), // teal
      Color(int.parse('E91E63', radix: 16) | 0xFF000000), // pink
      Color(int.parse('3F51B5', radix: 16) | 0xFF000000), // indigo
      Color(int.parse('FFC107', radix: 16) | 0xFF000000), // amber
      Color(int.parse('00BCD4', radix: 16) | 0xFF000000), // cyan
    ];

    // HEX 값 리스트
    const hexColors = [
      '#4285F4', // blue
      '#EA4335', // red
      '#34A853', // green
      '#FBBC05', // orange
      '#9C27B0', // purple
      '#009688', // teal
      '#E91E63', // pink
      '#3F51B5', // indigo
      '#FFC107', // amber
      '#00BCD4', // cyan
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('일정 색상'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(colors.length, (index) {
            final color = colors[index];
            final colorHex = hexColors[index];
            final isSelected = colorHex == _selectedColorHex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColorHex = colorHex;
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border:
                      isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _selectTime(
    BuildContext context, {
    required bool isStart,
  }) async {
    TimeOfDay initialTime;
    DateTime initialDate;

    if (isStart) {
      initialTime = TimeOfDay.fromDateTime(_startDateTime ?? DateTime.now());
      initialDate = _startDateTime ?? DateTime.now();
    } else {
      initialTime = TimeOfDay.fromDateTime(_endDateTime ?? DateTime.now());
      initialDate = _endDateTime ?? DateTime.now();
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          _startDateTime = DateTime(
            widget.viewModel.selectedDate.year,
            widget.viewModel.selectedDate.month,
            widget.viewModel.selectedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          // 만약 종료 시간이 시작 시간보다 이르면 종료 시간을 자동으로 조정
          if (_endDateTime != null && _endDateTime!.isBefore(_startDateTime!)) {
            _endDateTime = _startDateTime!.add(const Duration(hours: 1));
          }
        } else {
          _endDateTime = DateTime(
            widget.viewModel.selectedDate.year,
            widget.viewModel.selectedDate.month,
            widget.viewModel.selectedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          // 만약 종료 시간이 시작 시간보다 이르면 시작 시간을 자동으로 조정
          if (_startDateTime != null &&
              _endDateTime!.isBefore(_startDateTime!)) {
            _startDateTime = _endDateTime!.subtract(const Duration(hours: 1));
          }
        }
      });
    }
  }

  bool _isValidInput() {
    return _titleController.text.isNotEmpty &&
        _startDateTime != null &&
        _endDateTime != null &&
        _startDateTime!.isBefore(_endDateTime!);
  }

  void _addSchedule(BuildContext context) async {
    if (_startDateTime == null || _endDateTime == null) return;

    final newSchedule = ScheduleModel(
      id: '', // ID는 Firebase에서 자동 생성됨
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: _startDateTime!,
      endTime: _endDateTime!,
      colorHex: _selectedColorHex,
      createdAt: DateTime.now(),
      createdBy: '', // ViewModel에서 현재 사용자 ID 설정
      participants: [], // 기본 빈 리스트
      isRecurring: false, // 기본값
    );

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 일정 추가
    await widget.viewModel.addSchedule(newSchedule);

    if (!context.mounted) return;
    Navigator.pop(context); // 로딩 다이얼로그 닫기
    Navigator.pop(context); // 추가 다이얼로그 닫기

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('일정이 추가되었습니다')));
  }
}

/// 일정 추가 다이얼로그 호출 함수
Future<void> showAddScheduleDialog(
  BuildContext context,
  ScheduleViewModel viewModel, {
  TimeOfDay? initialTime,
}) async {
  await showDialog(
    context: context,
    builder:
        (context) =>
            AddScheduleDialog(viewModel: viewModel, initialTime: initialTime),
  );
}
