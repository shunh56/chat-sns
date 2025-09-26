import 'package:app/domain/entity/footprint.dart';
import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final streamVisitorsUsecaseProvider = Provider(
  (ref) => StreamVisitorsUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class StreamVisitorsUsecase {
  final FootprintRepository _repository;

  StreamVisitorsUsecase(this._repository);

  // 自分を訪問したユーザー一覧をリアルタイムで監視
  Stream<List<Footprint>> streamProfileVisitors() {
    return _repository.streamFootprinteds();
  }
}
