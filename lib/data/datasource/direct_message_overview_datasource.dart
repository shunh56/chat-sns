import 'package:app/domain/entity/message_overview.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dmOverviewDatasourceProvider = Provider(
  (ref) => DirectMessageOverviewDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class DirectMessageOverviewDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  DirectMessageOverviewDatasource(this._auth, this._firestore);

  Stream<QuerySnapshot<Map<String, dynamic>>> streamDMOverviews() {
    return _firestore
        .collection("direct_messages")
        .where("users.${_auth.currentUser!.uid}", isEqualTo: true)
        .limit(50)
        .snapshots();
  }

  Future<void> joinChat(String otherUserId) async {
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
    final DocumentReference roomRef =
        _firestore.collection('direct_messages').doc(roomId);

    // ドキュメントの存在確認
    final DocumentSnapshot roomSnapshot = await roomRef.get();

    // 初期化用のタイムスタンプ
    final Timestamp now = Timestamp.now();

    // 初期メッセージ（システムメッセージとして扱う）
    final Map<String, dynamic> initialMessage = {
      "createdAt": now,
      "text": "チャットを開始しました",
      "type": "system",
      "senderId": _auth.currentUser!.uid,
    };

    if (!roomSnapshot.exists ||
        (roomSnapshot.data() as Map<String, dynamic>?)?["id"] == null) {
      // ドキュメントが存在しない場合、完全なDMOverviewを作成
      await roomRef.set({
        "id": roomId,
        "lastMessage": initialMessage,
        "updatedAt": now,
        'users': {
          otherUserId: true,
          _auth.currentUser!.uid: true,
        },
        "userInfoList": [
          // 承認者（現在のユーザー）の情報
          {
            'userId': _auth.currentUser!.uid,
            'lastOpenedAt': now,
            'unseenCount': 0,
          },
          // リクエスト送信者（相手）の情報
          {
            'userId': otherUserId,
            'lastOpenedAt': now,
            'unseenCount': 0, // 承認時点では未読なし
          },
        ],
      });
    } else {
      // ドキュメントが既に存在する場合、users フラグと必要なフィールドを更新
      await roomRef.set({
        "users.${_auth.currentUser!.uid}": true,
        "users.$otherUserId": true,
        "lastMessage": initialMessage,
        "updatedAt": now,
      }, SetOptions(merge: true));
    }
  }

  closeChat(String otherUserId) async {
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
    final docExists =
        (await _firestore.collection("direct_messages").doc(roomId).get())
            .exists;
    if (docExists) {
      _firestore.collection("direct_messages").doc(roomId).update({
        "users.${_auth.currentUser!.uid}": false,
        "users.$otherUserId": false,
      });
    }
  }

  leaveChat(String otherUserId) async {
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
    final docExists =
        (await _firestore.collection("direct_messages").doc(roomId).get())
            .exists;
    if (docExists) {
      _firestore.collection("direct_messages").doc(roomId).update({
        "users.${_auth.currentUser!.uid}": false,
      });
    }
  }
}
