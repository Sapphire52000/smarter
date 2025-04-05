import 'package:cloud_firestore/cloud_firestore.dart';

/// 학생 모델 클래스
class StudentModel {
  final String id;
  final String name;
  final String? parentId; // 학부모 아이디
  final String? academyId; // 학원 아이디
  final int age;
  final String? grade; // 학년
  final String? contactNumber;
  final List<String>? enrolledClasses; // 등록된 수업 아이디 목록
  final Map<String, dynamic>? additionalInfo; // 추가 정보
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentModel({
    required this.id,
    required this.name,
    this.parentId,
    this.academyId,
    required this.age,
    this.grade,
    this.contactNumber,
    this.enrolledClasses,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore 문서에서 학생 모델 생성
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return StudentModel(
      id: doc.id,
      name: data['name'] ?? '',
      parentId: data['parentId'],
      academyId: data['academyId'],
      age: data['age'] ?? 0,
      grade: data['grade'],
      contactNumber: data['contactNumber'],
      enrolledClasses:
          data['enrolledClasses'] != null
              ? List<String>.from(data['enrolledClasses'])
              : null,
      additionalInfo: data['additionalInfo'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore에 저장하기 위한 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'parentId': parentId,
      'academyId': academyId,
      'age': age,
      'grade': grade,
      'contactNumber': contactNumber,
      'enrolledClasses': enrolledClasses,
      'additionalInfo': additionalInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 학생 데이터 업데이트
  StudentModel copyWith({
    String? name,
    String? parentId,
    String? academyId,
    int? age,
    String? grade,
    String? contactNumber,
    List<String>? enrolledClasses,
    Map<String, dynamic>? additionalInfo,
  }) {
    return StudentModel(
      id: id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      academyId: academyId ?? this.academyId,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      contactNumber: contactNumber ?? this.contactNumber,
      enrolledClasses: enrolledClasses ?? this.enrolledClasses,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() => 'StudentModel(id: $id, name: $name, age: $age)';
}
