// lib/data/repositories/tag_repository_impl.dart
import 'package:app/data/datasource/tag_datasource.dart';
import 'package:app/domain/entity/tag_stat.dart';
import 'package:app/domain/repository_interface/tag_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final dataSource = ref.watch(tagDatasourceProvider);
  return TagRepositoryImpl(dataSource);
});

class TagRepositoryImpl implements TagRepository {
  final TagDatasource _datasource;

  TagRepositoryImpl(this._datasource);

  @override
  Future<void> updateUserTagsImmediate(
      List<String> newTags, List<String> previousTags) async {
    await _datasource.updateUserTagsImmediate(newTags, previousTags);
  }

  @override
  Future<TagInfo> getTagInfo(String tagId) async {
    final res = await _datasource.getTag(tagId);
    return TagInfo.fromJson(res);
  }

  @override
  Future<List<TagInfo>> getPopularTags({int limit = 10}) async {
    final res = await _datasource.getPopularTags(limit: limit);
    return res.map((data) => TagInfo.fromJson(data)).toList();
  }

  @override
  Future<List<TagUser>> getActiveUsers(String tagId,
      {String? lastUserId}) async {
    final res = await _datasource.getActiveUsers(tagId, lastUserId: lastUserId);
    return res.map((json) => TagUser.fromJson(json)).toList();
  }
}
