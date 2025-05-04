import 'package:app/presentation/UNUSED/community_screen/model/topic.dart';
import 'package:app/presentation/UNUSED/community_screen/provider/states/topic_state.dart';
import 'package:app/data/repository/topics_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final topicsUsecaseProvider = Provider(
  (ref) => TopicsUsecase(
    ref.watch(topicsRepositoryProvider),
  ),
);

class TopicsUsecase {
  final TopicsRepository _repository;
  TopicsUsecase(this._repository);

  Future<List<Topic>> getPopularTopics() {
    return _repository.getPopularTopics();
  }

  Future<List<Topic>> getTopicsFromCommunity(String communityId) {
    return _repository.getTopicsFromCommunity(communityId);
  }

  createTopic(TopicState state) {
    return _repository.createTopic(state);
  }

  sendMessage(String topicId,String text){
    return _repository.sendMessage(topicId,text);
  }
}
