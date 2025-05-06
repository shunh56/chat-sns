import 'package:app/domain/usecases/footprint/get_unread_count_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 未読の足あと数をキャッシュするプロバイダ
final unreadFootprintCountProvider = StateNotifierProvider<UnreadCountNotifier, AsyncValue<int>>(
  (ref) => UnreadCountNotifier(ref.watch(getUnreadCountUsecaseProvider)),
);

class UnreadCountNotifier extends StateNotifier<AsyncValue<int>> {
  final GetUnreadCountUsecase _getUnreadCountUsecase;
  
  UnreadCountNotifier(this._getUnreadCountUsecase) : super(const AsyncValue.loading()) {
    loadUnreadCount();
  }
  
  Future<void> loadUnreadCount() async {
    try {
      state = const AsyncValue.loading();
      final count = await _getUnreadCountUsecase.getUnreadFootprintCount();
      state = AsyncValue.data(count);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  // 既読にしたときにカウントをリセットする
  void resetCount() {
    if (state.hasValue) {
      state = const AsyncValue.data(0);
    }
  }
  
  // 新しい足あとがついたときにカウントを増やす
  void incrementCount() {
    if (state.hasValue) {
      final currentCount = state.value ?? 0;
      state = AsyncValue.data(currentCount + 1);
    }
  }
}