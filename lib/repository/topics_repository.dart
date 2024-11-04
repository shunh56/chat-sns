import 'package:app/datasource/topics_datasource.dart';
import 'package:app/presentation/pages/community_screen/model/topic.dart';
import 'package:app/presentation/pages/community_screen/provider/states/topic_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final topicsRepositoryProvider = Provider(
  (ref) => TopicsRepository(ref.watch(topicsDatasourceProvider)),
);

class TopicsRepository {
  final TopicsDatasource _datasource;
  TopicsRepository(this._datasource);

  Future<List<Topic>> getRecentTopics() async {
    final res = await _datasource.getRecentTopics();
    return res.docs.map((doc) => Topic.fromJson(doc.data())).toList();
  }

  Future<List<Topic>> getTopicsFromCommunity(String communityId) async {
    final res = await _datasource.getTopicsFromCommunity(communityId);
    return res.docs.map((doc) => Topic.fromJson(doc.data())).toList();
  }

  createTopic(TopicState state) {
    return _datasource.createTopic(state.toJson());
  }
}
