import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/student_model.dart';
import '../../../../models/repositories/student_repository.dart';

/// 학생 추가 다이얼로그
class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  final StudentRepository _studentRepository = StudentRepository();

  // 학생 정보 필드
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _gradeController.dispose();
    _parentPhoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('학생 추가'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNameField(),
              const SizedBox(height: 16),
              _buildSchoolField(),
              const SizedBox(height: 16),
              _buildGradeField(),
              const SizedBox(height: 16),
              _buildParentPhoneField(),
              const SizedBox(height: 16),
              _buildNoteField(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        _isSubmitting
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _submitForm, child: const Text('저장')),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '이름',
        hintText: '학생 이름을 입력하세요',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '이름을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildSchoolField() {
    return TextFormField(
      controller: _schoolController,
      decoration: const InputDecoration(
        labelText: '학교',
        hintText: '예) 서울초등학교',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.account_balance),
      ),
    );
  }

  Widget _buildGradeField() {
    return TextFormField(
      controller: _gradeController,
      decoration: const InputDecoration(
        labelText: '학년',
        hintText: '예) 3학년',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.school),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '학년을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildParentPhoneField() {
    return TextFormField(
      controller: _parentPhoneController,
      decoration: const InputDecoration(
        labelText: '학부모 연락처',
        hintText: '010-0000-0000',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.contact_phone),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '학부모 연락처를 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: '특이사항',
        hintText: '학생에 대한 특이사항을 입력하세요',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 학교와 학년을 합쳐서 grade 필드에 저장
      String fullGrade = "";
      if (_schoolController.text.isNotEmpty) {
        fullGrade = "${_schoolController.text} ${_gradeController.text}";
      } else {
        fullGrade = _gradeController.text;
      }

      // Firebase에 저장
      final now = DateTime.now();
      final studentModel = StudentModel(
        id: '',
        name: _nameController.text.trim(),
        age: 0,
        grade: fullGrade.trim(),
        contactNumber: '',
        enrolledClasses: [],
        additionalInfo: {
          'parentPhoneNumber': _parentPhoneController.text.trim(),
          'note': _noteController.text.trim(),
          'attendanceRate': 0,
        },
        createdAt: now,
        updatedAt: now,
      );
      await _studentRepository.addStudent(studentModel);

      // 입력 데이터를 반환하며 다이얼로그 종료
      if (mounted) {
        Navigator.pop(context, {
          'name': _nameController.text.trim(),
          'grade': fullGrade.trim(),
          'parentPhoneNumber': _parentPhoneController.text.trim(),
          'note': _noteController.text.trim(),
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('학생이 추가되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('학생 추가 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
