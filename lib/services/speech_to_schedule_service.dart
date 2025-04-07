import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';

/// 음성 명령을 분석하여 일정 데이터로 변환하는 서비스
class SpeechToScheduleService {
  /// 음성 텍스트를 분석하여 일정 정보 추출
  ScheduleModel? processVoiceCommand({
    required String text,
    required String userId,
    required UserRole userRole,
  }) {
    // 소문자 변환 및 공백 정규화
    final normalizedText = text.toLowerCase().trim();

    // 역할별 처리
    switch (userRole) {
      case UserRole.academyOwner:
        return _processForAcademy(normalizedText, userId);
      case UserRole.teacher:
        return _processForTeacher(normalizedText, userId);
      case UserRole.parent:
        return _processForParent(normalizedText, userId);
      default:
        return null;
    }
  }

  /// 학원 관리자용 음성 명령 처리
  ScheduleModel? _processForAcademy(String text, String userId) {
    // 학원 관리자는 모든 종류의 일정 생성 가능
    return _extractScheduleInfo(text, userId);
  }

  /// 교사용 음성 명령 처리
  ScheduleModel? _processForTeacher(String text, String userId) {
    // 교사는 본인 수업 관련 일정 생성 가능
    return _extractScheduleInfo(text, userId);
  }

  /// 학부모용 음성 명령 처리
  ScheduleModel? _processForParent(String text, String userId) {
    // 학부모는 일정 조회만 가능, 추가 불가
    return null;
  }

  /// 텍스트에서 일정 정보 추출
  ScheduleModel? _extractScheduleInfo(String text, String userId) {
    // 제목 추출
    String? title = _extractTitle(text);
    if (title == null) return null;

    // 날짜 추출
    DateTime? date = _extractDate(text);
    if (date == null) return null;

    // 시간 추출
    TimeRange? timeRange = _extractTimeRange(text);
    if (timeRange == null) return null;

    // 설명 추출 (옵션)
    String description = _extractDescription(text) ?? '';

    // 색상 추출 (옵션)
    String colorHex = _extractColor(text) ?? '#4285F4';

    // 시작 및 종료 시간 설정
    final startTime = DateTime(
      date.year,
      date.month,
      date.day,
      timeRange.start.hour,
      timeRange.start.minute,
    );

    final endTime = DateTime(
      date.year,
      date.month,
      date.day,
      timeRange.end.hour,
      timeRange.end.minute,
    );

    // 새 일정 생성
    return ScheduleModel.create(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      createdBy: userId,
      colorHex: colorHex,
      participants: [userId],
    );
  }

  /// 텍스트에서 제목 추출
  String? _extractTitle(String text) {
    // 제목 관련 키워드
    final titlePatterns = [
      RegExp(r'(.*?)\s*수업'), // "수학 수업" → "수학"
      RegExp(r'(.*?)\s*일정'), // "영어 시험 일정" → "영어 시험"
      RegExp(r'(.*?)(?:\s+추가|\s+등록|\s+만들어)'), // "수학 보충 추가해줘" → "수학 보충"
    ];

    for (final pattern in titlePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    // 일반적인 경우 첫 몇 단어를 제목으로 간주
    final words = text.split(' ');
    if (words.length >= 2) {
      return words.take(2).join(' ');
    }

    return null;
  }

  /// 텍스트에서 날짜 추출
  DateTime? _extractDate(String text) {
    final now = DateTime.now();

    // "오늘" 키워드
    if (text.contains('오늘')) {
      return DateTime(now.year, now.month, now.day);
    }

    // "내일" 키워드
    if (text.contains('내일')) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    }

    // "모레" 키워드
    if (text.contains('모레')) {
      final dayAfterTomorrow = now.add(const Duration(days: 2));
      return DateTime(
        dayAfterTomorrow.year,
        dayAfterTomorrow.month,
        dayAfterTomorrow.day,
      );
    }

    // "다음주" 키워드
    if (text.contains('다음주')) {
      final nextWeek = now.add(const Duration(days: 7));
      return DateTime(nextWeek.year, nextWeek.month, nextWeek.day);
    }

    // 요일 키워드 (월요일, 화요일, ...)
    final weekdayPattern = RegExp(r'(월|화|수|목|금|토|일)요일');
    final weekdayMatch = weekdayPattern.firstMatch(text);
    if (weekdayMatch != null) {
      final weekdayStr = weekdayMatch.group(1);
      final Map<String, int> weekdayMap = {
        '월': 1,
        '화': 2,
        '수': 3,
        '목': 4,
        '금': 5,
        '토': 6,
        '일': 7,
      };

      if (weekdayStr != null && weekdayMap.containsKey(weekdayStr)) {
        final targetWeekday = weekdayMap[weekdayStr]!;
        final daysUntilTarget = (targetWeekday - now.weekday) % 7;
        final targetDate = now.add(
          Duration(days: daysUntilTarget == 0 ? 7 : daysUntilTarget),
        );
        return DateTime(targetDate.year, targetDate.month, targetDate.day);
      }
    }

    // "MM월 DD일" 형식
    final datePattern = RegExp(r'(\d+)월\s*(\d+)일');
    final dateMatch = datePattern.firstMatch(text);
    if (dateMatch != null) {
      final month = int.tryParse(dateMatch.group(1) ?? '');
      final day = int.tryParse(dateMatch.group(2) ?? '');

      if (month != null && day != null) {
        // 올해 또는 내년으로 가정
        int year = now.year;
        // 지정한 날짜가 오늘보다 이전이면 내년으로 설정
        if (month < now.month || (month == now.month && day < now.day)) {
          year++;
        }

        return DateTime(year, month, day);
      }
    }

    // 기본값은 오늘
    return DateTime(now.year, now.month, now.day);
  }

