import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/chat_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/chat_model.dart';
import '../../models/student_model.dart';

/// 채팅 화면
class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  bool _isMobile = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // ViewModel 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await Provider.of<ChatViewModel>(
        context,
        listen: false,
      ).initialize(authViewModel: authViewModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    // 화면 크기에 따라 모바일 여부 결정
    _isMobile = MediaQuery.of(context).size.width < 600;

    if (chatViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatViewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '채팅 로드 중 문제가 발생했습니다',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${chatViewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                chatViewModel.clearError();
                await chatViewModel.initialize();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 모바일 화면에서는 채팅방이 선택되었을 때만 채팅 내용 표시, 아니면 채팅방 목록만 표시
    if (_isMobile) {
      return chatViewModel.selectedChatRoom != null
          ? _buildChatScreen(chatViewModel, authViewModel, showBackButton: true)
          : _buildChatRoomsList(chatViewModel, authViewModel);
    }

    // 태블릿/데스크톱 화면에서는 분할 화면 표시
    return Row(
      children: [
        // 좌측 채팅방 목록
        Expanded(
          flex: 1,
          child: _buildChatRoomsList(chatViewModel, authViewModel),
        ),
        // 우측 채팅 화면
        Expanded(
          flex: 2,
          child:
              chatViewModel.selectedChatRoom != null
                  ? _buildChatScreen(chatViewModel, authViewModel)
                  : const Center(child: Text('채팅방을 선택하세요')),
        ),
      ],
    );
  }

  // 채팅방 목록
  Widget _buildChatRoomsList(
    ChatViewModel chatViewModel,
    AuthViewModel authViewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // 채팅방 추가 버튼 (선생님만 보임)
          if (chatViewModel.isTeacher)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed:
                    () => _showCreateChatRoomDialog(context, chatViewModel),
                icon: const Icon(Icons.add),
                label: const Text('새 채팅방'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ),

          // 채팅방 목록 제목
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '학부모 채팅방 목록',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // 채팅방 목록
          Expanded(
            child:
                chatViewModel.chatRooms.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text('채팅방이 없습니다'),
                          if (chatViewModel.isTeacher)
                            TextButton(
                              onPressed: () => chatViewModel.initialize(),
                              child: const Text('채팅방 생성하기'),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: chatViewModel.chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = chatViewModel.chatRooms[index];
                        final isSelected =
                            chatViewModel.selectedChatRoom?.id == chatRoom.id;

                        return _buildChatRoomItem(
                          chatRoom: chatRoom,
                          isSelected: isSelected,
                          isTeacher: chatViewModel.isTeacher,
                          onTap: () => chatViewModel.selectChatRoom(chatRoom),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // 채팅방 아이템
  Widget _buildChatRoomItem({
    required ChatRoom chatRoom,
    required bool isSelected,
    required bool isTeacher,
    required VoidCallback onTap,
  }) {
    final displayName = isTeacher ? chatRoom.parentName : chatRoom.teacherName;
    final hasUnread = chatRoom.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        selected: isSelected,
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          chatRoom.lastMessageContent.isNotEmpty
              ? chatRoom.lastMessageContent
              : '새로운 채팅방',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
            color: hasUnread ? Colors.black87 : Colors.grey,
          ),
        ),
        trailing:
            hasUnread
                ? CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    '${chatRoom.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : Text(
                  _formatDate(chatRoom.lastMessageTime),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
      ),
    );
  }

  // 날짜 포맷 함수
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('a h:mm', 'ko').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE', 'ko').format(dateTime);
    } else {
      return DateFormat('yy/MM/dd', 'ko').format(dateTime);
    }
  }

  // 채팅 화면
  Widget _buildChatScreen(
    ChatViewModel chatViewModel,
    AuthViewModel authViewModel, {
    bool showBackButton = false,
  }) {
    final chatRoom = chatViewModel.selectedChatRoom!;
    final user = authViewModel.user;
    final isTeacher = chatViewModel.isTeacher;
    final studentName = chatRoom.studentName;
    final parentName = chatRoom.parentName;
    final teacherName = chatRoom.teacherName;

    return Scaffold(
      appBar: AppBar(
        leading:
            showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _clearSelectedChatRoom(chatViewModel),
                )
                : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isTeacher ? parentName : teacherName),
            if (studentName.isNotEmpty)
              Text(
                '학생: $studentName',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showChatInfoDialog(context, chatRoom),
          ),
        ],
      ),
      body: Column(
        children: [
          // 채팅 메시지 목록
          Expanded(child: _buildMessageList(chatViewModel, user!.uid)),
          // 메시지 입력 영역
          _buildMessageComposer(chatViewModel),
        ],
      ),
    );
  }

  // 선택된 채팅방 지우기
  void _clearSelectedChatRoom(ChatViewModel chatViewModel) {
    // 이 메서드는 주로 모바일에서 채팅방에서 뒤로 가기를 눌렀을 때 실행
    chatViewModel.selectChatRoom(null);
  }

  // 메시지 목록
  Widget _buildMessageList(ChatViewModel chatViewModel, String userId) {
    if (chatViewModel.messages.isEmpty) {
      return const Center(child: Text('메시지가 없습니다. 대화를 시작해보세요.'));
    }

    // 새 메시지가 도착하면 자동으로 스크롤 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: chatViewModel.messages.length,
      itemBuilder: (context, index) {
        final message = chatViewModel.messages[index];
        final previousMessage =
            index > 0 ? chatViewModel.messages[index - 1] : null;
        final isFirstOfDay =
            previousMessage == null ||
            !_isSameDay(message.timestamp, previousMessage.timestamp);
        final isMe = message.senderId == userId;

        return Column(
          children: [
            if (isFirstOfDay) _buildDateDivider(message.timestamp),
            _buildMessageItem(message, isMe),
          ],
        );
      },
    );
  }

  // 날짜 구분선
  Widget _buildDateDivider(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              DateFormat('yyyy년 MM월 dd일', 'ko').format(date),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  // 같은 날짜인지 확인하는 함수
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 메시지 아이템
  Widget _buildMessageItem(ChatMessage message, bool isMe) {
    final time = DateFormat('a h:mm', 'ko').format(message.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe)
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  message.senderName.isNotEmpty
                      ? message.senderName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (!isMe) const SizedBox(width: 8),
            Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * (isMe ? 0.6 : 0.7),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
            if (isMe) const SizedBox(width: 8),
            Text(
              time,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // 메시지 입력 영역
  Widget _buildMessageComposer(ChatViewModel chatViewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            color: Colors.grey.shade200,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted:
                  _isComposing
                      ? (value) => _handleSubmitted(chatViewModel)
                      : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.blue,
            onPressed:
                _isComposing ? () => _handleSubmitted(chatViewModel) : null,
          ),
        ],
      ),
    );
  }

  // 메시지 전송 처리
  void _handleSubmitted(ChatViewModel chatViewModel) async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    if (!mounted) return;
    await chatViewModel.sendMessage(message);

    // 전송 후 스크롤 처리
    if (!mounted) return;
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // 채팅을 위한 학생 목록 가져오기
  Future<List<StudentModel>> _getStudentsForChat(
    ChatViewModel chatViewModel,
  ) async {
    // 간단하게 현재 students 목록 반환
    if (!mounted) return [];
    return chatViewModel.students;
  }

  // 새 채팅방 생성
  Future<bool> _createNewChatRoom(
    ChatViewModel chatViewModel,
    StudentModel student,
  ) async {
    // 학생 모델 객체로 채팅방 생성
    if (!mounted) return false;
    return await chatViewModel.createChatRoom(student);
  }

  // 채팅방 생성 다이얼로그
  Future<void> _showCreateChatRoomDialog(
    BuildContext context,
    ChatViewModel chatViewModel,
  ) async {
    final students = await _getStudentsForChat(chatViewModel);
    if (!context.mounted) return;

    if (students.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('학생 목록을 불러올 수 없습니다')));
      return;
    }

    String? selectedStudentId;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('학부모와 채팅하기'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('채팅할 학생을 선택하세요'),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(student.name[0])),
                        title: Text(student.name),
                        subtitle: Text('학부모: ${student.parentId ?? "미지정"}'),
                        onTap: () {
                          selectedStudentId = student.id;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );

    if (selectedStudentId != null && context.mounted) {
      // 선택된 학생 ID로 채팅방 생성
      final success = await _createNewChatRoom(
        chatViewModel,
        students.firstWhere((s) => s.id == selectedStudentId),
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('채팅방이 생성되었습니다')));
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(chatViewModel.error ?? '채팅방 생성에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 채팅방 정보 다이얼로그
  void _showChatInfoDialog(BuildContext context, ChatRoom chatRoom) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('채팅방 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('학생', chatRoom.studentName),
              const SizedBox(height: 8),
              _buildInfoItem('학부모', chatRoom.parentName),
              const SizedBox(height: 8),
              _buildInfoItem('선생님', chatRoom.teacherName),
              const SizedBox(height: 8),
              _buildInfoItem(
                '시작일',
                DateFormat(
                  'yyyy년 MM월 dd일',
                  'ko',
                ).format(chatRoom.lastMessageTime),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  // 정보 항목 위젯
  Widget _buildInfoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
