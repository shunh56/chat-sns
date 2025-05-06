import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final markFootprintsSeenUsecaseProvider = Provider(
  (ref) => MarkFootprintsSeenUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class MarkFootprintsSeenUsecase {
  final FootprintRepository _repository;

  MarkFootprintsSeenUsecase(this._repository);

  // 足あとを既読にする
  Future<void> markAllFootprintsSeen() async {
    return _repository.markFootprintsSeen();
  }
}