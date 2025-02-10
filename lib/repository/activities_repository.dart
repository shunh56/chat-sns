import 'package:app/datasource/activities_datasource.dart';
import 'package:app/domain/entity/activities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activitiesRepositoryProvider = Provider(
  (ref) => ActivitiesRepository(
    ref.watch(activitiesDatasourceProvider),
  ),
);

class ActivitiesRepository {
  final ActivitiesDatasource _datasource;
  ActivitiesRepository(this._datasource);

  Stream<List<Activity>> streamActivity() {
    final res = _datasource.streamActivity();
    return res.map((stream) =>
        stream.docs.map((doc) => Activity.fromJson(doc.data())).toList());
  }

  Future<List<Activity>> getRecentActivities() async {
    final res = await _datasource.getRecentActivities();
    return res.docs.map((doc) => Activity.fromJson(doc.data())).toList();
  }

  Future<void> readActitivies() async {
    return _datasource.readActivities();
  }

  addLikeToPost(String userId, String postId) async {
    return _datasource.addLikeToPost(userId, postId);
  }

  addCommentToPost(String userId, String postId) async {
    return _datasource.addCommentToPost(userId, postId);
  }

  addLikeToCurrentStatusPost(String userId, String postId) async {
    return _datasource.addLikeToCurrentStatusPost(userId, postId);
  }
}
