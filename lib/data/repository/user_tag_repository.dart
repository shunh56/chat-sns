import 'package:app/data/datasource/user_tag_datasource.dart';
import 'package:app/domain/entity/tag/tagged_user.dart';
import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTagRepositoryProvider = Provider((ref) {
  return UserTagRepository(ref.watch(userTagDatasourceProvider));
});

class UserTagRepository {
  final UserTagDatasource _datasource;

  UserTagRepository(this._datasource);

  // ========================================
  // タグ定義
  // ========================================

  /// ユーザーのタグ一覧を取得
  Stream<List<UserTag>> watchUserTags(String userId) {
    return _datasource.watchUserTags(userId);
  }

  /// タグを取得
  Future<UserTag?> getUserTag(String userId, String tagId) {
    return _datasource.getUserTag(userId, tagId);
  }

  /// タグを作成/更新
  Future<void> setUserTag(String userId, UserTag tag) {
    return _datasource.setUserTag(userId, tag);
  }

  /// タグを削除
  Future<void> deleteUserTag(String userId, String tagId) {
    return _datasource.deleteUserTag(userId, tagId);
  }

  /// システムタグを初期化
  Future<void> initializeSystemTags(String userId) {
    return _datasource.initializeSystemTags(userId);
  }

  // ========================================
  // タグ付けされたユーザー
  // ========================================

  /// タグ付けされたユーザー一覧を取得
  Stream<List<TaggedUser>> watchTaggedUsers(String userId) {
    return _datasource.watchTaggedUsers(userId);
  }

  /// 特定のタグが付いたユーザー一覧を取得
  Stream<List<TaggedUser>> watchTaggedUsersByTag(String userId, String tagId) {
    return _datasource.watchTaggedUsersByTag(userId, tagId);
  }

  /// タグ付けされたユーザーを取得
  Future<TaggedUser?> getTaggedUser(String userId, String targetId) {
    return _datasource.getTaggedUser(userId, targetId);
  }

  /// ユーザーにタグを付ける
  Future<void> tagUser(String userId, String targetId, List<String> tags,
      {String? memo}) {
    return _datasource.tagUser(userId, targetId, tags, memo: memo);
  }

  /// ユーザーのタグを解除
  Future<void> untagUser(String userId, String targetId) {
    return _datasource.untagUser(userId, targetId);
  }

  /// メモを更新
  Future<void> updateMemo(String userId, String targetId, String? memo) {
    return _datasource.updateMemo(userId, targetId, memo);
  }

  /// 特定のタグを追加
  Future<void> addTag(String userId, String targetId, String tagId) {
    return _datasource.addTag(userId, targetId, tagId);
  }

  /// 特定のタグを削除
  Future<void> removeTag(String userId, String targetId, String tagId) {
    return _datasource.removeTag(userId, targetId, tagId);
  }
}
