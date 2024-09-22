/*// Package imports:
import 'package:app/datasource/follow_folllower_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:

final ffRepositoryProvider = Provider(
  (ref) => FFRepository(
    ref,
    ref.watch(ffDatasourceProvider),
  ),
);

class FFRepository {
  final Ref ref;
  final FFDatasource _ffDatasource;

  FFRepository(this.ref, this._ffDatasource);

  Future<void> followUser(String userId) async {
    return await _ffDatasource.followUser(userId);
  }

  Future<void> unfollowUser(String userId) async {
    return await _ffDatasource.unfollowUser(userId);
  }

  Future<List<String>> getFollowers({String? userId}) async {
    final res = await _ffDatasource.getFollowers(userId: userId);
    return res.docs.map((e) => e.id).toList();
  }

  Future<List<String>> getFollowings({String? userId}) async {
    final res = await _ffDatasource.getFollowings(userId: userId);
    return res.docs.map((e) => e.id).toList();
  }

  Stream<List<String>> streamFollowers() {
    final res = _ffDatasource.streamFollowers();

    return res.map((event) => event.docs.map((e) => e.id).toList());
  }
}
 */