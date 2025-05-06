import 'package:app/domain/usecases/footprint/mark_footprints_seen_usecase.dart';
import 'package:app/presentation/providers/footprint/unread_count_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 足あとを既読にする操作のプロバイダ
final markFootprintsSeenProvider = Provider(
  (ref) => MarkSeenProvider(
    ref.watch(markFootprintsSeenUsecaseProvider),
    ref,
  ),
);

class MarkSeenProvider {
  final MarkFootprintsSeenUsecase _markFootprintsSeenUsecase;
  final Ref _ref;
  
  MarkSeenProvider(this._markFootprintsSeenUsecase, this._ref);
  
  Future<void> markAllSeen() async {
    await _markFootprintsSeenUsecase.markAllFootprintsSeen();
    
    // 未読カウントをリセット
    _ref.read(unreadFootprintCountProvider.notifier).resetCount();
  }
}