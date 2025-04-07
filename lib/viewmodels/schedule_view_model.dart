import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/schedule_model.dart';
import '../models/user_model.dart';
import '../services/speech_to_schedule_service.dart';
import 'auth_view_model.dart';

/// 시간표 관리를 위한 ViewModel
class ScheduleViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SpeechToScheduleService _speechService = SpeechToScheduleService();

  List<ScheduleModel> _schedules = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;
  AuthViewModel? _authViewModel;
  StreamSubscription? _schedulesSubscription;

  // 주간 뷰 관련 상태
  ViewType _currentViewType = ViewType.day; // 기본값은 일간 뷰
  List<DateTime> _weekDates = [];

  // 상태 getter
  List<ScheduleModel> get schedules => _schedules;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTeacher => _authViewModel?.user?.role == UserRole.teacher;
  bool get isAcademyOwner =>
      _authViewModel?.user?.role == UserRole.academyOwner;
  String get userId => _authViewModel?.user?.uid ?? '';
  UserRole? get userRole => _authViewModel?.user?.role;

  // 주간 뷰 getter
  ViewType get currentViewType => _currentViewType;
  List<DateTime> get weekDates => _weekDates;

  // 초기화
  Future<void> initialize({AuthViewModel? authViewModel}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (authViewModel != null) {
        _authViewModel = authViewModel;
      }

      if (_authViewModel?.user == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 스트림 구독 취소
      await _schedulesSubscription?.cancel();

      // 주간 날짜 계산 - 먼저 수행
      _updateWeekDates();

      // Firestore 스트림 구독
      _schedulesSubscription = _getSchedulesStream().listen(
        (schedulesList) {
          _schedules = schedulesList;

          // 일정이 없는 경우 더미 데이터 확인
          if (_schedules.isEmpty && (isTeacher || isAcademyOwner)) {
            _checkAndCreateDummyData();
          }

          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          // 인덱스 오류 확인 및 처리
          if (_handleIndexError(error)) {
            // 이미 처리됨
            return;
          }

          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      // 인덱스 오류 확인 및 처리
      if (_handleIndexError(e)) {
        // 이미 처리됨
        return;
      }

      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ViewModel 정리 작업
  @override
  void dispose() {
    _schedulesSubscription?.cancel();
    super.dispose();
  }

  // 뷰 타입 변경 (일간/주간)
  void setViewType(ViewType viewType) {
    _currentViewType = viewType;
    notifyListeners();
  }

  // 주간 날짜 업데이트
  void _updateWeekDates() {
    // 선택한 날짜가 속한 주의 월요일 찾기
    final monday = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    _weekDates = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  // 날짜 변경
  void changeDate(DateTime date) {
    _selectedDate = date;
    _updateWeekDates();
    notifyListeners();
  }

  // 이전 날짜로 이동
  void previousDay() {
    // 주간 뷰에서는 일주일 이동
    _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    _updateWeekDates();
    notifyListeners();
  }

  // 다음 날짜로 이동
  void nextDay() {
    // 주간 뷰에서는 일주일 이동
    _selectedDate = _selectedDate.add(const Duration(days: 7));
    _updateWeekDates();
    notifyListeners();
  }

  // 오늘 날짜로 이동
  void goToToday() {
    _selectedDate = DateTime.now();
    _updateWeekDates();
    notifyListeners();
  }

  // 특정 날짜의 일정만 가져오기
  List<ScheduleModel> getSchedulesForDate(DateTime date) {
    return _schedules
        .where(
          (schedule) =>
              schedule.startTime.year == date.year &&
              schedule.startTime.month == date.month &&
              schedule.startTime.day == date.day,
        )
        .toList();
  }

  // 특정 날짜 범위의 일정 가져오기 (주간 뷰용)
  List<ScheduleModel> getSchedulesForDateRange(List<DateTime> dates) {
    final startDate = dates.first;
    final endDate = dates.last.add(const Duration(days: 1)); // 마지막 날짜 포함

    return _schedules.where((schedule) {
      return schedule.startTime.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          schedule.startTime.isBefore(endDate);
    }).toList();
  }

  // 시간대별 일정 필터링
  List<ScheduleModel> getSchedulesForTimeSlot(TimeOfDay timeSlot) {
    final date = _selectedDate;
    final startOfSlot = DateTime(
      date.year,
      date.month,
      date.day,
      timeSlot.hour,
      0,
    );
    final endOfSlot = DateTime(
      date.year,
      date.month,
      date.day,
      timeSlot.hour,
      59,
    );

    return _schedules.where((schedule) {
      // 이 시간대에 시작하거나, 이 시간대에 진행 중이거나, 이 시간대에 끝나는 일정
      return (schedule.startTime.isAfter(startOfSlot) &&
              schedule.startTime.isBefore(endOfSlot)) ||
          (schedule.endTime.isAfter(startOfSlot) &&
              schedule.endTime.isBefore(endOfSlot)) ||
          (schedule.startTime.isBefore(startOfSlot) &&
              schedule.endTime.isAfter(endOfSlot));
    }).toList();
  }

  // Firestore 스트림 취득
  Stream<List<ScheduleModel>> _getSchedulesStream() {
    // 역할에 따라 다른 쿼리 사용
    Query query;

    // 선생님이나 학원장은 더 많은 일정을 볼 수 있음
    if (isTeacher || isAcademyOwner) {
      // 교사는 모든 일정 또는 담당 일정 볼 수 있음
      query = _firestore
          .collection('schedules')
          .where('participants', arrayContains: userId);
    } else {
      // 학부모는 본인과 관련된 일정만 확인 가능
      query = _firestore
          .collection('schedules')
          .where('participants', arrayContains: userId);
    }

    return query.snapshots().map((snapshot) {
      final scheduleList =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Firestore 문서 ID 추가
            return ScheduleModel.fromJson(data);
          }).toList();

      // 메모리에서 정렬 (Firestore 인덱스 문제 해결을 위해)
      scheduleList.sort((a, b) => a.startTime.compareTo(b.startTime));
      return scheduleList;
    });
  }

  // 일정 추가
  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('schedules')
          .doc(schedule.id)
          .set(schedule.toJson());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '일정 추가 실패: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 일정 수정
  Future<void> updateSchedule(ScheduleModel schedule) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('schedules')
          .doc(schedule.id)
          .update(schedule.toJson());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '일정 수정 실패: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 일정 삭제
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('schedules').doc(scheduleId).delete();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '일정 삭제 실패: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 오류 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 더미 데이터 확인 및 생성
  Future<void> _checkAndCreateDummyData() async {
    try {
      // 컬렉션 크기 확인
      final snapshot = await _firestore.collection('schedules').limit(1).get();

      // 데이터가 있으면 중단
      if (snapshot.docs.isNotEmpty) return;

      // 로그인한 사용자 정보
      final user = _authViewModel?.user;
      if (user == null) return;

      // 더미 데이터 생성
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 12, 0);

      // 오늘 일정 3개 생성
      final schedules = [
        ScheduleModel.create(
          title: '수학 기초반',
          description: '중학교 1학년 수학 기초 수업입니다.',
          startTime: DateTime(today.year, today.month, today.day, 14, 0),
          endTime: DateTime(today.year, today.month, today.day, 15, 30),
          createdBy: user.uid,
          colorHex: '#4285F4', // 파란색
          participants: [user.uid],
        ),
        ScheduleModel.create(
          title: '영어 중급반',
          description: '중학교 2학년 영어 중급 수업입니다.',
          startTime: DateTime(today.year, today.month, today.day, 16, 0),
          endTime: DateTime(today.year, today.month, today.day, 17, 30),
          createdBy: user.uid,
          colorHex: '#34A853', // 녹색
          participants: [user.uid],
        ),
        ScheduleModel.create(
          title: '과학 실험반',
          description: '초등학교 6학년 과학 실험 수업입니다.',
          startTime: DateTime(today.year, today.month, today.day, 18, 0),
          endTime: DateTime(today.year, today.month, today.day, 19, 30),
          createdBy: user.uid,
          colorHex: '#FBBC05', // 노란색
          participants: [user.uid],
        ),
      ];

      // 내일 일정 2개 생성
      final tomorrow = today.add(const Duration(days: 1));
      schedules.addAll([
        ScheduleModel.create(
          title: '국어 고급반',
          description: '고등학교 1학년 국어 고급 수업입니다.',
          startTime: DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            15,
            0,
          ),
          endTime: DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            16,
            30,
          ),
          createdBy: user.uid,
          colorHex: '#A142F4', // 보라색
          participants: [user.uid],
        ),
        ScheduleModel.create(
          title: '코딩 기초반',
          description: '중학교 코딩 기초 수업입니다.',
          startTime: DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            17,
            0,
          ),
          endTime: DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            18,
            30,
          ),
          createdBy: user.uid,
          colorHex: '#EA4335', // 빨간색
          participants: [user.uid],
        ),
      ]);

      // Firestore에 저장
      for (final schedule in schedules) {
        await _firestore
            .collection('schedules')
            .doc(schedule.id)
            .set(schedule.toJson());
      }
    } catch (e) {
      // 오류 무시 (더미 데이터 생성 실패해도 앱 동작에 영향 없음)
      print('더미 데이터 생성 중 오류: $e');
    }
  }

  // Firebase 인덱스 오류 처리
  bool _handleIndexError(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('cloud_firestore/failed-precondition') &&
        errorStr.contains('requires an index')) {
      // 인덱스 오류 발생, 대체 메서드 실행
      _loadSchedulesWithoutIndex();
      return true;
    }
    return false;
  }

  // 인덱스 없이 일정 불러오기 (대체 방법)
  Future<void> _loadSchedulesWithoutIndex() async {
    try {
      // 더 간단한 쿼리로 데이터 로드
      final snapshot = await _firestore.collection('schedules').get();

      final scheduleList =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ScheduleModel.fromJson(data);
          }).toList();

      // 필터링 (현재 사용자와 관련된 일정만)
      final filteredList =
          scheduleList.where((schedule) {
            return schedule.participants.contains(userId);
          }).toList();

      // 정렬
      filteredList.sort((a, b) => a.startTime.compareTo(b.startTime));

      // 데이터 업데이트
      _schedules = filteredList;
      _isLoading = false;
      notifyListeners();

      // 데이터가 없으면 더미 데이터 생성
      if (_schedules.isEmpty && (isTeacher || isAcademyOwner)) {
        _checkAndCreateDummyData();
      }
    } catch (e) {
      _error = '일정을 로드하는 중 오류가 발생했습니다: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 음성 명령을 처리하여 일정 생성
  Future<ScheduleModel?> processVoiceCommand(String text) async {
    if (_authViewModel?.user == null || userRole == null) {
      _error = '로그인이 필요합니다';
      notifyListeners();
      return null;
    }

    // 음성 명령 처리
    final schedule = _speechService.processVoiceCommand(
      text: text,
      userId: userId,
      userRole: userRole!,
    );

    if (schedule != null) {
      // 일정 추가
      await addSchedule(schedule);
    }

    return schedule;
  }

  /// 채팅 메시지에서 일정 정보 추출
  Future<ScheduleModel?> processScheduleFromChat(String chatMessage) async {
    if (_authViewModel?.user == null || userRole == null) {
      _error = '로그인이 필요합니다';
      notifyListeners();
      return null;
    }

    // 채팅 메시지를 음성 명령과 동일하게 처리
    return processVoiceCommand(chatMessage);
  }

  // 편의 메소드: 일정 추가 간편 버전
  Future<void> createSchedule({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String colorHex = '#4285F4',
    bool isRecurring = false,
  }) async {
    // 로그인한 사용자 정보 확인
    final user = _authViewModel?.user;
    if (user == null) {
      _error = '사용자 정보를 가져올 수 없습니다. 다시 로그인해주세요.';
      notifyListeners();
      return;
    }

    // ScheduleModel 생성
    final schedule = ScheduleModel.create(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      createdBy: user.uid,
      colorHex: colorHex,
      isRecurring: isRecurring,
      participants: [user.uid],
    );

    // 기존 메서드 호출
    await addSchedule(schedule);
  }

  // 편의 메소드: 일정 수정 간편 버전
  Future<void> editSchedule({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String? colorHex,
    bool? isRecurring,
  }) async {
    // 해당 ID의 기존 일정 찾기
    final existingSchedule = _schedules.firstWhere(
      (schedule) => schedule.id == id,
      orElse: () => throw Exception('해당 ID의 일정을 찾을 수 없습니다: $id'),
    );

    // 수정된 ScheduleModel 생성
    final updatedSchedule = existingSchedule.copyWith(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      colorHex: colorHex,
      isRecurring: isRecurring,
    );

    // 기존 메서드 호출
    await updateSchedule(updatedSchedule);
  }
}

// 뷰 타입 열거형
enum ViewType {
  day, // 일간 보기
  week, // 주간 보기
}
