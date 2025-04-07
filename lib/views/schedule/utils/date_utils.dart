import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 시간표 관련 날짜 유틸리티 클래스
class ScheduleDateUtils {
  /// 두 날짜가 같은 날인지 확인 (년, 월, 일만 비교)
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 주간 헤더 텍스트 생성 (예: '3월 1일 ~ 7일')
  static String buildWeekHeaderText(DateTime date) {
    // 해당 주의 월요일 찾기
    final monday = date.subtract(Duration(days: date.weekday - 1));

    // 해당 주의 일요일 찾기
    final sunday = monday.add(const Duration(days: 6));

    // 월-일 형식으로 표시 (월이 같으면 월 표시 한 번만)
    if (monday.month == sunday.month) {
      return '${DateFormat('M월 d일', 'ko').format(monday)} ~ ${DateFormat('d일', 'ko').format(sunday)}';
    } else {
      return '${DateFormat('M월 d일', 'ko').format(monday)} ~ ${DateFormat('M월 d일', 'ko').format(sunday)}';
    }
  }

  /// 시간 포맷팅 (예: '14:30')
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// TimeOfDay 포맷팅 (예: '14:30')
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 요일별 색상 얻기 (토요일: 파랑, 일요일: 빨강, 나머지: 기본색)
  static Color getDayColor(DateTime date, Color defaultColor) {
    if (date.weekday == 6) {
      // 토요일
      return Colors.blue;
    } else if (date.weekday == 7) {
      // 일요일
      return Colors.red;
    }
    return defaultColor;
  }
}
