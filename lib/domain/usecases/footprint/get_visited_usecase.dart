import 'package:app/domain/entity/footprint.dart';
import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getVisitedUsecaseProvider = Provider(
  (ref) => GetVisitedUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class GetVisitedUsecase {
  final FootprintRepository _repository;

  GetVisitedUsecase(this._repository);

  // 自分が訪問したユーザー一覧を取得
  Future<List<Footprint>> getVisitedProfiles() async {
    return await _repository.getFootprints();
  }
}