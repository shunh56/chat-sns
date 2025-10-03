/*import 'package:app/domain/entity/posts/UNUSED/blog.dart';
import 'package:app/presentation/providers/state/create_post/blog.dart';
import 'package:app/data/repository/posts/UNUSED/blog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blogUsecaseProvider = Provider(
  (ref) => BlogUsecase(
    ref.read(blogRepositoryProvider),
  ),
);

class BlogUsecase {
  final BlogRepository _repository;
  BlogUsecase(this._repository);

  Future<List<Blog>> getPosts() async {
    return await _repository.getPosts();
  }

  Future<List<Blog>> getPopularPosts() async {
    return await _repository.getPopularPosts();
  }

  Future<List<Blog>> getPostFromUserId(String userId) async {
    return await _repository.getPostFromUserId(userId);
  }

  uploadPost(BlogState state) {
    return _repository.uploadPost(state);
  }
}
 */
