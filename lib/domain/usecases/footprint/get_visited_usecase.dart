import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/domain/repository/footprint_repository_interface.dart';
import 'package:app/data/repository/footprint_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getVisitedUsecaseProvider = Provider(
  (ref) => GetVisitedUsecase(
    ref.watch(footprintRepositoryImplProvider),
  ),
);

class GetVisitedUsecase {
  final IFootprintRepository _repository;

  GetVisitedUsecase(this._repository);

  // 自分が訪問したユーザー一覧を取得
  Stream<List<Footprint>> getVisitedProfiles() {
    return _repository.getVisitedStream();
  }
}
