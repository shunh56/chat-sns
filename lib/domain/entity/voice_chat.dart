import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceChatUserInfo {
  final int uid;
  final bool isMuted;
  VoiceChatUserInfo({required this.uid, required this.isMuted});

  factory VoiceChatUserInfo.fromJson(Map<String, dynamic> json) {
    return VoiceChatUserInfo(
      uid: json["agoraUid"],
      isMuted: json["isMuted"] ?? false,
    );
  }
}

class VoiceChat {
  final String id;
  final Timestamp createdAt;
  final Timestamp endAt;
  final String title;
  final List<String> joinedUsers;
  final List<String> adminUsers;
  final Map<String, VoiceChatUserInfo> userInfo;
  final int maxCount;

  VoiceChat({
    required this.id,
    required this.createdAt,
    required this.endAt,
    required this.title,
    required this.joinedUsers,
    required this.adminUsers,
    required this.userInfo,
    required this.maxCount,
  });

  factory VoiceChat.fromJson(Map<String, dynamic> json) {
    return VoiceChat(
      id: json["id"],
      createdAt: json["createdAt"],
      endAt: json["endAt"],
      title: json["title"],
      joinedUsers: List<String>.from(json["joinedUsers"]),
      adminUsers: List<String>.from(json["adminUsers"]),
      userInfo: Map<String, dynamic>.from(json["userMap"]).map(
        (key, val) => MapEntry(
          key,
          VoiceChatUserInfo.fromJson(val),
        ),
      ),
      maxCount: json["maxCount"],
    );
  }
}
