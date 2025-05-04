import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/notifier/push_notification_notifier.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';
import 'package:app/domain/usecases/activities_usecase.dart';
import 'package:app/domain/usecases/posts/post_usecase.dart';
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

  incrementLikeCount(UserAccount user, Post post) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    cache[post.id]!.likeCount += 1;
    state = AsyncValue.data(cache);
    ref.read(postUsecaseProvider).incrementLikeCount(post.id, 1);
    if (user.userId != ref.read(authProvider).currentUser!.uid) {
      ref.read(activitiesUsecaseProvider).addLikeToPost(user, post);
      ref
          .read(pushNotificationNotifierProvider)
          .sendPostReaction(user, "postLike");
    }
  }

  addReply(UserAccount user, Post post, String text) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    cache[post.id]!.replyCount += 1;
    state = AsyncValue.data(cache);
    ref.read(postUsecaseProvider).addReply(post.id, text);
    if (user.userId != ref.read(authProvider).currentUser!.uid) {
      ref.read(activitiesUsecaseProvider).addCommentToPost(user, post);
      ref
          .read(pushNotificationNotifierProvider)
          .sendPostReaction(user, "postComment");
    }
  }

  createPost(PostState postState) {
    ref.read(postUsecaseProvider).uploadPost(postState);
    //ref.read(pushNotificationNotifierProvider).uploadPost();
  }

  deletePostByUser(Post post) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    post.isDeletedByUser = true;
    cache[post.id] = post;
    state = AsyncValue.data(cache);
    ref.read(postUsecaseProvider).deletePostByUser(post);
  }

  deletePostByModerator(Post post) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    post.isDeletedByModerator = true;
    cache[post.id] = post;
    state = AsyncValue.data(cache);
    ref.read(postUsecaseProvider).deletePostByModerator(post);
  }

  deletePostByAdmin(Post post) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    post.isDeletedByAdmin = true;
    cache[post.id] = post;
    state = AsyncValue.data(cache);
    ref.read(postUsecaseProvider).deletePostByAdmin(post);
  }
}
