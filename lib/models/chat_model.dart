import 'package:cloud_firestore/cloud_firestore.dart';

/// 채팅 메시지 모델
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'teacher' or 'parent'
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedStudentId; // 관련된 학생 ID (학부모 채팅인 경우)

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.relatedStudentId,
  });

  // Firebase에서 데이터 읽어오기
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      relatedStudentId: data['relatedStudentId'],
    );
  }

  // Firebase에 저장할 데이터 맵 생성
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'relatedStudentId': relatedStudentId,
    };
  }

  // 읽음 상태 업데이트된 새 객체 생성
  ChatMessage copyWithReadStatus({required bool isRead}) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      content: content,
      timestamp: timestamp,
      isRead: isRead,
      relatedStudentId: relatedStudentId,
    );
  }
}

/// 채팅방 모델
class ChatRoom {
  final String id;
  final String teacherId;
  final String teacherName;
  final String parentId;
  final String parentName;
  final String studentId;
  final String studentName;
  final DateTime lastMessageTime;
  final String lastMessageContent;
  final int unreadCount; // 선생님 기준으로 읽지 않은 메시지 수
  final bool active; // 활성화 상태

  ChatRoom({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.parentId,
    required this.parentName,
    required this.studentId,
    required this.studentName,
    required this.lastMessageTime,
    required this.lastMessageContent,
    this.unreadCount = 0,
    this.active = true,
  });

  // Firebase에서 데이터 읽어오기
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatRoom(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      parentId: data['parentId'] ?? '',
      parentName: data['parentName'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      lastMessageTime:
          data['lastMessageTime'] != null
              ? (data['lastMessageTime'] as Timestamp).toDate()
              : DateTime.now(),
      lastMessageContent: data['lastMessageContent'] ?? '',
      unreadCount: data['unreadCount'] ?? 0,
      active: data['active'] ?? true,
    );
  }

  // Firebase에 저장할 데이터 맵 생성
  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'parentId': parentId,
      'parentName': parentName,
      'studentId': studentId,
      'studentName': studentName,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageContent': lastMessageContent,
      'unreadCount': unreadCount,
      'active': active,
    };
  }

  // 마지막 메시지 및 읽지 않은 메시지 수 업데이트
  ChatRoom copyWithUpdatedLastMessage({
    required String content,
    required DateTime time,
    required int newUnreadCount,
  }) {
    return ChatRoom(
      id: id,
      teacherId: teacherId,
      teacherName: teacherName,
      parentId: parentId,
      parentName: parentName,
      studentId: studentId,
      studentName: studentName,
      lastMessageTime: time,
      lastMessageContent: content,
      unreadCount: newUnreadCount,
      active: active,
    );
  }
}
