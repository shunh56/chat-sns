import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/domain/usecases/footprint/get_visited_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 自分が訪問したユーザー一覧（ストリーム）
// 各訪問先（visitedUserId）ごとに最新の1件のみを表示
final visitedProvider = StreamProvider.autoDispose<List<Footprint>>((ref) {
  final usecase = ref.watch(getVisitedUsecaseProvider);
  return usecase.getVisitedProfiles().map((footprints) {
    // visitedUserIdごとに最新の訪問記録のみをフィルタリング
    final Map<String, Footprint> latestByVisitedUser = {};

    for (final footprint in footprints) {
      final visitedUserId = footprint.visitedUserId;

      // まだ登録されていないか、より新しい記録の場合は更新
      if (!latestByVisitedUser.containsKey(visitedUserId) ||
          footprint.visitedAt.compareTo(latestByVisitedUser[visitedUserId]!.visitedAt) >
              0) {
        latestByVisitedUser[visitedUserId] = footprint;
      }
    }

    // 訪問日時の降順でソートして返す
    final result = latestByVisitedUser.values.toList()
      ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

    return result;
  });
});
