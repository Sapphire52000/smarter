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
      role: UserRole.student,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Firestore 문서에서 사용자 모델 생성
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final role = _parseUserRole(data['role'] ?? 'student');

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      role: role,
      academyId: data['academyId'],
      academyName: data['academyName'],
      academyAddress: data['academyAddress'],
      academyPhone: data['academyPhone'],
      additionalInfo: data['additionalInfo'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// 문자열을 UserRole enum으로 변환
  static UserRole _parseUserRole(String roleStr) {
    // 역할 문자열 소문자로 변환하여 비교 (대소문자 차이로 인한 문제 방지)
    final lowerRoleStr = roleStr.toLowerCase();

    if (lowerRoleStr == 'academy' || lowerRoleStr == 'academyowner') {
      return UserRole.academyOwner;
    } else if (lowerRoleStr == 'superadmin' || lowerRoleStr == 'admin') {
      return UserRole.superAdmin;
    } else if (lowerRoleStr == 'teacher') {
      return UserRole.teacher;
    } else if (lowerRoleStr == 'parent') {
      return UserRole.parent;
    } else if (lowerRoleStr == 'student') {
      return UserRole.student;
    } else {
      return UserRole.student;
    }
  }

  /// 문자열을 UserRole enum으로 변환
  static UserRole _parseRole(dynamic roleStr) {
    if (roleStr == null) return UserRole.student;

    if (roleStr is String) {
      switch (roleStr) {
        case 'superAdmin':
          return UserRole.superAdmin;
        case 'academyOwner':
          return UserRole.academyOwner;
        case 'teacher':
          return UserRole.teacher;
        case 'parent':
          return UserRole.parent;
        case 'student':
        default:
          return UserRole.student;
      }
    }

    return UserRole.student;
  }

  /// Firestore에 저장하기 위한 Map 변환
  Map<String, dynamic> toMap() {
    final map = {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role.toString().split('.').last,
      'academyId': academyId,
      'academyName': academyName,
      'academyAddress': academyAddress,
      'academyPhone': academyPhone,
      'additionalInfo': additionalInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
    print('Firestore에 저장할 데이터: $map');
    return map;
  }

  /// 사용자 데이터 업데이트
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
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, displayName: $displayName, role: $role)';
}
