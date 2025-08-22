import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagDatasourceProvider = Provider(
  (ref) => TagDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class TagDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  TagDatasource(this._auth, this._firestore);

  final collectionName = "tags";

  //タグを更新する処理
  Future<void> updateUserTagsImmediate(
      List<String> newTags, List<String> previousTags) async {
    final batch = _firestore.batch();
    final timestamp = FieldValue.serverTimestamp();
    // 削除されたタグの処理
    final removedTags = previousTags.where((tag) => !newTags.contains(tag));
    for (final tagId in removedTags) {
      //タグ情報の変更
      await _updateTagDocument(batch, timestamp, tagId, isAdd: false);
      // usersサブコレクションのステータスを変更
      await _updateUserDocument(batch, timestamp, tagId, isAdd: false);
      // 履歴スナップショットを追加
      await _updateHistoryDocument(batch, timestamp, tagId, isAdd: false);
    }
    // 追加されたタグの処理
    final addedTags = newTags.where((tag) => !previousTags.contains(tag));
    for (final tagId in addedTags) {
      // タグの処理
      await _updateTagDocument(batch, timestamp, tagId);
      await _updateUserDocument(batch, timestamp, tagId);
      await _updateHistoryDocument(batch, timestamp, tagId);
    }
    // バッチ実行
    await batch.commit();
  }

  //GET

  Future<Map<String, dynamic>> getTag(String tagId) async {
    final res = await _firestore.collection(collectionName).doc(tagId).get();
    return res.data() ?? {};
  }

  //カウントの多いタグを10つ取得する
  Future<List<Map<String, dynamic>>> getPopularTags({int limit = 10}) async {
    final snapshot = await _firestore
        .collection('tags')
        .orderBy('count', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  //タグを設定した直近ユーザーの取得
  Future<List<Map<String, dynamic>>> getActiveUsers(String tagId,
      {String? lastUserId}) async {
    final limit = lastUserId == null ? 3 : 20;
    Query query = _firestore
        .collection(collectionName)
        .doc(tagId)
        .collection('users')
        .where('isActive', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    if (lastUserId != null) {
      final lastDoc = await _firestore
          .collection(collectionName)
          .doc(tagId)
          .collection('users')
          .doc(lastUserId)
          .get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs.map((item) {
      Map<String, dynamic> json = item.data() as Map<String, dynamic>;
      json.addAll({"id": item.id});
      return json;
    }).toList();
  }

  Future<void> _updateTagDocument(
      WriteBatch batch, FieldValue timestamp, String tagId,
      {bool isAdd = true}) async {
    final ref = _firestore.collection(collectionName).doc(tagId);
    final doc = await ref.get();
    if (!doc.exists) return;
    batch.update(ref, {
      "count": isAdd ? FieldValue.increment(1) : FieldValue.increment(-1),
      "updatedAt": timestamp,
    });
  }

  Future<void> _updateUserDocument(
      WriteBatch batch, FieldValue timestamp, String tagId,
      {bool isAdd = true}) async {
    final ref = _firestore
        .collection(collectionName)
        .doc(tagId)
        .collection("users")
        .doc(_auth.currentUser!.uid);
    if (isAdd) {
      batch.set(
        ref,
        {'isActive': true, 'updatedAt': timestamp},
        SetOptions(merge: true),
      );
    } else {
      batch.set(
        ref,
        {'isActive': false, 'updatedAt': timestamp},
        SetOptions(merge: true),
      );
    }
  }

  Future<void> _updateHistoryDocument(
      WriteBatch batch, FieldValue timestamp, String tagId,
      {bool isAdd = true}) async {
    final dateId = DateTime.now().toIso8601String().substring(0, 10);
    final ref = _firestore
        .collection(collectionName)
        .doc(tagId)
        .collection("history")
        .doc(dateId);
    if (isAdd) {
      batch.set(
        ref,
        {'count': FieldValue.increment(1), 'updatedAt': timestamp},
        SetOptions(merge: true),
      );
    } else {
      batch.set(
        ref,
        {'count': FieldValue.increment(-1), 'updatedAt': timestamp},
        SetOptions(merge: true),
      );
    }
  }
}
