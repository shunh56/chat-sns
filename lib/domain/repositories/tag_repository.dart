// lib/domain/repositories/tag_repository.dart



import 'package:app/domain/entity/tag/tag.dart';

abstract class TagRepository {
  // 全てのアクティブなタグを取得
  Future<List<Tag>> getAllTags();
  
  // カテゴリ別にタグを取得
  Future<List<Tag>> getTagsByCategory(String category);
  
  // タグIDで単一のタグを取得
  Future<Tag?> getTagById(String tagId);
  
  // タグ名でタグを検索
  Future<List<Tag>> searchTags(String query);
  
  // タグの使用回数を増加
  Future<void> incrementTagUsage(String tagId);
  
  // 初期タグをアップロード
  Future<void> uploadInitialTags(List<Tag> tags);
  
  // タグをアクティブ/非アクティブに切り替え (管理者機能)
  Future<void> toggleTagActive(String tagId, bool isActive);
}