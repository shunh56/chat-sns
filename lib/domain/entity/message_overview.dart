import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/user_info.dart';
import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//direct_messages/{id}をstreamする

class MessageOverview {
  final Message lastMessage;
  final Timestamp updatedAt;
  final List<OverviewUserInfo> userInfoList;

  MessageOverview({
    required this.lastMessage,
    required this.updatedAt,
    required this.userInfoList,
  });

  factory MessageOverview.fromJson(Map<String, dynamic> json) {
    return MessageOverview(
      lastMessage:
          Message.fromJson(Map<String, dynamic>.from(json["lastMessage"])),
      updatedAt: json["updatedAt"],
      userInfoList: List<OverviewUserInfo>.from(
        List<Map<String, dynamic>>.from(
          json['userInfoList'] ?? [],
        ).map((e) => OverviewUserInfo.fromJson(e)).toList(),
      ),
    );
  }
}

class DMOverview extends MessageOverview {
  final String userId;
  DMOverview({
    required this.userId,
    required super.lastMessage,
    required super.updatedAt,
    required super.userInfoList,
  });

  factory DMOverview.fromJson(Map<String, dynamic> json, Ref ref) {
    return DMOverview(
      userId: DMKeyConverter.getUserIdFromKey(
          json["id"], ref.watch(authProvider).currentUser!.uid),
      lastMessage:
          Message.fromJson(Map<String, dynamic>.from(json["lastMessage"])),
      updatedAt: json["updatedAt"],
      userInfoList: List<OverviewUserInfo>.from(
        List<Map<String, dynamic>>.from(
          json['userInfoList'] ?? [],
        ).map((e) => OverviewUserInfo.fromJson(e)).toList(),
      ),
    );
  }

  bool get isNotSeen {
    final q = userInfoList
        .where((item) => item.userId == FirebaseAuth.instance.currentUser!.uid);
    bool unseenCheck = false;
    if (q.isNotEmpty) {
      final myInfo = q.first;
      if (myInfo.lastOpenedAt.compareTo(updatedAt) < 0) {
        unseenCheck = true;
      }
    } else {
      unseenCheck = true;
    }
    return unseenCheck;
  }
}

class DMKeyConverter {
  static String getKey(String myId, String userId2) {
    if (myId.compareTo(userId2) < 0) {
      return '${myId}_$userId2';
    } else {
      return '${userId2}_$myId';
    }
  }

  static String getUserIdFromKey(String key, String myId) {
    List<String> userIds = key.split('_');
    if (userIds[0] == myId) {
      return userIds[1];
    } else if (userIds[1] == myId) {
      return userIds[0];
    } else {
      if (userIds[0] == myId) {
        return "${userIds[1]}_${userIds[2]}";
      } else if (userIds[2] == myId) {
        return "${userIds[0]}_${userIds[1]}";
      } else {
        throw Exception('Current user ID not found in chat room ID');
      }
    }
  }
}
