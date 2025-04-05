import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

/// 학생 데이터 관리 서비스
class StudentService {
  final CollectionReference _studentsCollection = FirebaseFirestore.instance
      .collection('students');

  /// 학생 목록 조회
  Stream<List<StudentModel>> getStudents({String? academyId}) {
    Query query = _studentsCollection;

    // 학원 ID가 있는 경우 필터링
    if (academyId != null) {
      query = query.where('academyId', isEqualTo: academyId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 학생 ID로 학생 정보 조회
  Future<StudentModel?> getStudentById(String id) async {
    try {
      final docSnapshot = await _studentsCollection.doc(id).get();

      if (docSnapshot.exists) {
        return StudentModel.fromFirestore(docSnapshot);
      }

      return null;
    } catch (e) {
      print('학생 정보 조회 오류: $e');
      rethrow;
    }
  }

  /// 학부모 ID로 학생 목록 조회
  Stream<List<StudentModel>> getStudentsByParentId(String parentId) {
    return _studentsCollection
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => StudentModel.fromFirestore(doc))
              .toList();
        });
  }

  /// 신규 학생 생성
  Future<StudentModel> createStudent({
    required String name,
    required int age,
    String? parentId,
    String? academyId,
    String? grade,
    String? contactNumber,
    List<String>? enrolledClasses,
  }) async {
    try {
      final newStudent = {
        'name': name,
        'age': age,
        'parentId': parentId,
        'academyId': academyId,
        'grade': grade,
        'contactNumber': contactNumber,
        'enrolledClasses': enrolledClasses,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final docRef = await _studentsCollection.add(newStudent);
      final docSnapshot = await docRef.get();

      return StudentModel.fromFirestore(docSnapshot);
    } catch (e) {
      print('학생 생성 오류: $e');
      rethrow;
    }
  }

  /// 학생 정보 업데이트
  Future<StudentModel> updateStudent(StudentModel student) async {
    try {
      await _studentsCollection.doc(student.id).update(student.toMap());

      final docSnapshot = await _studentsCollection.doc(student.id).get();
      return StudentModel.fromFirestore(docSnapshot);
    } catch (e) {
      print('학생 업데이트 오류: $e');
      rethrow;
    }
  }

  /// 수업에 학생 등록
  Future<void> enrollStudentInClass({
    required String studentId,
    required String classId,
  }) async {
    try {
      final docSnapshot = await _studentsCollection.doc(studentId).get();

      if (!docSnapshot.exists) {
        throw Exception('학생을 찾을 수 없습니다');
      }

      final studentData = docSnapshot.data() as Map<String, dynamic>;
      List<String> enrolledClasses = [];

      if (studentData['enrolledClasses'] != null) {
        enrolledClasses = List<String>.from(studentData['enrolledClasses']);
      }

      // 이미 등록되어 있는지 확인
      if (!enrolledClasses.contains(classId)) {
        enrolledClasses.add(classId);

        await _studentsCollection.doc(studentId).update({
          'enrolledClasses': enrolledClasses,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      print('학생 수업 등록 오류: $e');
      rethrow;
    }
  }

  /// 학생 삭제
  Future<void> deleteStudent(String id) async {
    try {
      await _studentsCollection.doc(id).delete();
    } catch (e) {
      print('학생 삭제 오류: $e');
      rethrow;
    }
  }
}
