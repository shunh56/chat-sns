import 'package:app/presentation/pages/community_screen/model/topic.dart';
import 'package:app/presentation/pages/community_screen/provider/states/topic_state.dart';
import 'package:app/repository/topics_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final topicsUsecaseProvider = Provider(
  (ref) => TopicsUsecase(
    ref.watch(topicsRepositoryProvider),
  ),
);

class TopicsUsecase {
  final TopicsRepository _repository;
  TopicsUsecase(this._repository);

  Future<List<Topic>> getRecentTopics() {
    return _repository.getRecentTopics();
  }

  Future<List<Topic>> getTopicsFromCommunity(String communityId) {
    return _repository.getTopicsFromCommunity(communityId);
  }

  createTopic(TopicState state) {
    return _repository.createTopic(state);
  }
}
