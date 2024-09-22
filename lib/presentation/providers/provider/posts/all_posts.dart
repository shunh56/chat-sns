import 'package:app/domain/entity/posts/post.dart';
import 'package:app/usecase/posts/post_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_posts.g.dart';

// 友達リクエストしたユーザーなどを含む、関係するユーザーの全てのUserModelのリスト
@Riverpod(keepAlive: true)
class AllPostsNotifier extends _$AllPostsNotifier {
  @override
  AsyncValue<Map<String, Post>> build() {
    Map<String, Post> allPosts = {};
    return AsyncValue.data(allPosts);
  }

/*  Future<List<Post>> getPosts(List<String> postIds) async {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    List<Post> list = [];
    List<Future<Post?>> futures = [];
    for (String id in postIds) {
      if (cache[id] != null) {
        futures.add(Future.value(cache[id]));
      } else {
        futures.add(ref.read(postUsecaseProvider).getPostById(id));
      }
    }
    await Future.wait(futures);
    for (var item in futures) {
      final user = (await item)!;
      cache[user.userId] = user;
      list.add(user);
    }
    state = AsyncValue.data(cache);
    return list;
  } */

  void addPosts(List<Post> posts) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    for (var post in posts) {
      cache[post.id] = post;
    }
    state = AsyncValue.data(cache);
  }

  incrementLikeCount(Post post) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};

    cache[post.id]!.likeCount += 1;
    state = AsyncValue.data(cache);

    ref.read(postUsecaseProvider).incrementLikeCount(post.id, 1);
  }

  addReply(Post post, String text) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    cache[post.id]!.replyCount += 1;
    state = AsyncValue.data(cache);
    return ref.read(postUsecaseProvider).addReply(post.id, text);
  }
}
