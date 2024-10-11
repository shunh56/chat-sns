import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum InviteCodeStatus {
  notFound,
  overLimit,
  usedByMe,
  valid,
  unknownError,
}

class InviteCode {
  final String code;
  final Timestamp createdAt;
  final String userId;
  final List<String> slot;
  final List<Map<String, dynamic>> logs;
  final int maxCount;

  InviteCode({
    required this.code,
    required this.createdAt,
    required this.userId,
    required this.slot,
    required this.logs,
    required this.maxCount,
  });

  factory InviteCode.fromJson(Map<String, dynamic> json) {
    return InviteCode(
      code: json["id"],
      createdAt: json["createdAt"],
      userId: json["userId"],
      slot: List<String>.from(json["slot"]),
      logs: List<Map<String, dynamic>>.from(json["logs"] ?? []),
      maxCount: json["maxCount"],
    );
  }

  factory InviteCode.notFount() {
    return InviteCode(
      code: "not_found",
      createdAt: Timestamp.now(),
      userId: "",
      slot: [],
      logs: [],
      maxCount: 0,
    );
  }

  factory InviteCode.init() {
    return InviteCode(
      code: "",
      createdAt: Timestamp.now(),
      userId: "",
      slot: [],
      logs: [],
      maxCount: 0,
    );
  }
  InviteCodeStatus get getStatus {
    InviteCodeStatus temp = InviteCodeStatus.unknownError;
    final myId = FirebaseAuth.instance.currentUser!.uid;
    if (slot.length < maxCount && !slot.contains(myId)) {
      temp = InviteCodeStatus.valid;
    }
    if (slot.contains(myId)) temp = InviteCodeStatus.usedByMe;
    if (slot.length >= maxCount) temp = InviteCodeStatus.overLimit;
    if (code == "not_found") temp = InviteCodeStatus.notFound;
    return temp;
  }
}
