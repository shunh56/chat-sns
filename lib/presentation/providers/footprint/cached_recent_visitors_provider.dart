import 'package:app/domain/entity/footprint/footprint_statistics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app/domain/usecases/footprint/get_recent_visitors_count_usecase.dart';
import 'package:app/domain/usecases/footprint/get_footprint_statistics_usecase.dart';

/// キャッシュタイムスタンプを管理
final _cacheTimestampProvider = StateProvider<DateTime?>((ref) => null);

/// キャッシュされた統計情報
final _cachedStatisticsProvider =
    StateProvider<FootprintStatistics?>((ref) => null);

/// キャッシュの有効期限（分）
const _cacheExpirationMinutes = 5;

/// キャッシュ付き過去24時間以内の足あと件数プロバイダー
final cachedRecentVisitorsCountProvider = StreamProvider<int>((ref) {
  final useCase = ref.watch(getRecentVisitorsCountUseCaseProvider);
  return useCase.execute();
});

/// キャッシュ付き未読足あと件数プロバイダー
final cachedUnseenVisitorsCountProvider = StreamProvider<int>((ref) {
  final useCase = ref.watch(getRecentVisitorsCountUseCaseProvider);

  return useCase.executeUnseen();
});

/// キャッシュ付き統計情報プロバイダー
final cachedFootprintStatisticsProvider =
    FutureProvider<FootprintStatistics>((ref) async {
  final cacheTimestamp = ref.read(_cacheTimestampProvider);
  final cachedStats = ref.read(_cachedStatisticsProvider);
  final now = DateTime.now();

  // キャッシュが有効な場合はキャッシュを返す
  if (cacheTimestamp != null &&
      cachedStats != null &&
      now.difference(cacheTimestamp).inMinutes < _cacheExpirationMinutes) {
    return cachedStats;
  }

  // 新しい統計情報を取得
  final useCase = ref.read(getFootprintStatisticsUseCaseProvider);
  final stats = await useCase.execute();

  // キャッシュを更新
  ref.read(_cacheTimestampProvider.notifier).state = now;
  ref.read(_cachedStatisticsProvider.notifier).state = stats;

  return stats;
});

/// 手動でキャッシュをリフレッシュ
class FootprintCacheManager {
  final Ref ref;

  FootprintCacheManager(this.ref);

  /// キャッシュをクリア
  void clearCache() {
    ref.read(_cacheTimestampProvider.notifier).state = null;
    ref.read(_cachedStatisticsProvider.notifier).state = null;
  }

  /// キャッシュを強制更新
  Future<void> refreshCache() async {
    clearCache();
    await ref.read(cachedFootprintStatisticsProvider.future);
  }

  /// キャッシュの有効性をチェック
  bool isCacheValid() {
    final timestamp = ref.read(_cacheTimestampProvider);
    if (timestamp == null) return false;

    final now = DateTime.now();
    return now.difference(timestamp).inMinutes < _cacheExpirationMinutes;
  }
}

/// キャッシュマネージャーのプロバイダー
final footprintCacheManagerProvider = Provider((ref) {
  return FootprintCacheManager(ref);
});

/// エラーハンドリング付き足あと件数プロバイダー
final safeRecentVisitorsCountProvider = Provider<int>((ref) {
  final asyncValue = ref.watch(cachedRecentVisitorsCountProvider);

  return asyncValue.when(
    data: (count) => count,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// エラーハンドリング付き未読件数プロバイダー
final safeUnseenVisitorsCountProvider = Provider<int>((ref) {
  final asyncValue = ref.watch(cachedUnseenVisitorsCountProvider);

  return asyncValue.when(
    data: (count) => count,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
