import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:app/domain/entity/chat_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final chatRequestDatasourceProvider = Provider(
  (ref) => ChatRequestDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class ChatRequestDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ChatRequestDatasource(this._auth, this._firestore);

  /// 受信したチャットリクエスト一覧をストリーム
  Stream<QuerySnapshot<Map<String, dynamic>>> streamReceivedRequests() {
    return _firestore
        .collection('chat_requests')
        .where('toUserId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// 送信したチャットリクエスト一覧をストリーム
  Stream<QuerySnapshot<Map<String, dynamic>>> streamSentRequests() {
    return _firestore
        .collection('chat_requests')
        .where('fromUserId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// 特定のユーザーとの間に既存のpendingリクエストがあるかチェック
  Future<ChatRequest?> checkExistingRequest(String otherUserId) async {
    // 自分が送ったリクエスト
    final sentQuery = await _firestore
        .collection('chat_requests')
        .where('fromUserId', isEqualTo: _auth.currentUser!.uid)
        .where('toUserId', isEqualTo: otherUserId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (sentQuery.docs.isNotEmpty) {
      return ChatRequest.fromJson(sentQuery.docs.first.data());
    }

    // 相手から受け取ったリクエスト
    final receivedQuery = await _firestore
        .collection('chat_requests')
        .where('fromUserId', isEqualTo: otherUserId)
        .where('toUserId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (receivedQuery.docs.isNotEmpty) {
      return ChatRequest.fromJson(receivedQuery.docs.first.data());
    }

    return null;
  }

  /// チャットリクエストを送信
  Future<void> sendRequest({
    required String toUserId,
    String? message,
  }) async {
    final requestId = const Uuid().v4();
    final request = ChatRequest(
      id: requestId,
      fromUserId: _auth.currentUser!.uid,
      toUserId: toUserId,
      createdAt: Timestamp.now(),
      status: ChatRequestStatus.pending,
      message: message,
    );

    await _firestore
        .collection('chat_requests')
        .doc(requestId)
        .set(request.toJson());
  }

  /// チャットリクエストを承認
  Future<void> acceptRequest(String requestId) async {
    await _firestore.collection('chat_requests').doc(requestId).update({
      'status': ChatRequestStatus.accepted.value,
    });
  }

  /// チャットリクエストを却下（削除）
  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('chat_requests').doc(requestId).delete();
  }

  /// チャットリクエストを取得
  Future<ChatRequest?> getRequest(String requestId) async {
    final doc =
        await _firestore.collection('chat_requests').doc(requestId).get();

    if (!doc.exists) {
      return null;
    }

    return ChatRequest.fromJson(doc.data()!);
  }

  /// リクエストをキャンセル（自分が送ったリクエストを削除）
  Future<void> cancelRequest(String requestId) async {
    await _firestore.collection('chat_requests').doc(requestId).delete();
  }
}
