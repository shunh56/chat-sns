import 'package:app/domain/entity/user.dart';
import 'package:app/domain/repository/footprint_repository_interface.dart';
import 'package:app/data/repository/footprint_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final visitProfileUsecaseProvider = Provider(
  (ref) => VisitProfileUsecase(
    ref.watch(footprintRepositoryImplProvider),
  ),
);

class VisitProfileUsecase {
  final IFootprintRepository _repository;

  VisitProfileUsecase(this._repository);

  // ユーザーのプロフィールを訪問する際に足あとを残す
  Future<void> leaveFootprint(UserAccount user) async {
    return _repository.visitProfile(user.userId);
  }
}
