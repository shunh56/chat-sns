/*import 'package:app/domain/entity/posts/post.dart';
import 'package:app/data/repository/posts/UNUSED/algolia_post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final algoliaPostUsecaseProvider = Provider(
  (ref) => AlgoliaPostUsecase(
    ref.watch(algoliaPostRepositoryProvider),
  ),
);

class AlgoliaPostUsecase {
  final AlgoliaPostRepository _repository;
  AlgoliaPostUsecase(this._repository);

  Future<List<Post>> getUserIdsPosts(List<String> friendIds,{int page = 0}) async {
    return _repository.getUserIdsPosts(friendIds,page:page);
  }
}
 */
