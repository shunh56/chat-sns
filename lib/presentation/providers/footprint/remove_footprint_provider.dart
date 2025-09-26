import 'package:app/domain/usecases/footprint/remove_footprint_usecase.dart';
import 'package:app/presentation/providers/footprint/visitors_provider.dart';
import 'package:app/presentation/providers/footprint/visited_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 足あとを削除する操作のプロバイダ
final removeFootprintProvider = Provider(
  (ref) => RemoveFootprintProvider(
    ref.watch(removeFootprintUsecaseProvider),
    ref,
  ),
);

class RemoveFootprintProvider {
  final RemoveFootprintUsecase _removeFootprintUsecase;
  final Ref _ref;

  RemoveFootprintProvider(this._removeFootprintUsecase, this._ref);

  Future<void> removeFootprint(String userId) async {
    await _removeFootprintUsecase.deleteFootprint(userId);

    // 関連するプロバイダを更新
    _ref.invalidate(visitorsProvider);
    _ref.invalidate(visitedProvider);
  }
}
