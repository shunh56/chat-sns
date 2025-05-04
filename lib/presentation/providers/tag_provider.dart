// lib/presentation/providers/tag/tag_providers.dart
import 'package:app/data/repository/tag_repository_impl.dart';
import 'package:app/domain/entity/tag_stat.dart';
import 'package:app/domain/usecases/tag/get_popular_tags_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 特定のタグに関する統計情報を提供します
/// タグの詳細情報（何人のユーザーが選択しているか、最終更新日時など）を表示する際に使用します。
/// [tagId] - 統計情報を取得したいタグのID
final tagStatProvider = FutureProvider.family<TagStat, String>((ref, tagId) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.getTagStat(tagId);
});

/// 人気順にソートされたタグのリストを提供します
/// トレンドタグやおすすめタグをユーザーに表示する際に使用します。結果はユーザー数の多い順（人気順）に降順でソートされます。
/// [limit] - 取得するタグの最大数
final popularTagsProvider =
    FutureProvider.family<List<TagStat>, int>((ref, limit) {
  final usecase = ref.watch(getPopularTagsUsecaseProvider);
  return usecase.execute(5);
});

/// 特定のタグを選択しているユーザーのリストを提供します
/// 「同じ興味を持つユーザー」機能やタグベースのユーザー検索機能を実装する際に使用します。結果は最近選択したユーザーが先頭に来るようにソートされます。
/// [params] - タグID、取得件数、ページネーション用カーソルを含むパラメータ
final tagUsersProvider =
    FutureProvider.family<List<String>, TagUsersParams>((ref, params) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.getUsersByTag(params.tagId,
      limit: params.limit, lastUserId: params.lastUserId);
});

/// 特定のタグの履歴統計データを期間指定で提供します
/// トレンドグラフや人気度の推移比較などの分析機能を実装する際に使用します。
/// [params] - タグIDと日付範囲を含むパラメータ
final tagHistoryProvider =
    FutureProvider.family<List<TagHistory>, TagHistoryParams>((ref, params) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.getTagHistory(
    params.tagId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// tagUsersProviderのためのパラメータクラス
/// 特定のタグを選択しているユーザーを取得する際に、
/// タグID、取得件数、ページネーションパラメータを指定するために使用します。
class TagUsersParams {
  final String tagId;
  final int limit;
  final String? lastUserId;

  TagUsersParams({
    required this.tagId,
    this.limit = 20,
    this.lastUserId,
  });
}

/// tagHistoryProviderのためのパラメータクラス
/// 特定のタグの履歴統計を取得する際に、
/// タグIDと日付範囲パラメータを指定するために使用します。
class TagHistoryParams {
  /// 履歴を取得するタグのID
  final String tagId;
  final DateTime startDate;
  final DateTime endDate;

  TagHistoryParams({
    required this.tagId,
    required this.startDate,
    required this.endDate,
  });
}
