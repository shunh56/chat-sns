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
  final String id;
  final Timestamp createdAt;
  final String userId;
  final List<Map<String, dynamic>> logs;
  final String? usedCode; // 自分が使用した招待コードのID

  InviteCode({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.logs,
    this.usedCode,
  });

  factory InviteCode.fromJson(Map<String, dynamic> json) {
    return InviteCode(
      id: json["id"],
      createdAt: json["createdAt"],
      userId: json["userId"],
      logs: List<Map<String, dynamic>>.from(json["logs"] ?? []),
      usedCode: json["usedCode"],
    );
  }

  factory InviteCode.notFount() {
    return InviteCode(
      id: "not_found",
      createdAt: Timestamp.now(),
      userId: "",
      logs: [],
    );
  }

  factory InviteCode.init() {
    return InviteCode(
      id: "",
      createdAt: Timestamp.now(),
      userId: "",
      logs: [],
    );
  }

  InviteCodeStatus get getStatus {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    if (id == "not_found") return InviteCodeStatus.notFound;
    if (userId == myId) return InviteCodeStatus.usedByMe;
    return InviteCodeStatus.valid;
  }
}
