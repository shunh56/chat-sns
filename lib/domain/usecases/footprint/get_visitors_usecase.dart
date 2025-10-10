import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/domain/repository/footprint_repository_interface.dart';
import 'package:app/data/repository/footprint_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getVisitorsUsecaseProvider = Provider(
  (ref) => GetVisitorsUsecase(
    ref.watch(footprintRepositoryImplProvider),
  ),
);

class GetVisitorsUsecase {
  final IFootprintRepository _repository;

  GetVisitorsUsecase(this._repository);

  // 自分のプロフィールを訪問したユーザー一覧を取得
  Stream<List<Footprint>> getProfileVisitors() {
    return _repository.getVisitorsStream();
  }
}
