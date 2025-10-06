import 'package:app/domain/repository/footprint_repository_interface.dart';
import 'package:app/data/repository/footprint_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final removeFootprintUsecaseProvider = Provider(
  (ref) => RemoveFootprintUsecase(
    ref.watch(footprintRepositoryImplProvider),
  ),
);

class RemoveFootprintUsecase {
  final IFootprintRepository _repository;

  RemoveFootprintUsecase(this._repository);

  // 特定のユーザーの足あとを削除する
  Future<void> deleteFootprint(String userId) {
    return _repository.removeFootprint(userId);
  }
}
