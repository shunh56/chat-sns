import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/repository/user_tag_repository.dart';
import 'package:app/domain/entity/tag/tagged_user.dart';
import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final userTagUsecaseProvider = Provider((ref) {
  final currentUser = ref.watch(authProvider).currentUser;
  // ログイン前はnullを返す（呼び出し側でハンドリング）
  if (currentUser == null) {
    throw Exception('User not authenticated - Please login first');
  }
  return UserTagUsecase(
    ref.watch(userTagRepositoryProvider),
    currentUser.uid,
  );
});

class UserTagUsecase {
  final UserTagRepository _repository;
  final String _currentUserId;

  UserTagUsecase(this._repository, this._currentUserId);

  // ========================================
  // タグ定義
  // ========================================

  /// 現在のユーザーのタグ一覧を取得
  Stream<List<UserTag>> watchMyTags() {
    return _repository.watchUserTags(_currentUserId);
  }

  /// タグを取得
  Future<UserTag?> getTag(String tagId) {
    return _repository.getUserTag(_currentUserId, tagId);
  }

  /// カスタムタグを作成
  Future<void> createCustomTag({
    required String name,
    required String icon,
    required String color,
    required int priority,
  }) async {
    final tagId = const Uuid().v4();
    final tag = UserTag.custom(
      tagId: tagId,
      name: name,
      icon: icon,
      color: color,
      priority: priority,
    );
    await _repository.setUserTag(_currentUserId, tag);
  }

  /// タグを更新
  Future<void> updateTag(UserTag tag) async {
    final updatedTag = tag.copyWith(updatedAt: Timestamp.now());
    await _repository.setUserTag(_currentUserId, updatedTag);
  }

  /// タグを削除
  Future<void> deleteTag(String tagId) {
    return _repository.deleteUserTag(_currentUserId, tagId);
  }

  /// システムタグを初期化 (初回ログイン時)
  Future<void> initializeSystemTags() {
    return _repository.initializeSystemTags(_currentUserId);
  }

  /// タグのタイムライン表示を切り替え
  Future<void> toggleTimelineVisibility(String tagId, bool show) async {
    final tag = await getTag(tagId);
    if (tag == null) return;
    await updateTag(tag.copyWith(showInTimeline: show));
  }

  /// タグの通知を切り替え
  Future<void> toggleNotifications(String tagId, bool enable) async {
    final tag = await getTag(tagId);
    if (tag == null) return;
    await updateTag(tag.copyWith(enableNotifications: enable));
  }

  // ========================================
  // タグ付けされたユーザー
  // ========================================

  /// タグ付けされたユーザー一覧を取得
  Stream<List<TaggedUser>> watchMyTaggedUsers() {
    return _repository.watchTaggedUsers(_currentUserId);
  }

  /// 特定のタグが付いたユーザー一覧を取得
  Stream<List<TaggedUser>> watchTaggedUsersByTag(String tagId) {
    return _repository.watchTaggedUsersByTag(_currentUserId, tagId);
  }

  /// タグ付けされたユーザーを取得
  Future<TaggedUser?> getTaggedUser(String targetId) {
    return _repository.getTaggedUser(_currentUserId, targetId);
  }

  /// ユーザーにタグを付ける (複数タグ一括設定)
  Future<void> tagUser(String targetId, List<String> tags, {String? memo}) {
    return _repository.tagUser(_currentUserId, targetId, tags, memo: memo);
  }

  /// ユーザーのタグを解除 (全タグ削除)
  Future<void> untagUser(String targetId) {
    return _repository.untagUser(_currentUserId, targetId);
  }

  /// メモを更新
  Future<void> updateMemo(String targetId, String? memo) {
    return _repository.updateMemo(_currentUserId, targetId, memo);
  }

  /// 特定のタグを追加
  Future<void> addTag(String targetId, String tagId) {
    return _repository.addTag(_currentUserId, targetId, tagId);
  }

  /// 特定のタグを削除
  Future<void> removeTag(String targetId, String tagId) {
    return _repository.removeTag(_currentUserId, targetId, tagId);
  }

  /// タグをトグル (あれば削除、なければ追加)
  Future<void> toggleTag(String targetId, String tagId) async {
    final taggedUser = await getTaggedUser(targetId);
    if (taggedUser == null || !taggedUser.tags.contains(tagId)) {
      await addTag(targetId, tagId);
    } else {
      await removeTag(targetId, tagId);
    }
  }

  /// ユーザーが特定のタグを持っているかチェック
  Future<bool> hasTag(String targetId, String tagId) async {
    final taggedUser = await getTaggedUser(targetId);
    return taggedUser?.tags.contains(tagId) ?? false;
  }

  /// ユーザーに付いているタグのリストを取得
  Future<List<String>> getUserTags(String targetId) async {
    final taggedUser = await getTaggedUser(targetId);
    return taggedUser?.tags ?? [];
  }
}
