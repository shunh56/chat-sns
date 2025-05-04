import 'package:app/domain/entity/footprint.dart';
import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final footprintUsecaseProvider = Provider(
  (ref) => FootprintUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class FootprintUsecase {
  final FootprintRepository _repository;

  FootprintUsecase(this._repository);

  Future<List<Footprint>> getFootprints() async {
    return await _repository.getFootprints();
  }

  Future<List<Footprint>> getFootprinteds() async {
    return await _repository.getFootprinteds();
  }

  addFootprint(String userId) {
    return _repository.addFootprint(userId);
  }

  deleteFootprint(String userId) {
    return _repository.deleteFootprint(userId);
  }
}
