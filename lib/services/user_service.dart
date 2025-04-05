import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

/// 사용자 데이터 관리 서비스
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 사용자 컬렉션 참조
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// 사용자 ID로 사용자 정보 조회
  Future<UserModel?> getUserById(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();

      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      }

      return null;
    } catch (e) {
      print('사용자 정보 조회 오류: $e');
      rethrow;
    }
  }

  /// 신규 사용자 생성
  Future<UserModel> createUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final now = DateTime.now();

      final user = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        photoURL: photoURL,
        role: UserRole.student, // 기본 역할은 학생
        createdAt: now,
        updatedAt: now,
      );

      await _usersCollection.doc(uid).set(user.toMap());

      return user;
    } catch (e) {
      print('사용자 생성 오류: $e');
      rethrow;
    }
  }

  /// 사용자 정보 업데이트
  Future<UserModel> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toMap());
      return user;
    } catch (e) {
      print('사용자 업데이트 오류: $e');
      rethrow;
    }
  }

  /// 사용자 프로필 업데이트
  Future<UserModel> updateUserProfile({
    required String uid,
    String? displayName,
    String? academyName,
    String? academyAddress,
    String? academyPhone,
    UserRole? role,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final currentUser = await getUserById(uid);
      if (currentUser == null) {
        throw Exception('사용자를 찾을 수 없습니다');
      }

      final updatedUser = currentUser.copyWith(
        displayName: displayName,
        academyName: academyName,
        academyAddress: academyAddress,
        academyPhone: academyPhone,
        role: role,
        additionalInfo: additionalInfo,
      );

      final updateData = {...updatedUser.toMap(), 'updatedAt': Timestamp.now()};

      await _usersCollection.doc(uid).update(updateData);

      return updatedUser;
    } catch (e) {
      throw Exception('프로필 업데이트 실패: $e');
    }
  }

  /// 프로필 이미지 업로드 및 URL 업데이트
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    try {
      final storageRef = _storage.ref().child('profile_images/$uid.jpg');

      final uploadTask = await storageRef.putFile(imageFile);

      final downloadUrl = await storageRef.getDownloadURL();

      await _usersCollection.doc(uid).update({
        'photoURL': downloadUrl,
        'updatedAt': Timestamp.now(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  /// 사용자 역할 업데이트
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _usersCollection.doc(uid).update({
        'role': role.toString().split('.').last,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('역할 업데이트 실패: $e');
    }
  }
}
