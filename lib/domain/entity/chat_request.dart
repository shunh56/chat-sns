import 'package:cloud_firestore/cloud_firestore.dart';

/// チャットリクエストのステータス
enum ChatRequestStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected');

  const ChatRequestStatus(this.value);
  final String value;

  static ChatRequestStatus fromString(String value) {
    return ChatRequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ChatRequestStatus.pending,
    );
  }
}

/// チャットリクエストエンティティ
class ChatRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final Timestamp createdAt;
  final ChatRequestStatus status;
  final String? message;

  ChatRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    required this.status,
    this.message,
  });

  factory ChatRequest.fromJson(Map<String, dynamic> json) {
    return ChatRequest(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      createdAt: json['createdAt'] as Timestamp,
      status: ChatRequestStatus.fromString(json['status'] as String),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'createdAt': createdAt,
      'status': status.value,
      if (message != null) 'message': message,
    };
  }

  /// リクエストがpending状態かどうか
  bool get isPending => status == ChatRequestStatus.pending;

  /// リクエストが承認済みかどうか
  bool get isAccepted => status == ChatRequestStatus.accepted;

  /// リクエストが却下済みかどうか
  bool get isRejected => status == ChatRequestStatus.rejected;

  ChatRequest copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    Timestamp? createdAt,
    ChatRequestStatus? status,
    String? message,
  }) {
    return ChatRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
