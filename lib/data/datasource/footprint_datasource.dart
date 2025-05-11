import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final footprintDatasourceProvider = Provider(
  (ref) => FootprintDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class FootprintDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  FootprintDatasource(this._auth, this._firestore);

  final footprints = "footprints"; // 自分が訪問したユーザー
  final footprinteds = "footprinteds"; // 自分を訪問したユーザー
  final settings = "footprint_settings"; // 足あと設定

  // 自分を訪問したユーザーの一覧を取得
  Future<QuerySnapshot<Map<String, dynamic>>> fetchFootprinteds(
      {int limit = 20}) async {
    return await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprinteds)
        .orderBy("updatedAt", descending: true)
        .limit(limit)
        .get();
  }

  // 自分が訪問したユーザーの一覧を取得
  Future<QuerySnapshot<Map<String, dynamic>>> fetchFootprints(
      {int limit = 20}) async {
    return await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprints)
        .orderBy("updatedAt", descending: true)
        .limit(limit)
        .get();
  }

  // 自分を訪問したユーザーをリアルタイムで監視
  Stream<QuerySnapshot<Map<String, dynamic>>> streamFootprinteds(
      {int limit = 20}) {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprinteds)
        .orderBy("updatedAt", descending: true)
        .limit(limit)
        .snapshots();
  }

  // ユーザーのプロフィールを訪問した際に足あとを残す
  Future<void> addFootprint(String userId) async {
    final myUid = _auth.currentUser!.uid;
    final ts = Timestamp.now();

    // 自分と相手のプライバシー設定をチェック
    /*final mySettings = await getFootprintSettings();
    final theirSettings = await getFootprintSettings(userId: userId);

    // どちらかが無効にしている場合は記録しない
    if (mySettings["privacy"] == "disabled" ||
        theirSettings["privacy"] == "disabled") {
      return;
    } */

    // バッチ処理で操作をアトミックに行う
    final batch = _firestore.batch();

    // 自分の足あと履歴を更新
    final myFootprintRef = _firestore
        .collection("users")
        .doc(myUid)
        .collection(footprints)
        .doc(userId);

    // 相手の足あと履歴を更新
    final theirFootprintedRef = _firestore
        .collection("users")
        .doc(userId)
        .collection(footprinteds)
        .doc(myUid);

    batch.set(
        myFootprintRef,
        {
          "userId": userId,
          "count": FieldValue.increment(1),
          "updatedAt": ts,
        },
        SetOptions(merge: true));

    batch.set(
        theirFootprintedRef,
        {
          "userId": myUid,
          "count": FieldValue.increment(1),
          "updatedAt": ts,
          "isSeen": false,
        },
        SetOptions(merge: true));

    await batch.commit();
  }

  // 足あとを既読にする
  Future<void> markFootprintsSeen() async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprinteds)
        .where("isSeen", isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {"isSeen": true});
    }

    await batch.commit();
  }

  // 足あとを削除する
  Future<void> deleteFootprint(String userId) async {
    final batch = _firestore.batch();

    // 自分の履歴から削除
    final myRef = _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprints)
        .doc(userId);

    // 相手の履歴から削除
    final theirRef = _firestore
        .collection("users")
        .doc(userId)
        .collection(footprinteds)
        .doc(_auth.currentUser!.uid);

    batch.delete(myRef);
    batch.delete(theirRef);

    await batch.commit();
  }

  // 未読の足あと数を取得
  Future<int> getUnreadFootprintCount() async {
    final snapshot = await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprinteds)
        .where("isSeen", isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /*  // 足あと設定を取得
  Future<Map<String, dynamic>> getFootprintSettings({String? userId}) async {
    final uid = userId ?? _auth.currentUser!.uid;
    final doc = await _firestore
        .collection("users")
        .doc(uid)
        .collection(settings)
        .doc("settings")
        .get();

    if (!doc.exists) {
      // デフォルト設定
      return {
        "privacy": "everyone",
        "notifyOnNew": true,
      };
    }

    return doc.data()!;
  }

  // 足あと設定を更新
  Future<void> updateFootprintSettings(Map<String, dynamic> settings) async {
    await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(this.settings)
        .doc("settings")
        .set(settings, SetOptions(merge: true));
  }
 */
}
