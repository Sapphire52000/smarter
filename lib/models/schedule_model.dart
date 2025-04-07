import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// 일정 데이터 모델
class ScheduleModel {
  String id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  String colorHex;
  bool isRecurring;
  String createdBy;
  DateTime createdAt;
  List<String> participants;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.colorHex = '#4285F4', // 기본값: 구글 블루
    this.isRecurring = false,
    required this.createdBy,
    required this.createdAt,
    this.participants = const [],
  });

  // Color 객체 가져오기
  Color get color {
    return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
  }

  // 일정 지속 시간 계산 (분 단위)
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  // JSON 변환 메소드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'colorHex': colorHex,
      'isRecurring': isRecurring,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'participants': participants,
    };
  }

  // 팩토리 메소드: JSON에서 ScheduleModel 생성
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    try {
      // Timestamp 또는 DateTime 형식 처리
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        } else if (value is String) {
          return DateTime.parse(value);
        }
        // 기본값
        return DateTime.now();
      }

      return ScheduleModel(
        id:
            json['id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? '제목 없음',
        description: json['description'] as String? ?? '',
        startTime: parseDateTime(json['startTime']),
        endTime: parseDateTime(json['endTime']),
        colorHex: json['colorHex'] as String? ?? '#4285F4',
        isRecurring: json['isRecurring'] as bool? ?? false,
        createdBy: json['createdBy'] as String? ?? '',
        createdAt: parseDateTime(json['createdAt']),
        participants:
            json['participants'] != null
                ? List<String>.from(json['participants'])
                : [],
      );
    } catch (e) {
      print('ScheduleModel 파싱 중 오류: $e');
      // 예외 발생 시 기본 객체 반환
      return ScheduleModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '오류 발생',
        description: '데이터 변환 중 오류가 발생했습니다',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        createdBy: '',
        createdAt: DateTime.now(),
      );
    }
  }

  // 새 일정 생성 시 사용할 팩토리 메소드
  factory ScheduleModel.create({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String createdBy,
    String colorHex = '#4285F4',
    bool isRecurring = false,
    List<String> participants = const [],
  }) {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    return ScheduleModel(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      colorHex: colorHex,
      isRecurring: isRecurring,
      createdBy: createdBy,
      createdAt: now,
      participants: participants,
    );
  }

  // 일정 복사본 생성 (수정용)
  ScheduleModel copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? colorHex,
    bool? isRecurring,
    List<String>? participants,
  }) {
    return ScheduleModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorHex: colorHex ?? this.colorHex,
      isRecurring: isRecurring ?? this.isRecurring,
      createdBy: createdBy,
      createdAt: createdAt,
      participants: participants ?? this.participants,
    );
  }
}
