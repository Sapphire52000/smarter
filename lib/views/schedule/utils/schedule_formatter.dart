import 'package:flutter/material.dart';
import '../../../models/schedule_model.dart';
import 'date_utils.dart';

/// 시간표 포맷팅 관련 유틸리티 클래스
class ScheduleFormatter {
  /// 일정 시간 범위 문자열 반환 (예: "14:00 ~ 15:30")
  static String formatTimeRange(ScheduleModel schedule) {
    return '${ScheduleDateUtils.formatTime(schedule.startTime)} ~ ${ScheduleDateUtils.formatTime(schedule.endTime)}';
  }

  /// 일정 지속 시간 문자열 반환 (예: "1시간 30분")
  static String formatDuration(ScheduleModel schedule) {
    final hours = schedule.durationInMinutes ~/ 60;
    final minutes = schedule.durationInMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours시간 $minutes분';
    } else if (hours > 0) {
      return '$hours시간';
    } else {
      return '$minutes분';
    }
  }

  /// 배경색에 따른 텍스트 색상 계산
  static Color getContrastColor(Color backgroundColor) {
    // 밝기 계산 (표준 공식 사용)
    double brightness =
        (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) /
        1000;

    // 어두운 색상은 흰색, 밝은 색상은 검은색 반환
    return brightness > 160 ? Colors.black : Colors.white;
  }
}
