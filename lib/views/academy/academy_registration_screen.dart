import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/academy_request_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/academy_request_view_model.dart';
import '../../viewmodels/auth_view_model.dart';

/// 학원 등록 신청 화면 (학원장용)
class AcademyRegistrationScreen extends StatefulWidget {
  const AcademyRegistrationScreen({super.key});

  @override
  State<AcademyRegistrationScreen> createState() =>
      _AcademyRegistrationScreenState();
}

class _AcademyRegistrationScreenState extends State<AcademyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hasPendingRequest = false;
  AcademyRequestModel? _pendingRequest;

  // 폼 필드 컨트롤러
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessNumberController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 기존 신청 내역 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingRequests();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _businessNumberController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // 대기 중인 신청 확인
  Future<void> _checkPendingRequests() async {
    final viewModel = Provider.of<AcademyRequestViewModel>(
      context,
      listen: false,
    );

    await viewModel.loadMyRequests();
    final pendingRequests = viewModel.pendingRequests;

    setState(() {
      _hasPendingRequest = pendingRequests.isNotEmpty;
      if (_hasPendingRequest) {
        _pendingRequest = pendingRequests.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showCancelConfirmation(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('학원 등록 신청'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _showCancelConfirmation(context),
          ),
        ),
        body: Consumer<AcademyRequestViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 대기 중인 신청이 있는 경우
            if (_hasPendingRequest && _pendingRequest != null) {
              return _buildPendingRequestView(_pendingRequest!);
            }

            // 새 신청 폼
            return _buildRegistrationForm(viewModel);
          },
        ),
      ),
    );
  }

  // 대기 중인 신청 화면
  Widget _buildPendingRequestView(AcademyRequestModel request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(Icons.hourglass_top, color: Colors.orange, size: 64),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '학원 등록 신청 검토 중',
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '신청하신 학원 등록 건이 관리자에 의해 검토 중입니다.\n승인 또는 거절 결과가 나오면 알려드리겠습니다.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('신청 정보', style: AppTheme.headingSmall),
                  const SizedBox(height: 16),
                  _buildInfoRow('학원명', request.academyName),
                  _buildInfoRow('주소', request.address),
                  _buildInfoRow('전화번호', request.phoneNumber),
                  _buildInfoRow('이메일', request.email),
                  _buildInfoRow('사업자등록번호', request.businessRegistrationNumber),
                  _buildInfoRow('신청일', _formatDate(request.requestDate)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (request.message.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('추가 메시지', style: AppTheme.headingSmall),
                    const SizedBox(height: 8),
                    Text(request.message),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 새 신청 폼
  Widget _buildRegistrationForm(AcademyRequestViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('학원 정보 입력', style: AppTheme.headingMedium),
            const SizedBox(height: 8),
            const Text('학원 등록을 위해 아래 정보를 입력해주세요. 관리자 검토 후 승인됩니다.'),
            const SizedBox(height: 24),

            // 학원명
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '학원명',
                hintText: '예: 서울 핑퐁 아카데미',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '학원명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 주소
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '주소',
                hintText: '예: 서울특별시 강남구 테헤란로 123',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '주소를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 전화번호
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '전화번호',
                hintText: '예: 02-123-4567',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '전화번호를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 이메일
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                hintText: '예: info@example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요';
                }
                if (!value.contains('@')) {
                  return '유효한 이메일 주소를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 사업자등록번호
            TextFormField(
              controller: _businessNumberController,
              decoration: const InputDecoration(
                labelText: '사업자등록번호',
                hintText: '예: 123-45-67890',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '사업자등록번호를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 추가 메시지
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: '추가 메시지 (선택사항)',
                hintText: '관리자에게 전달할 추가 메시지가 있으면 입력해주세요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 에러 메시지
            if (viewModel.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            const SizedBox(height: 24),

            // 등록 신청 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => _submitForm(viewModel),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('학원 등록 신청하기'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _showCancelConfirmation(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('이전 화면으로 돌아가기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 신청서 제출 처리
  Future<void> _submitForm(AcademyRequestViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    // 신청 모델 생성
    final request = AcademyRequestModel(
      id: '',
      ownerUid: user.uid,
      ownerName: user.displayName ?? '',
      academyName: _nameController.text,
      address: _addressController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text,
      businessRegistrationNumber: _businessNumberController.text,
      message: _messageController.text,
      status: 'pending',
      requestDate: DateTime.now(),
    );

    // 제출
    final success = await viewModel.submitRequest(request);

    if (!mounted) return;

    if (success) {
      setState(() {
        _hasPendingRequest = true;
        _pendingRequest = request;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('학원 등록 신청이 제출되었습니다')));
    }
  }

  // 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // 취소 확인 다이얼로그
  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('학원 등록 취소'),
            content: const Text(
              '학원 등록을 취소하고 이전 화면으로 돌아가시겠습니까?\n입력하신 정보는 저장되지 않습니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('계속 작성하기'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 사용자 역할 재설정
                  final authViewModel = Provider.of<AuthViewModel>(
                    context,
                    listen: false,
                  );
                  authViewModel.resetUserRole();

                  // 이전 화면으로 돌아가기
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 학원 등록 화면 닫기
                },
                child: const Text('취소하고 돌아가기'),
              ),
            ],
          ),
    );
  }
}
