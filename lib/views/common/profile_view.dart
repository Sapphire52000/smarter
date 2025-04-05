import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';

/// 공통 프로필 화면
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.user;

    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: '010-1234-5678'); // 임시 데이터
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.user;
    final userRole = authViewModel.userRole;

    String roleText = '사용자';
    IconData roleIcon = Icons.person;

    // 역할에 따른 아이콘 및 텍스트 설정
    switch (userRole) {
      case 'academy':
        roleText = '학원 관리자';
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'teacher':
        roleText = '선생님';
        roleIcon = Icons.school;
        break;
      case 'parent':
        roleText = '학부모';
        roleIcon = Icons.family_restroom;
        break;
      case 'student':
        roleText = '학생';
        roleIcon = Icons.face;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
        actions: [
          _isEditing
              ? IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveProfile,
                tooltip: '저장',
              )
              : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _toggleEditMode,
                tooltip: '수정',
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(user, roleText, roleIcon),
            const SizedBox(height: 24),
            _buildProfileDetails(),
            const SizedBox(height: 32),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user, String roleText, IconData roleIcon) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: Icon(roleIcon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? '사용자',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.5)),
            ),
            child: Text(
              roleText,
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '개인 정보',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildProfileItem(
          '이름',
          _isEditing
              ? _buildTextField(_nameController, '이름')
              : _nameController.text,
          Icons.person,
        ),
        const Divider(height: 16),
        _buildProfileItem(
          '이메일',
          _isEditing
              ? _buildTextField(_emailController, '이메일', enabled: false)
              : _emailController.text,
          Icons.email,
        ),
        const Divider(height: 16),
        _buildProfileItem(
          '전화번호',
          _isEditing
              ? _buildTextField(_phoneController, '전화번호')
              : _phoneController.text,
          Icons.phone,
        ),
      ],
    );
  }

  Widget _buildProfileItem(String label, dynamic content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                if (content is Widget) content else Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '설정',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildSettingItem(
          '앱 알림',
          '수업 일정, 메시지 등 알림 설정',
          Icons.notifications,
          () => _showNotificationSettings(),
        ),
        _buildSettingItem(
          '앱 테마',
          '다크 모드 및 색상 테마 설정',
          Icons.color_lens,
          () => _showThemeSettings(),
        ),
        _buildSettingItem(
          '비밀번호 변경',
          '계정 비밀번호 변경',
          Icons.lock,
          () => _showChangePasswordDialog(),
        ),
        _buildSettingItem(
          '로그아웃',
          '앱에서 로그아웃',
          Icons.logout,
          () => _showLogoutConfirmation(),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color ?? Colors.grey[700]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveProfile() {
    // 이름과 전화번호 저장 로직 (실제 앱에서는 API 호출 필요)
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('프로필이 저장되었습니다')));
  }

  void _showNotificationSettings() {
    // 알림 설정 화면으로 이동 또는 다이얼로그 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showThemeSettings() {
    // 테마 설정 화면으로 이동 또는 다이얼로그 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showChangePasswordDialog() {
    // 비밀번호 변경 다이얼로그 표시
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 기능은 준비 중입니다')));
  }

  void _showLogoutConfirmation() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  authViewModel.signOut();
                  Navigator.pop(context); // 대화상자 닫기
                  Navigator.pop(context); // 프로필 화면 닫기
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );
  }
}
