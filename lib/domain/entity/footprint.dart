import 'package:cloud_firestore/cloud_firestore.dart';

class Footprint {
  final String userId;       // 足あとを残したユーザーID
  final int count;           // 訪問回数
  final Timestamp updatedAt; // 最終訪問日時
  final bool isSeen;         // 既読状態（所有者が確認したかどうか）

  Footprint({
    required this.userId,
    required this.count,
    required this.updatedAt,
    this.isSeen = false,
  });

  factory Footprint.fromJson(Map<String, dynamic> json) {
    return Footprint(
      userId: json["userId"],
      count: json["count"],
      updatedAt: json["updatedAt"],
      isSeen: json["isSeen"] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "count": count,
      "updatedAt": updatedAt,
      "isSeen": isSeen,
    };
  }
  
  Footprint copyWith({
    String? userId,
    int? count,
    Timestamp? updatedAt,
    bool? isSeen,
  }) {
    return Footprint(
      userId: userId ?? this.userId,
      count: count ?? this.count,
      updatedAt: updatedAt ?? this.updatedAt,
      isSeen: isSeen ?? this.isSeen,
    );
  }
}

// 足あとのプライバシー設定
enum FootprintPrivacy {
  everyone,    // 全員に表示
  friendsOnly, // 友達のみに表示
  disabled,    // 無効（表示せず、残さない）
}

extension FootprintPrivacyExtension on FootprintPrivacy {
  String get value {
    switch (this) {
      case FootprintPrivacy.everyone:
        return 'everyone';
      case FootprintPrivacy.friendsOnly:
        return 'friendsOnly';
      case FootprintPrivacy.disabled:
        return 'disabled';
    }
  }
  
  static FootprintPrivacy fromString(String value) {
    switch (value) {
      case 'everyone':
        return FootprintPrivacy.everyone;
      case 'friendsOnly':
        return FootprintPrivacy.friendsOnly;
      case 'disabled':
        return FootprintPrivacy.disabled;
      default:
        return FootprintPrivacy.everyone;
    }
  }
}