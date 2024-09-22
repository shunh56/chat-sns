import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  final Timestamp? lastOpenedAt;
  final int unseenCount;

  UserInfo({
    required this.lastOpenedAt,
    required this.unseenCount,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      lastOpenedAt: json["lastOpenedAt"],
      unseenCount: json["unseenCount"],
    );
  }
}
