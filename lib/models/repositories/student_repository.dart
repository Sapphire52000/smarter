import 'package:cloud_firestore/cloud_firestore.dart';
import '../student_model.dart';

/// 학생 관련 데이터 처리 리포지토리
class StudentRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'students';

  StudentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 모든 학생 목록 가져오기
  Future<List<StudentModel>> getAllStudents() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList();
  }

  /// 특정 학원의 학생 목록 가져오기
  Future<List<StudentModel>> getStudentsByAcademy(String academyId) async {
    final snapshot =
        await _firestore
            .collection(_collection)
            .where('academyId', isEqualTo: academyId)
            .get();

    return snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList();
  }

  /// 학생 추가
  Future<DocumentReference> addStudent(StudentModel student) async {
    return await _firestore.collection(_collection).add(student.toMap());
  }

  /// 학생 정보 업데이트
  Future<void> updateStudent(StudentModel student) async {
    await _firestore
        .collection(_collection)
        .doc(student.id)
        .update(student.toMap());
  }

  /// 학생 삭제
  Future<void> deleteStudent(String studentId) async {
    await _firestore.collection(_collection).doc(studentId).delete();
  }

  /// 학생 상세 정보 가져오기
  Future<StudentModel?> getStudentById(String studentId) async {
    final doc = await _firestore.collection(_collection).doc(studentId).get();

    if (!doc.exists) {
      return null;
    }

    return StudentModel.fromFirestore(doc);
  }

  /// 학생을 수업에 등록
  Future<void> enrollStudentToClass(String studentId, String classId) async {
    final doc = await _firestore.collection(_collection).doc(studentId).get();

    if (!doc.exists) {
      throw Exception('학생을 찾을 수 없습니다');
    }

    final student = StudentModel.fromFirestore(doc);
    final List<String> enrolledClasses = student.enrolledClasses ?? [];

    if (!enrolledClasses.contains(classId)) {
      enrolledClasses.add(classId);
      await _firestore.collection(_collection).doc(studentId).update({
        'enrolledClasses': enrolledClasses,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// 학생을 수업에서 제외
  Future<void> unenrollStudentFromClass(
    String studentId,
    String classId,
  ) async {
    final doc = await _firestore.collection(_collection).doc(studentId).get();

    if (!doc.exists) {
      throw Exception('학생을 찾을 수 없습니다');
    }

    final student = StudentModel.fromFirestore(doc);
    final List<String> enrolledClasses = student.enrolledClasses ?? [];

    if (enrolledClasses.contains(classId)) {
      enrolledClasses.remove(classId);
      await _firestore.collection(_collection).doc(studentId).update({
        'enrolledClasses': enrolledClasses,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
