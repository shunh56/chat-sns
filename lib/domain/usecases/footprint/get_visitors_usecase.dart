import 'package:app/domain/entity/footprint.dart';
import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getVisitorsUsecaseProvider = Provider(
  (ref) => GetVisitorsUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class GetVisitorsUsecase {
  final FootprintRepository _repository;

  GetVisitorsUsecase(this._repository);

  // 自分のプロフィールを訪問したユーザー一覧を取得
  Future<List<Footprint>> getProfileVisitors() async {
    return await _repository.getFootprinteds();
  }
}