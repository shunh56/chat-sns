import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/usecase/posts/current_status_post_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_current_status_posts.g.dart';

// 友達リクエストしたユーザーなどを含む、関係するユーザーの全てのUserModelのリスト
@Riverpod(keepAlive: true)
class AllCurrentStatusPostsNotifier extends _$AllCurrentStatusPostsNotifier {
  @override
  AsyncValue<Map<String, CurrentStatusPost>> build() {
    Map<String, CurrentStatusPost> allCurrentStatusPosts = {};
    return AsyncValue.data(allCurrentStatusPosts);
  }

  Future<List<CurrentStatusPost>> getUsersPosts(String userId) async {
    Map<String, CurrentStatusPost> cache =
        state.asData != null ? state.asData!.value : {};
    List<CurrentStatusPost> list = cache.entries
        .where((item) => item.value.userId == userId)
        .map((item) => item.value)
        .toList();
    if (list.length < 10) {
      final posts = await ref
          .read(currentStatusPostUsecaseProvider)
          .getUsersPosts(userId);
      for (var post in posts) {
        cache[post.id] = post;
      }
      state = AsyncValue.data(cache);
      return posts;
    } else {
      return list;
    }
  }

  void addPosts(List<CurrentStatusPost> currentStatusPosts) {
    Map<String, CurrentStatusPost> cache =
        state.asData != null ? state.asData!.value : {};
    for (var post in currentStatusPosts) {
      cache[post.id] = post;
    }
    state = AsyncValue.data(cache);
  }

  incrementLikeCount(UserAccount user, CurrentStatusPost post) {
    /* Map<String, CurrentStatusPost> cache =
        state.asData != null ? state.asData!.value : {};
    cache[post.id]!.likeCount += 1;
    state = AsyncValue.data(cache);
    ref.read(currentStatusPostUsecaseProvider).incrementLikeCount(post.id, 1);
    if (user.userId != ref.read(authProvider).currentUser!.uid) {
      ref
          .read(activitiesUsecaseProvider)
          .addLikeToCurrentStatusPost(user, post);
      ref
          .read(pushNotificationNotifierProvider)
          .sendCurrentStatusPostReaction(user, "currentStatusPostLike");
    } */
  }

  getPosts(List<String> ids) async {
    Map<String, CurrentStatusPost> cache =
        state.asData != null ? state.asData!.value : {};
    List<Future<CurrentStatusPost>> futures = [];
    for (String id in ids) {
      if (cache[id] == null) {
        futures.add(ref.read(currentStatusPostUsecaseProvider).getPost(id));
      }
    }
    await Future.wait(futures);
    for (String id in ids) {
      cache[id] ??= await futures[ids.indexOf(id)];
    }
    state = AsyncValue.data(cache);
  }

  readPost(String userId) {
    DebugPrint("READING USERS POSTS!");
    Map<String, CurrentStatusPost> cache =
        state.asData != null ? state.asData!.value : {};
    List<CurrentStatusPost> posts =
        cache.values.where((post) => post.userId == userId).toList();
    for (var post in posts) {
      final users = cache[post.id]!.seenUserIds.toSet();
      users.add(ref.read(authProvider).currentUser!.uid);
      cache[post.id]!.seenUserIds = users.toList();
      ref.read(currentStatusPostUsecaseProvider).readPost(post);
    }
    state = AsyncValue.data(cache);
  }

  /* addReply(CurrentStatusPost post, String text) {
    Map<String, CurrentStatusPost> cache =
        state.asData != null ? state.asData!.value : {};
    cache[post.id]!.replyCount += 1;
    state = AsyncValue.data(cache);
    return ref.read(currentStatusPostUsecaseProvider).addReply(post.id, text);
  } */
}
