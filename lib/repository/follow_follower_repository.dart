import 'package:app/datasource/follow_folllower_datasource.dart';
import 'package:app/domain/entity/relation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ffRepositoryProvider = Provider(
  (ref) => FFRepository(
    ref.watch(ffDatasourceProvider),
  ),
);

class FFRepository {
  final FFDatasource _datasource;

  FFRepository(this._datasource);

  Future<List<Relation>> getFollowings({String? userId}) async {
    final result = await _datasource.getFollowings(userId: userId);

    if (result == null || !result.containsKey('data')) {
      return [];
    }

    final data = List<Map<String, dynamic>>.from(result['data']);
    return data.map((item) => Relation.fromJson(item)).toList();
  }

  Future<List<Relation>> getFollowers({String? userId}) async {
    final result = await _datasource.getFollowers(userId: userId);

    if (result == null || !result.containsKey('data')) {
      return [];
    }

    final data = List<Map<String, dynamic>>.from(result['data']);
    return data.map((item) => Relation.fromJson(item)).toList();
  }

  followUser(String userId) {
    return _datasource.followUser(userId);
  }

  unfollowUser(String userId) {
    return _datasource.unfollowUser(userId);
  }
}
