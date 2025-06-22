import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/push_notification_usecase.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
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

  Future<List<Post>> getPostsFromUserIds(List<String> userIds,
      {bool onlyPublic = false}) async {
    final posts =
        await ref.read(postUsecaseProvider).getPostFromUserIds(userIds);
    addPosts(posts);
    return posts;
  }

  Future<List<Post>> getPostsFromUserId(String userId) async {
    final posts = await ref.read(postUsecaseProvider).getPostFromUserId(userId);
    addPosts(posts);
    return posts;
  }

  Future<List<Post>> getImagePostsFromUserId(String userId) async {
    final posts =
        await ref.read(postUsecaseProvider).getImagePostFromUserId(userId);
    addPosts(posts);
    return posts;
  }

  incrementLikeCount(UserAccount user, Post post) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    cache[post.id]!.likeCount += 1;
    state = AsyncValue.data(cache);
    ref.read(postUsecaseProvider).incrementLikeCount(post.id, 1);
  }

  addReply(UserAccount user, Post post, String text) {
    Map<String, Post> cache = state.asData != null ? state.asData!.value : {};
    cache[post.id]!.replyCount += 1;
    state = AsyncValue.data(cache);
    ref.read(postUsecaseProvider).addReply(post.id, text);
    if (user.userId != ref.read(authProvider).currentUser!.uid) {
      ref.read(activitiesUsecaseProvider).addCommentToPost(user, post);
      ref.read(pushNotificationUsecaseProvider).sendPostComment(user);
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

  Future<void> addReaction(
      UserAccount user, String postId, String reactionType) async {
    //final String userId = user.userId;
    final myId = ref.read(authProvider).currentUser!.uid;
    try {
      ref.read(pushNotificationUsecaseProvider).sendPostReaction(user);
      await ref.read(postUsecaseProvider).addReaction(postId, reactionType);
      if (user.userId != myId) {
        ref.read(activitiesUsecaseProvider).addReactionToPost(user, postId);
      }
      // ローカル状態も更新
      final cache = state.asData?.value ?? {};
      if (cache.containsKey(postId)) {
        final updatedPost = cache[postId]!.addReaction(myId, reactionType);
        cache[postId] = updatedPost;
        state = AsyncValue.data(cache);
      }
      DebugPrint(
          "state :  ${cache[postId]?.reactions.map((k, v) => MapEntry(k, v.userIds))}");
    } catch (e) {
      // エラーハンドリング
      print('Failed to add reaction: $e');
    }
  }

  Future<void> removeReaction(
      String postId, String userId, String reactionType) async {
    try {
      await ref
          .read(postUsecaseProvider)
          .removeReaction(postId, userId, reactionType);

      // ローカル状態も更新
      final cache = state.asData?.value ?? {};
      if (cache.containsKey(postId)) {
        final updatedPost = cache[postId]!.removeReaction(userId, reactionType);
        cache[postId] = updatedPost;
        state = AsyncValue.data(cache);
      }
    } catch (e) {
      // エラーハンドリング
      print('Failed to remove reaction: $e');
    }
  }

  Future<void> toggleReaction(
      String postId, String userId, String reactionType) async {
    try {
      await ref
          .read(postUsecaseProvider)
          .toggleReaction(postId, userId, reactionType);

      // 投稿データを再取得して状態を更新
      // または楽観的更新を実装
    } catch (e) {
      // エラーハンドリング
      print('Failed to toggle reaction: $e');
    }
  }
}
