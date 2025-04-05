import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 역할 정의
enum UserRole {
  superAdmin, // 슈퍼계정
  academyOwner, // 학원장
  teacher, // 선생님
  parent, // 학부모
  student, // 학생
}

/// 사용자 모델 클래스
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final UserRole role;
  final String? academyId;
  final String? academyName;
  final String? academyAddress;
  final String? academyPhone;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.role,
    this.academyId,
    this.academyName,
    this.academyAddress,
    this.academyPhone,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 기본 사용자 생성 (첫 로그인 시)
  factory UserModel.initial({
    required String id,
    required String email,
    String? displayName,
    String? photoURL,
  }) {
    return UserModel(
      uid: id,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      role: UserRole.academyOwner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Firestore 문서에서 사용자 모델 생성
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // 역할 열거형 변환
    UserRole userRole = UserRole.student;
    final roleString = data['role'] as String?;
    if (roleString != null) {
      if (roleString == 'academyOwner') {
        userRole = UserRole.academyOwner;
      } else if (roleString == 'teacher') {
        userRole = UserRole.teacher;
      } else if (roleString == 'parent') {
        userRole = UserRole.parent;
      } else if (roleString == 'student') {
        userRole = UserRole.student;
      } else if (roleString == 'superAdmin') {
        userRole = UserRole.superAdmin;
      }
    }

    // 날짜 변환
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();

    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAt = DateTime.parse(data['createdAt'] as String);
      }
    }

    if (data['updatedAt'] != null) {
      if (data['updatedAt'] is Timestamp) {
        updatedAt = (data['updatedAt'] as Timestamp).toDate();
      } else if (data['updatedAt'] is String) {
        updatedAt = DateTime.parse(data['updatedAt'] as String);
      }
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      role: userRole,
      academyId: data['academyId'],
      academyName: data['academyName'],
      academyAddress: data['academyAddress'],
      academyPhone: data['academyPhone'],
      additionalInfo: data['additionalInfo'] as Map<String, dynamic>?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Firestore에 저장할 맵 형태로 변환
  Map<String, dynamic> toMap() {
    String roleString;
    switch (role) {
      case UserRole.academyOwner:
        roleString = 'academyOwner';
        break;
      case UserRole.teacher:
        roleString = 'teacher';
        break;
      case UserRole.parent:
        roleString = 'parent';
        break;
      case UserRole.student:
        roleString = 'student';
        break;
      case UserRole.superAdmin:
        roleString = 'superAdmin';
        break;
    }

    final map = {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': roleString,
      'academyId': academyId,
      'academyName': academyName,
      'academyAddress': academyAddress,
      'academyPhone': academyPhone,
      'additionalInfo': additionalInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };

    // Firestore에 저장할 데이터
    return map;
  }

  // 특정 필드만 업데이트하는 복사 메서드
  UserModel copyWith({
    String? displayName,
    String? photoURL,
    UserRole? role,
    String? academyId,
    String? academyName,
    String? academyAddress,
    String? academyPhone,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      academyId: academyId ?? this.academyId,
      academyName: academyName ?? this.academyName,
      academyAddress: academyAddress ?? this.academyAddress,
      academyPhone: academyPhone ?? this.academyPhone,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, displayName: $displayName, role: $role)';
}
