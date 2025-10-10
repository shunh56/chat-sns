import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/data/datasource/footprint_datasource.dart';
import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/domain/entity/footprint/footprint_statistics.dart';
import 'package:app/domain/repository/footprint_repository_interface.dart';
import 'package:app/presentation/providers/shared/users/my_user_account_notifier.dart';

/// 足あとリポジトリの実装プロバイダー
final footprintRepositoryImplProvider = Provider<IFootprintRepository>((ref) {
  return FootprintRepositoryImpl(
    datasource: ref.watch(footprintDatasourceProvider),
    myUserId: ref.watch(myAccountNotifierProvider).asData?.value.userId ?? '',
  );
});

/// 足あとリポジトリの実装
///
/// クリーンアーキテクチャに基づき、Data層で具体的な実装を提供
/// Firestore操作は全てDatasource層に委譲する
class FootprintRepositoryImpl implements IFootprintRepository {
  final FootprintDatasource datasource;
  final String myUserId;

  FootprintRepositoryImpl({
    required this.datasource,
    required this.myUserId,
  });

  @override
  Stream<List<Footprint>> getRecentVisitorsStream() {
    if (myUserId.isEmpty) {
      return Stream.value([]);
    }

    return datasource.getRecentVisitors(myUserId);
  }

  @override
  Stream<List<Footprint>> getVisitorsStream() {
    if (myUserId.isEmpty) {
      return Stream.value([]);
    }

    return datasource.getVisitors(myUserId);
  }

  @override
  Stream<List<Footprint>> getVisitedStream() {
    if (myUserId.isEmpty) {
      return Stream.value([]);
    }

    return datasource.getVisited(myUserId);
  }

  @override
  Future<void> visitProfile(String targetUserId) async {
    if (myUserId.isEmpty || myUserId == targetUserId) {
      return; // 自分自身のプロフィールは記録しない
    }

    try {
      await datasource.addFootprint(targetUserId);
    } catch (e) {
      throw FootprintException('Failed to visit profile: $e');
    }
  }

  @override
  Future<void> markMultipleAsSeen(List<String> footprintIds) async {
    if (myUserId.isEmpty || footprintIds.isEmpty) {
      return;
    }

    try {
      await datasource.markMultipleAsSeen(myUserId, footprintIds);
    } catch (e) {
      throw FootprintException('Failed to mark footprints as seen: $e');
    }
  }

  @override
  Future<void> markAllFootprintsSeen() async {
    if (myUserId.isEmpty) {
      return;
    }

    try {
      await datasource.markSeen(myUserId);
    } catch (e) {
      throw FootprintException('Failed to mark all footprints as seen: $e');
    }
  }

  @override
  Future<void> removeFootprint(String userId) async {
    if (myUserId.isEmpty) {
      return;
    }

    try {
      await datasource.deleteFootprint(userId);
    } catch (e) {
      throw FootprintException('Failed to remove footprint: $e');
    }
  }

  @override
  Future<int> getRecentUnseenCount() async {
    if (myUserId.isEmpty) {
      return 0;
    }

    try {
      return await datasource.getRecentUnseenCount(myUserId);
    } catch (e) {
      throw FootprintException('Failed to get unseen count: $e');
    }
  }

  @override
  Future<FootprintStatistics> getStatistics() async {
    if (myUserId.isEmpty) {
      return FootprintStatistics.empty();
    }

    try {
      final now = DateTime.now();
      final twentyFourHoursAgo = Timestamp.fromDate(
        now.subtract(const Duration(hours: 24)),
      );
      final oneWeekAgo = Timestamp.fromDate(
        now.subtract(const Duration(days: 7)),
      );
      final oneMonthAgo = Timestamp.fromDate(
        now.subtract(const Duration(days: 30)),
      );

      // パラレル実行で効率化（Datasource層のメソッドを並列で呼び出す）
      final results = await Future.wait([
        datasource.getCountForPeriod(myUserId, twentyFourHoursAgo),
        datasource.getCountForPeriod(myUserId, oneWeekAgo),
        datasource.getCountForPeriod(myUserId, oneMonthAgo),
        datasource.getUnseenCount(myUserId),
        datasource.getHourlyDistribution(myUserId),
        datasource.getFrequentVisitors(myUserId),
      ]);

      return FootprintStatistics(
        last24Hours: results[0] as int,
        lastWeek: results[1] as int,
        lastMonth: results[2] as int,
        unseenCount: results[3] as int,
        hourlyDistribution: results[4] as Map<int, int>,
        frequentVisitors: results[5] as List<String>,
      );
    } catch (e) {
      throw FootprintException('Failed to get statistics: $e');
    }
  }
}

/// 足あと機能のエラー
class FootprintException implements Exception {
  final String message;

  FootprintException(this.message);

  @override
  String toString() => 'FootprintException: $message';
}
