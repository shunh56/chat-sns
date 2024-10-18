import 'package:algolia/algolia.dart';
import 'package:app/presentation/providers/provider/firebase/algolia.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const hitsPerPage = 30;

final algoliaPostDatasourceProvider = Provider(
  (ref) => AlgoliaPostDatasource(
    ref.watch(algoliaProvider),
  ),
);

class AlgoliaPostDatasource {
  final Algolia _algolia;
  AlgoliaPostDatasource(this._algolia);

  Future<List<AlgoliaObjectSnapshot>> fetchFriendsPosts(
      List<String> followingUserIds,
      {int page = 0}) async {
    AlgoliaQuery query = _algolia.instance
        .index('fetch_friends_posts')
        .setHitsPerPage(hitsPerPage)
        .setPage(page);
    if (followingUserIds.isEmpty) return [];
    List<String> filters = followingUserIds.map((id) => 'userId:$id').toList();
    String filterString = filters.join(' OR ');
    query = query.setFilters(filterString);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    return querySnap.hits;
  }
}
