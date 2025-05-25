/*import 'package:app/data/datasource/post/blog_datasource.dart';
import 'package:app/domain/entity/posts/UNUSED/blog.dart';
import 'package:app/presentation/providers/state/create_post/blog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blogRepositoryProvider = Provider(
  (ref) => BlogRepository(
    ref.read(blogDatasourceProvider),
  ),
);

class BlogRepository {
  final BlogDatasource _datasource;
  BlogRepository(this._datasource);

  Future<List<Blog>> getPosts() async {
    final query = await _datasource.getPosts();
    return query.docs.map((e) => Blog.fromJson(e.data())).toList();
  }

  Future<List<Blog>> getPopularPosts() async {
    final query = await _datasource.fetchPopularPosts();
    return query.docs.map((e) => Blog.fromJson(e.data())).toList();
  }

  Future<List<Blog>> getPostFromUserId(String userId) async {
    final query = await _datasource.getPostFromUserId(userId);
    return query.docs.map((e) => Blog.fromJson(e.data())).toList();
  }

  uploadPost(BlogState state) {
    final title = state.title;
    final contents = state.contents;
    return _datasource.uploadPost(title, contents);
  }
}
 */