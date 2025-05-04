import 'package:app/data/datasource/topics_datasource.dart';
import 'package:app/presentation/UNUSED/community_screen/model/topic.dart';
import 'package:app/presentation/UNUSED/community_screen/provider/states/topic_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final topicsRepositoryProvider = Provider(
  (ref) => TopicsRepository(ref.watch(topicsDatasourceProvider)),
);

class TopicsRepository {
  final TopicsDatasource _datasource;
  TopicsRepository(this._datasource);

  Future<List<Topic>> getPopularTopics() async {
    final res = await _datasource.getPopularTopics();
    return res.docs.map((doc) => Topic.fromJson(doc.data())).toList();
  }

  Future<List<Topic>> getTopicsFromCommunity(String communityId) async {
    final res = await _datasource.getTopicsFromCommunity(communityId);
    return res.docs.map((doc) => Topic.fromJson(doc.data())).toList();
  }

  createTopic(TopicState state) {
    return _datasource.createTopic(state.toJson());
  }

  sendMessage(String topicId, String text) {
    return _datasource.sendMessage(topicId, text);
  }
}
