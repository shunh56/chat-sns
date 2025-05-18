import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final String userId;
  final Timestamp startedAt;
  final Timestamp? endedAt;
  final int? duration; // 秒単位
  final Map<String, dynamic> deviceInfo;
  final List<String> actions;
  final List<Map<String, dynamic>> screenViews;

  Session({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.duration,
    required this.deviceInfo,
    required this.actions,
    required this.screenViews,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'duration': duration,
      'deviceInfo': deviceInfo,
      'actions': actions,
      'screenViews': List<dynamic>.from(screenViews),
    };
  }

  factory Session.fromFirestore(Map<String, dynamic> data) {
    return Session(
      id: data['id'],
      userId: data['userId'] ?? '',
      startedAt: data['startedAt'],
      endedAt: data['endedAt'],
      duration: data['duration'],
      deviceInfo: Map<String, dynamic>.from(data['deviceInfo'] ?? {}),
      actions: List<String>.from(data['actions'] ?? []),
      screenViews: List<Map<String, dynamic>>.from(
          (data['screenViews'] ?? []).map((x) => Map<String, dynamic>.from(x))),
    );
  }

  Session copyWith({
    String? id,
    String? userId,
    Timestamp? startedAt,
    Timestamp? endedAt,
    int? duration,
    Map<String, dynamic>? deviceInfo,
    List<String>? actions,
    List<Map<String, dynamic>>? screenViews,
  }) {
    return Session(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      actions: actions ?? this.actions,
      screenViews: screenViews ?? this.screenViews,
    );
  }
}
