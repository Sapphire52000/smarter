import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/student_model.dart';
import '../services/chat_service.dart';
import '../services/student_service.dart';
import '../services/auth_service.dart';
import '../services/attendance_service.dart';
import '../models/attendance_model.dart';
import '../viewmodels/auth_view_model.dart';

/// 채팅 뷰모델
class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final StudentService _studentService = StudentService();
  final AuthService _authService = AuthService();
  final AttendanceService _attendanceService = AttendanceService();

  // AuthViewModel 참조 저장
  AuthViewModel? _authViewModel;

  // 채팅방 목록
  List<ChatRoom> _chatRooms = [];
  List<ChatRoom> get chatRooms => _chatRooms;

  // 현재 선택된 채팅방
  ChatRoom? _selectedChatRoom;
  ChatRoom? get selectedChatRoom => _selectedChatRoom;

  // 현재 채팅방의 메시지
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  // 사용자가 교사인지 여부
  bool _isTeacher = false;
  bool get isTeacher => _isTeacher;

  // 학생 목록 (교사의 경우)
  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  // 스트림 구독
  StreamSubscription? _chatRoomsSubscription;
  StreamSubscription? _messagesSubscription;

  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 오류 상태
  String? _error;
  String? get error => _error;

  // 초기화 - AuthViewModel 전달 받도록 수정
  Future<void> initialize({AuthViewModel? authViewModel}) async {
    _setLoading(true);
    _error = null;

    try {
      final user = _authService.currentUser;
      if (user == null) {
        _error = '로그인이 필요합니다';
        _setLoading(false);
        return;
      }

      // AuthViewModel 저장
      _authViewModel = authViewModel;

      // 사용자 역할 확인
      bool isTeacherOrAcademy = false;

      if (_authViewModel != null) {
        // AuthViewModel에서 역할 가져오기
        final userRole = _authViewModel!.userRole;
        debugPrint('현재 사용자 역할: $userRole');
        isTeacherOrAcademy = userRole == 'teacher' || userRole == 'academy';
      } else {
        // 기존 방식으로 이메일로 확인 (폴백)
        final userEmail = user.email ?? '';
        isTeacherOrAcademy =
            userEmail.contains('teacher') || userEmail.contains('academy');
        debugPrint(
          'AuthViewModel 없음, 이메일로 역할 확인: $userEmail -> 교사/학원: $isTeacherOrAcademy',
        );
      }

      _isTeacher = isTeacherOrAcademy;

      // 교사인 경우 학생 목록 로드
      if (_isTeacher) {
        // 모든 학생 로드 (스트림으로부터 한 번만 로드)
        final studentsStream = _studentService.getStudents();
        _students = await studentsStream.first;

        // 채팅방 구독
        _subscribeToTeacherChatRooms(user.uid);
      } else {
        // 학부모인 경우 자신의 채팅방만 구독
        _subscribeToChatRoomsByParentId(user.uid);
      }

      // 샘플 채팅방 생성 (테스트 목적) - 비동기 작업으로 처리하고 기다립니다
      await _createSampleChatRooms(user);
    } catch (e) {
      _error = '초기화 중 오류가 발생했습니다: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // 채팅방이 없을 경우 기본 채팅방 생성 확인
  Future<void> _checkAndCreateDefaultChatRooms() async {
    // 이미 채팅방이 있으면 아무것도 하지 않음
    if (_chatRooms.isNotEmpty) return;

    final user = _authService.currentUser;
    if (user == null) return;

    try {
      if (_isTeacher) {
        // 교사인 경우 학생 데이터가 있으면 첫 학생과의 채팅방 생성
        if (_students.isNotEmpty) {
          // 첫 번째 학생과 채팅방 생성
          final student = _students.first;

          final roomId = await _chatService.createChatRoom(
            teacherId: user.uid,
            teacherName: user.displayName ?? '선생님',
            parentId: student.parentId ?? 'default-parent-id',
            parentName: '${student.name}의 학부모',
            studentId: student.id,
            studentName: student.name,
          );

          if (roomId.isNotEmpty) {
            // 환영 메시지 보내기
            await _chatService.sendMessage(
              roomId: roomId,
              senderId: 'system',
              senderName: '시스템',
              senderRole: 'system',
              content: '환영합니다! 학부모님과의 채팅이 시작되었습니다.',
            );

            // 생성된 채팅방 자동 선택
            final createdRoom = await _getChatRoomById(roomId);
            if (createdRoom != null) {
              await selectChatRoom(createdRoom);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('기본 채팅방 생성 오류: $e');
    }
  }

  // 샘플 채팅방 생성
  Future<void> _createSampleChatRooms(user) async {
    try {
      if (_isTeacher) {
        // 학원/교사 입장에서 3개의 학부모 채팅방 생성
        await _createParentChatRoom(
          user: user,
          parentId: 'parent-id-1',
          parentName: '김서현 학부모',
          studentId: 'student-id-1',
          studentName: '김서현',
          messages: [
            {'role': 'system', 'content': '채팅방이 생성되었습니다.'},
            {'role': 'parent', 'content': '안녕하세요, 선생님! 우리 아이 수업은 잘 듣고 있나요?'},
            {'role': 'teacher', 'content': '네, 서현이는 수업 참여도도 좋고 과제도 잘 해오고 있어요.'},
            {
              'role': 'parent',
              'content': '다행이네요! 다음 주 화요일은 병원 검진이 있어서 결석할 것 같아요.',
            },
          ],
        );

        await _createParentChatRoom(
          user: user,
          parentId: 'parent-id-2',
          parentName: '이준우 학부모',
          studentId: 'student-id-2',
          studentName: '이준우',
          messages: [
            {'role': 'system', 'content': '채팅방이 생성되었습니다.'},
            {'role': 'parent', 'content': '선생님, 다음 달 시험 일정이 어떻게 되나요?'},
            {'role': 'teacher', 'content': '다음 달 15일에 중간고사가 예정되어 있습니다.'},
            {'role': 'parent', 'content': '알겠습니다. 시험 범위를 알려주실 수 있을까요?'},
            {
              'role': 'teacher',
              'content': '네, 준우에게 시험 범위 프린트를 오늘 나눠드렸어요. 확인해보세요!',
            },
          ],
        );

        await _createParentChatRoom(
          user: user,
          parentId: 'parent-id-3',
          parentName: '박민지 학부모',
          studentId: 'student-id-3',
          studentName: '박민지',
          messages: [
            {'role': 'system', 'content': '채팅방이 생성되었습니다.'},
            {'role': 'parent', 'content': '선생님, 아이가 조금 아파서 오늘은 결석할 것 같습니다.'},
            {
              'role': 'teacher',
              'content': '알겠습니다. 건강이 최우선이니 푹 쉬게 해주세요. 빠진 수업 내용은 내일 보충해드릴게요.',
            },
            {'role': 'parent', 'content': '감사합니다. 내일은 등원할 수 있을 것 같아요.'},
            {'role': 'teacher', 'content': '네, 내일 뵙겠습니다! 민지에게 쾌유를 빕니다.'},
          ],
        );
      } else {
        // 학부모용 샘플 채팅방
        final roomId = await _chatService.createChatRoom(
          teacherId: 'sample-teacher-id',
          teacherName: '김선생님',
          parentId: user.uid,
          parentName: user.displayName ?? '학부모',
          studentId: 'sample-student-id',
          studentName: '내 자녀',
        );

        if (roomId.isNotEmpty) {
          // 샘플 메시지 보내기
          await _chatService.sendMessage(
            roomId: roomId,
            senderId: 'system',
            senderName: '시스템',
            senderRole: 'system',
            content: '환영합니다! 이곳에서 선생님과 대화를 나눌 수 있습니다.',
          );

          await _chatService.sendMessage(
            roomId: roomId,
            senderId: 'sample-teacher-id',
            senderName: '김선생님',
            senderRole: 'teacher',
            content: '안녕하세요, 학부모님! 문의사항이 있으시면 언제든지 물어보세요.',
          );

          // 생성된 채팅방 자동 선택
          final createdRoom = await _getChatRoomById(roomId);
          if (createdRoom != null) {
            await selectChatRoom(createdRoom);
          }
        }
      }
    } catch (e) {
      _error = '채팅방 생성 중 오류가 발생했습니다: $e';
      debugPrint(_error);
    }
  }

  // 학부모 채팅방 생성 헬퍼 함수
  Future<void> _createParentChatRoom({
    required user,
    required String parentId,
    required String parentName,
    required String studentId,
    required String studentName,
    required List<Map<String, String>> messages,
  }) async {
    final roomId = await _chatService.createChatRoom(
      teacherId: user.uid,
      teacherName: user.displayName ?? '선생님',
      parentId: parentId,
      parentName: parentName,
      studentId: studentId,
      studentName: studentName,
    );

    if (roomId.isNotEmpty) {
      // 메시지 전송
      for (final message in messages) {
        final role = message['role'] ?? 'system';
        final content = message['content'] ?? '';

        String senderId;
        String senderName;

        if (role == 'parent') {
          senderId = parentId;
          senderName = parentName;
        } else if (role == 'teacher') {
          senderId = user.uid;
          senderName = user.displayName ?? '선생님';
        } else {
          senderId = 'system';
          senderName = '시스템';
        }

        await _chatService.sendMessage(
          roomId: roomId,
          senderId: senderId,
          senderName: senderName,
          senderRole: role,
          content: content,
          relatedStudentId: studentId,
        );
      }
    }
  }

  // 선생님 ID로 채팅방 구독
  void _subscribeToTeacherChatRooms(String teacherId) {
    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = _chatService
        .getChatRoomsByTeacherId(teacherId)
        .listen(
          _updateChatRooms,
          onError: (e) {
            _error = '채팅방 로드 중 오류가 발생했습니다: $e';
            debugPrint(_error);
            notifyListeners();
          },
        );
  }

  // 학부모 ID로 채팅방 구독
  void _subscribeToChatRoomsByParentId(String parentId) {
    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = _chatService
        .getChatRoomsByParentId(parentId)
        .listen(
          _updateChatRooms,
          onError: (e) {
            _error = '채팅방 로드 중 오류가 발생했습니다: $e';
            debugPrint(_error);
            notifyListeners();
          },
        );
  }

  // 채팅방 선택
  Future<void> selectChatRoom(ChatRoom? chatRoom) async {
    _selectedChatRoom = chatRoom;
    _messages = [];
    notifyListeners();

    // 선택된 채팅방이 없으면 메시지 구독 취소
    if (chatRoom == null) {
      _messagesSubscription?.cancel();
      return;
    }

    // 메시지 구독
    _subscribeToMessages(chatRoom.id);

    // 선생님인 경우 메시지 읽음 처리
    if (_isTeacher) {
      final user = _authService.currentUser;
      if (user != null) {
        await _chatService.markMessagesAsRead(chatRoom.id, user.uid);
      }
    }
  }

  // 채팅방 메시지 구독
  void _subscribeToMessages(String roomId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService
        .getChatMessages(roomId)
        .listen(
          (messages) {
            _messages = messages;
            notifyListeners();
          },
          onError: (e) {
            _error = '메시지 로드 중 오류가 발생했습니다: $e';
            debugPrint(_error);
            notifyListeners();
          },
        );
  }

  // 채팅방 목록 업데이트
  void _updateChatRooms(List<ChatRoom> chatRooms) {
    _chatRooms = chatRooms;

    // 선택된 채팅방이 있으면 업데이트
    if (_selectedChatRoom != null) {
      final updatedRoom = chatRooms.firstWhereOrNull(
        (room) => room.id == _selectedChatRoom!.id,
      );

      if (updatedRoom != null) {
        _selectedChatRoom = updatedRoom;
      }
    }

    // 채팅방 초기 선택 로직
    if (_selectedChatRoom == null && chatRooms.isNotEmpty) {
      // 채팅방이 있지만 선택된 것이 없으면 첫 번째 채팅방 선택
      selectChatRoom(chatRooms.first);
    } else if (chatRooms.isEmpty) {
      // 채팅방이 없는 경우 기본 채팅방 생성 시도
      _checkAndCreateDefaultChatRooms();
    }

    notifyListeners();
  }

  // 메시지 전송
  Future<bool> sendMessage(String message) async {
    if (_selectedChatRoom == null || message.trim().isEmpty) {
      return false;
    }

    final user = _authService.currentUser;
    if (user == null) {
      _error = '로그인이 필요합니다';
      notifyListeners();
      return false;
    }

    final role = _isTeacher ? 'teacher' : 'parent';
    final studentId = _selectedChatRoom!.studentId;

    try {
      return await _chatService.sendMessage(
        roomId: _selectedChatRoom!.id,
        senderId: user.uid,
        senderName: user.displayName ?? '사용자',
        senderRole: role,
        content: message,
        relatedStudentId: studentId,
      );
    } catch (e) {
      _error = '메시지 전송 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // 새 채팅방 생성 (선생님 전용)
  Future<bool> createChatRoom(StudentModel student) async {
    if (!_isTeacher) {
      _error = '선생님만 채팅방을 생성할 수 있습니다';
      notifyListeners();
      return false;
    }

    final teacher = _authService.currentUser;
    if (teacher == null) {
      _error = '로그인이 필요합니다';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);

      final roomId = await _chatService.createChatRoom(
        teacherId: teacher.uid,
        teacherName: teacher.displayName ?? '선생님',
        parentId: student.parentId ?? '',
        parentName: student.name, // 실제로는 학부모 이름이 필요할 수 있음
        studentId: student.id,
        studentName: student.name,
      );

      if (roomId.isEmpty) {
        _error = '채팅방 생성에 실패했습니다';
        return false;
      }

      // 채팅방을 찾아서 선택
      final createdRoom = await _getChatRoomById(roomId);
      if (createdRoom != null) {
        await selectChatRoom(createdRoom);
      }

      return true;
    } catch (e) {
      _error = '채팅방 생성 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ID로 채팅방 가져오기
  Future<ChatRoom?> _getChatRoomById(String roomId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot =
          await firestore.collection('chatRooms').doc(roomId).get();
      if (snapshot.exists) {
        return ChatRoom.fromFirestore(snapshot);
      }
      return null;
    } catch (e) {
      debugPrint('채팅방 조회 오류: $e');
      return null;
    }
  }

  // 채팅 메시지에서 출석 정보 추출하기
  Future<bool> processAttendanceFromMessage(ChatMessage message) async {
    if (!_isTeacher || _selectedChatRoom == null) return false;

    // 메시지가 학부모로부터 온 것인지 확인
    if (message.senderRole != 'parent') return false;

    final studentId = _selectedChatRoom!.studentId;
    final content = message.content.toLowerCase();

    // 출석 관련 키워드 체크
    bool isPresent = false;
    bool isAbsent = false;
    bool isLate = false;
    DateTime? attendanceDate;

    // 출석 키워드 확인
    if (content.contains('출석') || content.contains('등원')) {
      isPresent = true;
    }
    // 결석 키워드 확인
    else if (content.contains('결석') ||
        content.contains('못감') ||
        content.contains('못 감')) {
      isAbsent = true;
    }
    // 지각 키워드 확인
    else if (content.contains('지각') || content.contains('늦을')) {
      isLate = true;
    }
    // 출석 관련 메시지가 아님
    else {
      return false;
    }

    // 날짜 정보 추출 시도 (오늘/내일/특정 날짜)
    if (content.contains('오늘')) {
      attendanceDate = DateTime.now();
    } else if (content.contains('내일')) {
      attendanceDate = DateTime.now().add(const Duration(days: 1));
    } else if (content.contains('모레')) {
      attendanceDate = DateTime.now().add(const Duration(days: 2));
    }

    // 날짜 정보가 없으면 기본적으로 오늘
    attendanceDate ??= DateTime.now();

    try {
      // 학생 출석 상태 업데이트 (여기서는 실제 수업 ID 필요)
      // 실제 구현에서는 학생의 해당 날짜 수업을 찾아서 처리해야 함
      // 임시로 "default-class-id"를 사용
      const defaultClassId = "default-class-id";

      AttendanceStatus status;
      String note;

      if (isPresent) {
        status = AttendanceStatus.present;
        note = '학부모 채팅으로 자동 출석 처리됨';
      } else if (isAbsent) {
        status = AttendanceStatus.absent;
        note = '학부모 채팅으로 자동 결석 처리됨';
      } else {
        status = AttendanceStatus.late;
        note = '학부모 채팅으로 자동 지각 처리됨';
      }

      await _attendanceService.createAttendance(
        classId: defaultClassId,
        studentId: studentId,
        date: attendanceDate,
        status: status,
        note: note,
      );

      // 처리 성공 메시지 전송
      final dateString =
          '${attendanceDate.year}년 ${attendanceDate.month}월 ${attendanceDate.day}일';
      String statusMessage = isPresent ? '출석' : (isAbsent ? '결석' : '지각');

      await sendMessage(
        '$dateString ${_selectedChatRoom!.studentName} 학생의 출결 상태가 \'$statusMessage\'으로 자동 처리되었습니다.',
      );
      return true;
    } catch (e) {
      _error = '출석 처리 중 오류가 발생했습니다: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 오류 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
