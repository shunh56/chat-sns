import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/message_overview.dart';
import 'package:app/domain/entity/user_info.dart';
import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';

final dmDatasourceProvider = Provider(
  (ref) => DirectMessageDatasource(
    ref,
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class DirectMessageDatasource {
  final Ref _ref;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final qLimit = 20;
  DocumentSnapshot? lastDocument;
  DirectMessageDatasource(this._ref, this._auth, this._firestore);

  Future<QuerySnapshot<Map<String, dynamic>>> fetchMessages(
    String id, {
    Timestamp? lastTimestamp,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection("direct_messages")
        .doc(id)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .limit(qLimit);

    if (lastTimestamp != null) {
      query = query.startAfter([lastTimestamp]);
    }

    return await query.get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(String id) {
    return _firestore
        .collection("direct_messages")
        .doc(id)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots();
  }

  Future<String> sendMessage(
    String text,
    String otherUserId,
  ) async {
    String id = const Uuid().v4();
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
    Timestamp timestamp = Timestamp.fromDate(DateTime.now());
    Map<String, dynamic> json = _textToJson(text, timestamp, id);
    FirebaseFirestore.instance
        .collection("direct_messages")
        .doc(roomId)
        .collection("messages")
        .doc(id)
        .set(json);
    writeOverview(json, otherUserId);
    return id;
  }

  sendCurrentStatusReply(
    String text,
    String otherUserId,
    String postId,
  ) async {
    String id = const Uuid().v4();
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
    Timestamp timestamp = Timestamp.fromDate(DateTime.now());
    Map<String, dynamic> json =
        _textToCurrentStatusReplyJson(text, otherUserId, postId, timestamp, id);
    FirebaseFirestore.instance
        .collection("direct_messages")
        .doc(roomId)
        .collection("messages")
        .doc(id)
        .set(json);
    writeOverview(json, otherUserId);
  }

  writeOverview(Map<String, dynamic> json, String otherUserId) async {
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);

    final DocumentReference roomRef =
        _firestore.collection('direct_messages').doc(roomId);

    try {
      // ドキュメントの存在確認をトランザクション外で行う
      final DocumentSnapshot roomSnapshot = await roomRef.get();

      await _firestore.runTransaction((transaction) async {
        //もしドキュメントが存在しなかったら
        if (!roomSnapshot.exists ||
            (roomSnapshot.data() as Map<String, dynamic>)["id"] == null) {
          //create room
          transaction.set(roomRef, {
            "id": roomId,
            "lastMessage": json,
            "updatedAt": json['createdAt'],
            'users': {
              otherUserId: true,
              _auth.currentUser!.uid: true,
            },
            "userInfoList": [
              OverviewUserInfo(
                userId: _auth.currentUser!.uid,
                lastOpenedAt: json['createdAt'],
                unseenCount: 0,
              ).toJson()
            ]
          });
        } else {
          //update room
          List<OverviewUserInfo> userInfoList = DMOverview.fromJson(
                  roomSnapshot.data() as Map<String, dynamic>, _ref)
              .userInfoList;
          //add myInfo if no data
          if (!userInfoList
              .map((e) => e.userId)
              .contains(_auth.currentUser!.uid)) {
            userInfoList.add(
              OverviewUserInfo(
                userId: _auth.currentUser!.uid,
                lastOpenedAt: json['createdAt'],
                unseenCount: 0,
              ),
            );
          }

          //change list
          for (var info in userInfoList) {
            if (info.userId == _auth.currentUser!.uid) {
              info.lastOpenedAt = json['createdAt'];
              info.unseenCount = 0;
            } else {
              info.unseenCount = info.unseenCount + 1;
            }
          }

          //upload to document
          transaction.update(roomRef, {
            "lastMessage": json,
            "updatedAt": json['createdAt'],
            "userInfoList": userInfoList.map((e) => e.toJson()).toList(),
            'users': {
              otherUserId: true,
              _auth.currentUser!.uid: true,
            },
          });
        }
      });
    } catch (e) {
      DebugPrint("Error sending message: $e");
    }
  }

  readOverview(String otherUserId) async {
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
    Timestamp timestamp = Timestamp.now();
    final DocumentReference roomRef =
        _firestore.collection('direct_messages').doc(roomId);
    try {
      // ドキュメントの存在確認をトランザクション外で行う
      final DocumentSnapshot roomSnapshot = await roomRef.get();
      await _firestore.runTransaction((transaction) async {
        //only update when doc exists
        if (roomSnapshot.exists) {
          //update room
          List<OverviewUserInfo> userInfoList = DMOverview.fromJson(
                  roomSnapshot.data() as Map<String, dynamic>, _ref)
              .userInfoList;
          if (!userInfoList
              .map((e) => e.userId)
              .contains(_auth.currentUser!.uid)) {
            userInfoList.add(
              OverviewUserInfo(
                userId: _auth.currentUser!.uid,
                lastOpenedAt: timestamp,
                unseenCount: 0,
              ),
            );
          }
          userInfoList
              .where((element) => element.userId == _auth.currentUser!.uid)
              .first
              .lastOpenedAt = timestamp;
          userInfoList
              .where((element) => element.userId == _auth.currentUser!.uid)
              .first
              .unseenCount = 0;
          transaction.update(roomRef, {
            "userInfoList": userInfoList.map((e) => e.toJson()).toList(),
            "users.${_auth.currentUser!.uid}": true,
          });
        }

        // メッセージの追加
      });
    } catch (e) {
      DebugPrint("Error reading message: $e");
    }
  }

  Map<String, dynamic> _textToJson(String text, Timestamp ts, String id) {
    return {
      "createdAt": ts,
      "id": id,
      "text": text,
      "type": "text",
      "senderId": _auth.currentUser!.uid,
    };
  }

  Map<String, dynamic> _textToCurrentStatusReplyJson(
      String text, String userId, String postId, Timestamp ts, String id) {
    return {
      //
      "userId": userId,
      "postId": postId,
      //
      "createdAt": ts,
      "id": id,
      "text": text,
      "type": "currentStatus_reply",
      "senderId": _auth.currentUser!.uid,
    };
  }
}
