/// 사용자 역할 구분
enum UserRole {
  student, // 학생
  coach, // 코치
  admin, // 관리자
}

/// 사용자 모델 클래스
class UserModel {
  /// 사용자 고유 ID (Firebase Auth UID)
  final String? uid;

  /// 사용자 이름
  final String? name;

  /// 사용자 이메일
  final String? email;

  /// 사용자 프로필 사진 URL
  final String? photoUrl;

  /// 사용자 역할 (기본값: 학생)
  final UserRole role;

  /// 생성 시간
  final DateTime? createdAt;

  /// 마지막 로그인 시간
  final DateTime? lastLoginAt;

  /// 추가 속성 (확장성을 위한 동적 필드)
  final Map<String, dynamic>? additionalData;

  /// 모델 버전 (스키마 마이그레이션 지원용)
  final int version;

  /// 기본 생성자
  UserModel({
    this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.role = UserRole.student,
    this.createdAt,
    this.lastLoginAt,
    this.additionalData,
    this.version = 1,
  });

  /// Firebase Auth User로부터 모델 생성
  factory UserModel.fromFirebaseUser(
    dynamic user, {
    UserRole role = UserRole.student,
  }) {
    if (user == null) return UserModel();

    return UserModel(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      role: role,
      lastLoginAt: DateTime.now(),
    );
  }

  /// JSON에서 모델 생성
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photo_url'],
      role: _parseRole(json['role']),
      createdAt: _parseDateTime(json['created_at']),
      lastLoginAt: _parseDateTime(json['last_login_at']),
      additionalData: json['additional_data'],
      version: json['version'] ?? 1,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'role': role.toString().split('.').last,
      'created_at': createdAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'additional_data': additionalData,
      'version': version,
    };
  }

  /// 사용자 정보 업데이트를 위한 복사 생성자
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? additionalData,
    int? version,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      additionalData: additionalData ?? this.additionalData,
      version: version ?? this.version,
    );
  }

  /// 문자열 역할을 UserRole enum으로 파싱
  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.student;

    switch (role) {
      case 'coach':
        return UserRole.coach;
      case 'admin':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  /// ISO8601 문자열을 DateTime으로 파싱
  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    if (dateTime is DateTime) return dateTime;

    try {
      return DateTime.parse(dateTime.toString());
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, role: $role)';
  }
}
