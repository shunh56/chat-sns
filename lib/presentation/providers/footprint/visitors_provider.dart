import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/domain/usecases/footprint/get_visitors_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 訪問者リストのステート（ストリーム）
// 各訪問者（visitorId）ごとに最新の1件のみを表示
final visitorsProvider = StreamProvider.autoDispose<List<Footprint>>((ref) {
  final usecase = ref.watch(getVisitorsUsecaseProvider);
  return usecase.getProfileVisitors().map((footprints) {
    // visitorIdごとに最新の訪問記録のみをフィルタリング
    final Map<String, Footprint> latestByVisitor = {};

    for (final footprint in footprints) {
      final visitorId = footprint.visitorId;

      // まだ登録されていないか、より新しい記録の場合は更新
      if (!latestByVisitor.containsKey(visitorId) ||
          footprint.visitedAt.compareTo(latestByVisitor[visitorId]!.visitedAt) >
              0) {
        latestByVisitor[visitorId] = footprint;
      }
    }

    // 訪問日時の降順でソートして返す
    final result = latestByVisitor.values.toList()
      ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

    return result;
  });
});
