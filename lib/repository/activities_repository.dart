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

  Future<List<Activity>> getRecentActivities() async {
    final res = await _datasource.getRecentActivities();
    return res.docs.map((doc) => Activity.fromJson(doc.data())).toList();
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
