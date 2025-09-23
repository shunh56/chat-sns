import 'dart:async';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/footprint.dart';
import 'package:app/domain/usecases/footprint/get_visitors_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 訪問者リストのステート（キャッシュ）
final visitorsProvider = StateNotifierProvider.autoDispose<VisitorsNotifier,
    AsyncValue<List<Footprint>>>((ref) {
  ref.keepAlive();
  return VisitorsNotifier(
    ref.watch(getVisitorsUsecaseProvider),
  );
});

class VisitorsNotifier extends StateNotifier<AsyncValue<List<Footprint>>> {
  final GetVisitorsUsecase _getVisitorsUsecase;

  VisitorsNotifier(this._getVisitorsUsecase)
      : super(const AsyncValue.loading()) {
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    DebugPrint("Load visitors");
    try {
      state = const AsyncValue.loading();
      final visitors = await _getVisitorsUsecase.getProfileVisitors();
      state = AsyncValue.data(visitors);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /*void _subscribeToVisitors() {
    _subscription = _streamVisitorsUsecase.streamProfileVisitors().listen(
      (visitors) {
        state = AsyncValue.data(visitors);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    );
  } */

  // 明示的に再読み込みするためのメソッド
  Future<void> refresh() async {
    try {
      final visitors = await _getVisitorsUsecase.getProfileVisitors();
      state = AsyncValue.data(visitors);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  @override
  void dispose() {
    // _subscription?.cancel();
    DebugPrint("ON DISPOSE");
    super.dispose();
  }
}
