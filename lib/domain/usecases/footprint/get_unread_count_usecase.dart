import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getUnreadCountUsecaseProvider = Provider(
  (ref) => GetUnreadCountUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class GetUnreadCountUsecase {
  final FootprintRepository _repository;

  GetUnreadCountUsecase(this._repository);

  // 未読の足あと数を取得
  Future<int> getUnreadFootprintCount() {
    return _repository.getUnreadFootprintCount();
  }
}