// lib/domain/repositories/tag_repository.dart
import 'package:app/domain/entity/tag_stat.dart';

abstract class TagRepository {
  // 即時処理：ユーザーのタグ更新
  Future<void> updateUserTagsImmediate(
      List<String> newTags, List<String> previousTags);

  // 即時処理：ユーザーのタグリスト取得
  Future<List<String>> getUserTags(String userId);

  // 定時処理：全タグの統計情報更新
  Future<void> updateTagStatsDaily();

  // 統計情報取得
  Future<TagStat> getTagStat(String tagId);
  Future<List<TagStat>> getPopularTags({int limit = 10});

  // タグを選択しているユーザー取得
  Future<List<String>> getUsersByTag(String tagId,
      {int limit = 20, String? lastUserId});

  // タグの使用履歴取得
  Future<List<TagHistory>> getTagHistory(String tagId,
      {required DateTime startDate, required DateTime endDate});
}
