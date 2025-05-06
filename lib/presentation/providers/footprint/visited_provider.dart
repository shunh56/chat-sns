import 'package:app/domain/entity/footprint.dart';
import 'package:app/domain/usecases/footprint/get_visited_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 自分が訪問したユーザー一覧（キャッシュ）
final visitedProvider = FutureProvider<List<Footprint>>(
  (ref) async {
    final usecase = ref.watch(getVisitedUsecaseProvider);
    return await usecase.getVisitedProfiles();
  },
);

// 手動リロードが必要な場合に使用するプロバイダ
final visitedControllerProvider =
    StateNotifierProvider<VisitedController, AsyncValue<List<Footprint>>>(
  (ref) => VisitedController(ref.watch(getVisitedUsecaseProvider)),
);

class VisitedController extends StateNotifier<AsyncValue<List<Footprint>>> {
  final GetVisitedUsecase _getVisitedUsecase;

  VisitedController(this._getVisitedUsecase)
      : super(const AsyncValue.loading()) {
    loadVisited();
  }

  Future<void> loadVisited() async {
    try {
      state = const AsyncValue.loading();
      final visited = await _getVisitedUsecase.getVisitedProfiles();
      state = AsyncValue.data(visited);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    try {
      final visited = await _getVisitedUsecase.getVisitedProfiles();
      state = AsyncValue.data(visited);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  removeFootprint(String userId) {
    final list = state.value ?? [];
    list.removeWhere((item) => item.userId == userId);
    state = AsyncValue.data(list);
  }
}
