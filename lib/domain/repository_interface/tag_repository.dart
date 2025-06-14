// lib/domain/repositories/tag_repository.dart
import 'package:app/domain/entity/tag_stat.dart';

abstract class TagRepository {
  // 即時処理：ユーザーのタグ更新
  Future<void> updateUserTagsImmediate(
      List<String> newTags, List<String> previousTags);

  Future<TagInfo> getTagInfo(String tagId);

  // 統計情報取得
  Future<List<TagInfo>> getPopularTags({int limit = 5});

  // タグを選択しているユーザー取得
  Future<List<TagUser>> getActiveUsers(String tagId, {String? lastUserId});
}
