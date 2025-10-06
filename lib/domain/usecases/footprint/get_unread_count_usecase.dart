import 'package:app/domain/repository/footprint_repository_interface.dart';
import 'package:app/data/repository/footprint_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getUnreadCountUsecaseProvider = Provider(
  (ref) => GetUnreadCountUsecase(
    ref.watch(footprintRepositoryImplProvider),
  ),
);

class GetUnreadCountUsecase {
  final IFootprintRepository _repository;

  GetUnreadCountUsecase(this._repository);

  // 未読の足あと数を取得
  Future<int> getUnreadFootprintCount() {
    return _repository.getRecentUnseenCount();
  }
}
