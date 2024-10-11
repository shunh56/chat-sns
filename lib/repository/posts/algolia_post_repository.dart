import 'package:app/core/utils/debug_print.dart';
import 'package:app/datasource/post/algolia_post_datasource.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final algoliaPostRepositoryProvider = Provider(
  (ref) => AlgoliaPostRepository(
    ref.watch(algoliaPostDatasourceProvider),
  ),
);

class AlgoliaPostRepository {
  final AlgoliaPostDatasource _datasource;
  AlgoliaPostRepository(this._datasource);

  Future<List<Post>> getUserIdsPosts(List<String> friendIds,{int page = 0}) async {
    final res = await _datasource.fetchFriendsPosts(friendIds,page: page);
    DebugPrint("algolia friends posts query length : ${res.length}");
    return res.map((e) => Post.fromAlgoliaJson(e.data)).toList();
  }
}
