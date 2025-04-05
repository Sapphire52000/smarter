import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';

/// 수업 데이터 관리 서비스
class ClassService {
  final CollectionReference _classesCollection = FirebaseFirestore.instance
      .collection('classes');

  /// 수업 목록 조회
  Stream<List<ClassModel>> getClasses({String? academyId, String? teacherId}) {
    Query query = _classesCollection;

    // 학원 ID가 있는 경우 필터링
    if (academyId != null) {
      query = query.where('academyId', isEqualTo: academyId);
    }

    // 선생님 ID가 있는 경우 필터링
    if (teacherId != null) {
      query = query.where('teacherId', isEqualTo: teacherId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
    });
  }

  /// 수업 ID로 수업 정보 조회
  Future<ClassModel?> getClassById(String id) async {
    try {
      final docSnapshot = await _classesCollection.doc(id).get();

      if (docSnapshot.exists) {
        return ClassModel.fromFirestore(docSnapshot);
      }

      return null;
    } catch (e) {
      print('수업 정보 조회 오류: $e');
      rethrow;
    }
  }

  /// 학생 ID로 등록된 수업 목록 조회
  Stream<List<ClassModel>> getClassesByStudentId(String studentId) {
    return _classesCollection
        .where('enrolledStudentIds', arrayContains: studentId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ClassModel.fromFirestore(doc))
              .toList();
        });
  }

  /// 신규 수업 생성
  Future<ClassModel> createClass({
    required String name,
    String? academyId,
    String? teacherId,
    String? subject,
    String? description,
    required int maxStudents,
    List<String>? enrolledStudentIds,
    required int sessionsPerMonth,
    Map<DayOfWeek, TimeOfDay>? schedule,
    required DateTime startDate,
    DateTime? endDate,
    ClassStatus status = ClassStatus.active,
  }) async {
    try {
      // 요일별 시간 맵 변환
      Map<String, String>? scheduleMap;
      if (schedule != null) {
        scheduleMap = {};
        schedule.forEach((day, time) {
          final dayStr = day.toString().split('.').last;
          final timeStr =
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
          scheduleMap![dayStr] = timeStr;
        });
      }

      final newClass = {
        'name': name,
        'academyId': academyId,
        'teacherId': teacherId,
        'subject': subject,
        'description': description,
        'maxStudents': maxStudents,
        'enrolledStudentIds': enrolledStudentIds ?? [],
        'sessionsPerMonth': sessionsPerMonth,
        'schedule': scheduleMap,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'status': status.toString().split('.').last,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final docRef = await _classesCollection.add(newClass);
      final docSnapshot = await docRef.get();

      return ClassModel.fromFirestore(docSnapshot);
    } catch (e) {
      print('수업 생성 오류: $e');
      rethrow;
    }
  }

  /// 수업 정보 업데이트
  Future<ClassModel> updateClass(ClassModel classModel) async {
    try {
      await _classesCollection.doc(classModel.id).update(classModel.toMap());

      final docSnapshot = await _classesCollection.doc(classModel.id).get();
      return ClassModel.fromFirestore(docSnapshot);
    } catch (e) {
      print('수업 업데이트 오류: $e');
      rethrow;
    }
  }

  /// 수업에 학생 등록
  Future<void> enrollStudentInClass({
    required String classId,
    required String studentId,
  }) async {
    try {
      final docSnapshot = await _classesCollection.doc(classId).get();

      if (!docSnapshot.exists) {
        throw Exception('수업을 찾을 수 없습니다');
      }

      final classData = docSnapshot.data() as Map<String, dynamic>;
      List<String> enrolledStudents = [];

      if (classData['enrolledStudentIds'] != null) {
        enrolledStudents = List<String>.from(classData['enrolledStudentIds']);
      }

      // 이미 등록되어 있는지 확인
      if (!enrolledStudents.contains(studentId)) {
        enrolledStudents.add(studentId);

        await _classesCollection.doc(classId).update({
          'enrolledStudentIds': enrolledStudents,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      print('학생 등록 오류: $e');
      rethrow;
    }
  }

  /// 수업에서 학생 제거
  Future<void> removeStudentFromClass({
    required String classId,
    required String studentId,
  }) async {
    try {
      final docSnapshot = await _classesCollection.doc(classId).get();

      if (!docSnapshot.exists) {
        throw Exception('수업을 찾을 수 없습니다');
      }

      final classData = docSnapshot.data() as Map<String, dynamic>;
      List<String> enrolledStudents = [];

      if (classData['enrolledStudentIds'] != null) {
        enrolledStudents = List<String>.from(classData['enrolledStudentIds']);
      }

      // 이미 등록되어 있는지 확인
      if (enrolledStudents.contains(studentId)) {
        enrolledStudents.remove(studentId);

        await _classesCollection.doc(classId).update({
          'enrolledStudentIds': enrolledStudents,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      print('학생 제거 오류: $e');
      rethrow;
    }
  }

  /// 수업 삭제
  Future<void> deleteClass(String id) async {
    try {
      await _classesCollection.doc(id).delete();
    } catch (e) {
      print('수업 삭제 오류: $e');
      rethrow;
    }
  }
}