  /// 텍스트에서 시간 범위 추출
  TimeRange? _extractTimeRange(String text) {
    // "N시부터 M시까지" 패턴
    final timeRangePattern = RegExp(
      r'(\d+)시\s*(?:(\d+)분)?\s*(?:부터|에서)?\s*(\d+)시\s*(?:(\d+)분)?\s*(?:까지|동안|간)?',
    );
    final timeRangeMatch = timeRangePattern.firstMatch(text);

    if (timeRangeMatch != null) {
      final startHour = int.tryParse(timeRangeMatch.group(1) ?? '') ?? 0;
      final startMinute = int.tryParse(timeRangeMatch.group(2) ?? '0') ?? 0;
      final endHour = int.tryParse(timeRangeMatch.group(3) ?? '') ?? 0;
      final endMinute = int.tryParse(timeRangeMatch.group(4) ?? '0') ?? 0;

      return TimeRange(
        TimeOfDay(hour: startHour, minute: startMinute),
        TimeOfDay(hour: endHour, minute: endMinute),
      );
    }

    // "N시에" 패턴 (1시간 기본 지속시간)
    final timePointPattern = RegExp(r'(\d+)시\s*(?:(\d+)분)?\s*에');
    final timePointMatch = timePointPattern.firstMatch(text);

    if (timePointMatch != null) {
      final hour = int.tryParse(timePointMatch.group(1) ?? '') ?? 0;
      final minute = int.tryParse(timePointMatch.group(2) ?? '0') ?? 0;

      return TimeRange(
        TimeOfDay(hour: hour, minute: minute),
        TimeOfDay(hour: hour + 1, minute: minute),
      );
    }

    // 오전/오후 패턴
    final amPmPattern = RegExp(r'(오전|오후)\s*(\d+)시\s*(?:(\d+)분)?');
    final amPmMatch = amPmPattern.firstMatch(text);

    if (amPmMatch != null) {
      final amPm = amPmMatch.group(1);
      final hour = int.tryParse(amPmMatch.group(2) ?? '') ?? 0;
      final minute = int.tryParse(amPmMatch.group(3) ?? '0') ?? 0;

      int adjustedHour = hour;
      if (amPm == '오후' && hour < 12) {
        adjustedHour += 12;
      }

      return TimeRange(
        TimeOfDay(hour: adjustedHour, minute: minute),
        TimeOfDay(hour: adjustedHour + 1, minute: minute),
      );
    }

    // 기본값: 없음 (null 반환)
    return null;
  }

  /// 텍스트에서 설명 추출
  String? _extractDescription(String text) {
    // 설명 키워드
    final List<RegExp> descriptionPatterns = [
      RegExp(r'(?:내용|설명)\s*(?:은|는)?\s*(.*?)(?:이|라고|로)?'),
      RegExp(r'(?:메모|참고)\s*(?:는|은)?\s*(.*?)(?:이|라고|로)?'),
    ];

    for (final pattern in descriptionPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    return null;
  }

  /// 텍스트에서 색상 추출
  String? _extractColor(String text) {
    // 색상 키워드
    final Map<String, String> colorMap = {
      '빨간': '#EA4335',
      '빨강': '#EA4335',
      '레드': '#EA4335',
      '파란': '#4285F4',
      '파랑': '#4285F4',
      '블루': '#4285F4',
      '초록': '#34A853',
      '녹색': '#34A853',
      '그린': '#34A853',
      '노란': '#FBBC05',
      '노랑': '#FBBC05',
      '옐로우': '#FBBC05',
      '보라': '#A142F4',
      '퍼플': '#A142F4',
    };

    for (final entry in colorMap.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }
}

/// 시간 범위 클래스
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange(this.start, this.end);
}
