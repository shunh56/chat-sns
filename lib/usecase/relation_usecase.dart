
import 'package:app/repository/relation_repostiory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final relationUsecaseProvider = Provider(
  (ref) => RelationUsecase(
    ref.watch(relationRepositoryProvider),
  ),
);

class RelationUsecase {
  final RelationRepository _repository;
  RelationUsecase(this._repository);

  sendRequest(String userId) {
    return _repository.sendRequest(userId);
  }

  admitRequested(String userId) {
    return _repository.admitRequested(userId);
  }

  deleteRequest(String userId) {
    return _repository.deleteRequest(userId);
  }

  deleteRequested(String userId) {
    return _repository.deleteRequested(userId);
  }
}
