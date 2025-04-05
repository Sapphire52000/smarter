import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';

/// 채팅 서비스
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 컬렉션 참조
  CollectionReference get _chatRooms => _firestore.collection('chatRooms');

  // 특정 채팅방의 메시지 컬렉션 참조 가져오기
  CollectionReference _getChatMessages(String roomId) {
    return _chatRooms.doc(roomId).collection('messages');
  }

  // 선생님 ID로 채팅방 목록 조회
  Stream<List<ChatRoom>> getChatRoomsByTeacherId(String teacherId) {
    try {
      // 먼저 'active'와 'teacherId' 필드만으로 쿼리 수행
      return _chatRooms
          .where('teacherId', isEqualTo: teacherId)
          .where('active', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
            final rooms =
                snapshot.docs
                    .map((doc) => ChatRoom.fromFirestore(doc))
                    .toList();

            // 메모리에서 정렬 수행 (인덱스 오류 방지)
            rooms.sort(
              (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
            );
            return rooms;
          });
    } catch (e) {
      // 오류 발생 시 기본값 반환
      debugPrint('선생님 채팅방 목록 조회 오류: $e');
      return Stream.value([]);
    }
  }

  // 학부모 ID로 채팅방 목록 조회
  Stream<List<ChatRoom>> getChatRoomsByParentId(String parentId) {
    try {
      // 먼저 'active'와 'parentId' 필드만으로 쿼리 수행
      return _chatRooms
          .where('parentId', isEqualTo: parentId)
          .where('active', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
            final rooms =
                snapshot.docs
                    .map((doc) => ChatRoom.fromFirestore(doc))
                    .toList();

            // 메모리에서 정렬 수행 (인덱스 오류 방지)
            rooms.sort(
              (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
            );
            return rooms;
          });
    } catch (e) {
      // 오류 발생 시 기본값 반환
      debugPrint('학부모 채팅방 목록 조회 오류: $e');
      return Stream.value([]);
    }
  }

  // 메시지 목록 조회
  Stream<List<ChatMessage>> getChatMessages(String roomId) {
    try {
      return _getChatMessages(
        roomId,
      ).orderBy('timestamp', descending: false).snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      debugPrint('메시지 목록 조회 오류: $e');
      return Stream.value([]);
    }
  }

  // 새 채팅방 생성
  Future<String> createChatRoom({
    required String teacherId,
    required String teacherName,
    required String parentId,
    required String parentName,
    required String studentId,
    required String studentName,
  }) async {
    try {
      // 기존 채팅방 확인
      final existingChatRoomQuery =
          await _chatRooms
              .where('teacherId', isEqualTo: teacherId)
              .where('parentId', isEqualTo: parentId)
              .where('studentId', isEqualTo: studentId)
              .get();

      if (existingChatRoomQuery.docs.isNotEmpty) {
        final existingRoomId = existingChatRoomQuery.docs.first.id;

        // 비활성화된 채팅방이면 다시 활성화
        if (existingChatRoomQuery.docs.first['active'] == false) {
          await _chatRooms.doc(existingRoomId).update({'active': true});
        }

        return existingRoomId;
      }

      // 신규 채팅방 생성
      final chatRoom = ChatRoom(
        id: '',
        teacherId: teacherId,
        teacherName: teacherName,
        parentId: parentId,
        parentName: parentName,
        studentId: studentId,
        studentName: studentName,
        lastMessageTime: DateTime.now(),
        lastMessageContent: '채팅방이 생성되었습니다.',
        unreadCount: 0,
        active: true,
      );

      final docRef = await _chatRooms.add(chatRoom.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('채팅방 생성 오류: $e');
      return '';
    }
  }

  // 메시지 전송
  Future<bool> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String content,
    String? relatedStudentId,
  }) async {
    try {
      final chatRoom = await _chatRooms.doc(roomId).get();
      if (!chatRoom.exists) return false;

      final roomData = chatRoom.data() as Map<String, dynamic>;

      // 현재 읽지 않은 메시지 수 계산
      int unreadCount = roomData['unreadCount'] ?? 0;

      // 메시지 발신자에 따른 unreadCount 변경
      // 선생님이 보내는 메시지는 카운트에 포함되지 않음
      // 학부모가 보내는 메시지는 카운트 증가
      if (senderRole == 'parent') {
        unreadCount += 1;
      } else {
        // 선생님이 메시지를 보내면 읽지 않은 메시지 초기화
        unreadCount = 0;
      }

      // 메시지 저장
      final message = ChatMessage(
        id: '',
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        relatedStudentId: relatedStudentId,
      );

      await _getChatMessages(roomId).add(message.toMap());

      // 채팅방 정보 업데이트 (마지막 메시지, 시간, 읽지 않은 메시지 수)
      await _chatRooms.doc(roomId).update({
        'lastMessageContent': content,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'unreadCount': unreadCount,
      });

      return true;
    } catch (e) {
      debugPrint('메시지 전송 오류: $e');
      return false;
    }
  }

  // 메시지 읽음 상태 업데이트
  Future<void> markMessagesAsRead(String roomId, String teacherId) async {
    try {
      // 채팅방의 선생님 ID가 현재 사용자와 일치하는지 확인
      final roomDoc = await _chatRooms.doc(roomId).get();
      if (!roomDoc.exists) return;

      final roomData = roomDoc.data() as Map<String, dynamic>;
      if (roomData['teacherId'] != teacherId) return;

      // 읽지 않은 메시지 수 초기화
      await _chatRooms.doc(roomId).update({'unreadCount': 0});

      // 메시지의 읽음 상태 업데이트
      final messages =
          await _getChatMessages(roomId)
              .where('isRead', isEqualTo: false)
              .where('senderRole', isEqualTo: 'parent')
              .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('메시지 읽음 상태 업데이트 오류: $e');
    }
  }

  // 채팅방 비활성화
  Future<void> deactivateChatRoom(String roomId) async {
    try {
      await _chatRooms.doc(roomId).update({'active': false});
    } catch (e) {
      debugPrint('채팅방 비활성화 오류: $e');
    }
  }

  // 학생 ID로 관련 채팅방 가져오기
  Future<List<ChatRoom>> getChatRoomsByStudentId(String studentId) async {
    try {
      final snapshot =
          await _chatRooms
              .where('studentId', isEqualTo: studentId)
              .where('active', isEqualTo: true)
              .get();

      return snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('학생 ID로 채팅방 조회 오류: $e');
      return [];
    }
  }
}
