import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:app/domain/entity/tag/tagged_user.dart';
import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTagDatasourceProvider = Provider((ref) {
  return UserTagDatasource(ref.watch(firestoreProvider));
});

class UserTagDatasource {
  final FirebaseFirestore _firestore;

  UserTagDatasource(this._firestore);

  // ========================================
  // タグ定義 (users/{userId}/tags/{tagId})
  // ========================================

  /// ユーザーのタグ一覧を取得
  Stream<List<UserTag>> watchUserTags(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserTag.fromJson(doc.data()))
            .toList());
  }

  /// タグを取得
  Future<UserTag?> getUserTag(String userId, String tagId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tagId)
        .get();

    if (!doc.exists) return null;
    return UserTag.fromJson(doc.data()!);
  }

  /// タグを作成/更新
  Future<void> setUserTag(String userId, UserTag tag) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tag.tagId)
        .set(tag.toJson());
  }

  /// タグを削除
  Future<void> deleteUserTag(String userId, String tagId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tagId)
        .delete();
  }

  /// タグのuserCountを更新
  Future<void> updateTagUserCount(
      String userId, String tagId, int delta) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tagId)
        .update({
      'userCount': FieldValue.increment(delta),
    });
  }

  /// システムタグを初期化 (初回ログイン時)
  Future<void> initializeSystemTags(String userId) async {
    final batch = _firestore.batch();

    for (final tagData in UserTag.systemTags) {
      final tag = UserTag.systemTag(tagData);
      final ref = _firestore
          .collection('users')
          .doc(userId)
          .collection('tags')
          .doc(tag.tagId);
      batch.set(ref, tag.toJson());
    }

    await batch.commit();
  }

  // ========================================
  // タグ付けされたユーザー (user_tags/{userId}/tagged_users/{targetId})
  // ========================================

  /// タグ付けされたユーザー一覧を取得
  Stream<List<TaggedUser>> watchTaggedUsers(String userId) {
    return _firestore
        .collection('user_tags')
        .doc(userId)
        .collection('tagged_users')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaggedUser.fromJson(doc.data()))
            .toList());
  }

  /// 特定のタグが付いたユーザー一覧を取得
  Stream<List<TaggedUser>> watchTaggedUsersByTag(
      String userId, String tagId) {
    return _firestore
        .collection('user_tags')
        .doc(userId)
        .collection('tagged_users')
        .where('tags', arrayContains: tagId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaggedUser.fromJson(doc.data()))
            .toList());
  }

  /// タグ付けされたユーザーを取得
  Future<TaggedUser?> getTaggedUser(String userId, String targetId) async {
    final doc = await _firestore
        .collection('user_tags')
        .doc(userId)
        .collection('tagged_users')
        .doc(targetId)
        .get();

    if (!doc.exists) return null;
    return TaggedUser.fromJson(doc.data()!);
  }

  /// ユーザーにタグを付ける
  Future<void> tagUser(String userId, String targetId, List<String> tags,
      {String? memo}) async {
    final existingTaggedUser = await getTaggedUser(userId, targetId);
    final previousTags = existingTaggedUser?.tags ?? [];

    final taggedUser = TaggedUser.create(
      userId: userId,
      targetId: targetId,
      tags: tags,
      memo: memo,
    );

    await _firestore
        .collection('user_tags')
        .doc(userId)
        .collection('tagged_users')
        .doc(targetId)
        .set(taggedUser.toJson());

    // タグのuserCountを更新
    final addedTags = tags.where((tag) => !previousTags.contains(tag)).toList();
    final removedTags =
        previousTags.where((tag) => !tags.contains(tag)).toList();

    for (final tagId in addedTags) {
      await updateTagUserCount(userId, tagId, 1);
    }
    for (final tagId in removedTags) {
      await updateTagUserCount(userId, tagId, -1);
    }
  }

  /// ユーザーのタグを解除
  Future<void> untagUser(String userId, String targetId) async {
    final existingTaggedUser = await getTaggedUser(userId, targetId);
    if (existingTaggedUser == null) return;

    await _firestore
        .collection('user_tags')
        .doc(userId)
        .collection('tagged_users')
        .doc(targetId)
        .delete();

    // すべてのタグのuserCountを減らす
    for (final tagId in existingTaggedUser.tags) {
      await updateTagUserCount(userId, tagId, -1);
    }
  }

  /// メモを更新
  Future<void> updateMemo(
      String userId, String targetId, String? memo) async {
    await _firestore
        .collection('user_tags')
        .doc(userId)
        .collection('tagged_users')
        .doc(targetId)
        .update({
      'memo': memo,
      'updatedAt': Timestamp.now(),
    });
  }

  /// 特定のタグを追加
  Future<void> addTag(String userId, String targetId, String tagId) async {
    final taggedUser = await getTaggedUser(userId, targetId);
    if (taggedUser == null) {
      // 新規作成
      await tagUser(userId, targetId, [tagId]);
    } else if (!taggedUser.tags.contains(tagId)) {
      // 既存に追加
      final newTags = [...taggedUser.tags, tagId];
      await _firestore
          .collection('user_tags')
          .doc(userId)
          .collection('tagged_users')
          .doc(targetId)
          .update({
        'tags': newTags,
        'updatedAt': Timestamp.now(),
      });
      await updateTagUserCount(userId, tagId, 1);
    }
  }

  /// 特定のタグを削除
  Future<void> removeTag(String userId, String targetId, String tagId) async {
    final taggedUser = await getTaggedUser(userId, targetId);
    if (taggedUser == null || !taggedUser.tags.contains(tagId)) return;

    final newTags = taggedUser.tags.where((t) => t != tagId).toList();

    if (newTags.isEmpty) {
      // タグがなくなったら削除
      await untagUser(userId, targetId);
    } else {
      await _firestore
          .collection('user_tags')
          .doc(userId)
          .collection('tagged_users')
          .doc(targetId)
          .update({
        'tags': newTags,
        'updatedAt': Timestamp.now(),
      });
      await updateTagUserCount(userId, tagId, -1);
    }
  }
}
