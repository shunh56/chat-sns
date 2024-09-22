import 'package:app/domain/entity/message_overview.dart';
import 'package:app/repository/direct_message_overview_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dmOverviewUsecaseProvider = Provider(
  (ref) => DirectMessageOverviewUsecase(
    ref.watch(dmOverviewRepositoryProvider),
  ),
);

class DirectMessageOverviewUsecase {
  final DirectMessageOverviewRepository _repository;
  DirectMessageOverviewUsecase(this._repository);

  Stream<List<DMOverview>> streamDMOverviews() {
    return _repository.streamDMOverviews();
  }

  leaveChat(String userId) {
    return _repository.leaveChat(userId);
  }

  joinChat(String userId){
    return _repository.joinChat(userId);
  }
}
