import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewUserInfo {
  Timestamp lastOpenedAt;
  int unseenCount;
  final String userId;
  OverviewUserInfo({
    required this.userId,
    required this.lastOpenedAt,
    required this.unseenCount,
  });

  factory OverviewUserInfo.fromJson(Map<String, dynamic> json) {
    return OverviewUserInfo(
        userId: json["userId"],
        lastOpenedAt: json["lastOpenedAt"],
        unseenCount: json["unseenCount"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "lastOpenedAt": lastOpenedAt,
      "unseenCount": unseenCount,
    };
  }
}
