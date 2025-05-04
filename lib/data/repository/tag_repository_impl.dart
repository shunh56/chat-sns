// lib/data/repositories/tag_repository_impl.dart
import 'package:app/data/datasource/local/hashtags.dart';
import 'package:app/data/datasource/tag_datasource.dart';
import 'package:app/domain/entity/tag_stat.dart';
import 'package:app/domain/repository_interface/tag_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<List<String>> getUserTags(String userId) async {
    return await _datasource.getUserTags(userId);
  }

  @override
  Future<void> updateTagStatsDaily() async {
    await _datasource.updateTagStatsDaily();
  }

  @override
  Future<TagStat> getTagStat(String tagId) async {
    final data = await _datasource.getTagStat(tagId);
    return TagStat(
      id: data['id'],
      text: data['text'] ?? getTextFromId(tagId) ?? tagId,
      count: data['count'] ?? 0,
      lastUpdated: data['lastUpdated'] ?? Timestamp.now(),
    );
  }

  @override
  Future<List<TagStat>> getPopularTags({int limit = 10}) async {
    final dataList = await _datasource.getPopularTags(limit: limit);
    return dataList
        .map(
          (data) => TagStat(
            id: data['id'],
            text: data['text'] ?? getTextFromId(data['id']) ?? data['id'],
            count: data['count'] ?? 0,
            lastUpdated: data['lastUpdated'],
          ),
        )
        .toList();
  }

  @override
  Future<List<String>> getUsersByTag(String tagId,
      {int limit = 20, String? lastUserId}) async {
    return await _datasource.getUsersByTag(tagId,
        limit: limit, lastUserId: lastUserId);
  }

  @override
  Future<List<TagHistory>> getTagHistory(
    String tagId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final dataList = await _datasource.getTagHistory(
      tagId,
      startDate: startDate,
      endDate: endDate,
    );

    return dataList
        .map(
          (data) => TagHistory(
            tagId: tagId,
            count: data['count'] ?? 0,
            timestamp: data['timestamp'],
          ),
        )
        .toList();
  }
}
