import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final removeFootprintUsecaseProvider = Provider(
  (ref) => RemoveFootprintUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class RemoveFootprintUsecase {
  final FootprintRepository _repository;

  RemoveFootprintUsecase(this._repository);

  // 特定のユーザーの足あとを削除する
  Future<void> deleteFootprint(String userId) {
    return _repository.deleteFootprint(userId);
  }
}
