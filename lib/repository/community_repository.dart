import 'package:app/datasource/comunity_datasouce.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final communityRepositoryProvider = Provider(
  (ref) => CommunityRepository(
    ref.watch(communityDatasourceProvider),
  ),
);

class CommunityRepository {
  final CommunityDatasource _datasource;
  CommunityRepository(this._datasource);

  Future<Community?> getCommunityFromId(String communityId) async {
    final res = await _datasource.getCommunityFromId(communityId);
    if (!res.exists) return null;
    return Community.fromJson(res.data()!);
  }

  createCommunity(Map<String, dynamic> json) {
    return _datasource.createCommunity(json);
  }

  Future<List<String>> getRecentUsers(String communityId) async {
    final res = await _datasource.getRecentUsers(communityId);
    return res.docs.map((doc) => doc.id).toList();
  }
}
