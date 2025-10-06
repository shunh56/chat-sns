import 'package:app/domain/repository/footprint_repository_interface.dart';
import 'package:app/data/repository/footprint_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final markFootprintsSeenUsecaseProvider = Provider(
  (ref) => MarkFootprintsSeenUsecase(
    ref.watch(footprintRepositoryImplProvider),
  ),
);

class MarkFootprintsSeenUsecase {
  final IFootprintRepository _repository;

  MarkFootprintsSeenUsecase(this._repository);

  // 足あとを既読にする
  Future<void> markAllFootprintsSeen() async {
    return _repository.markAllFootprintsSeen();
  }
}
