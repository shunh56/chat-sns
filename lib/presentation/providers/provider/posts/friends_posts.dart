// Flutter imports:

// Package imports:
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/posts/timeline_post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/usecase/posts/current_status_post_usecase.dart';
import 'package:app/usecase/posts/post_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsPostsNotiferProvider = StateNotifierProvider.autoDispose<
    FriendsPostsNotifier, AsyncValue<List<PostBase>>>((ref) {
  return FriendsPostsNotifier(
    ref,
    ref.watch(friendIdListNotifierProvider),
    ref.watch(postUsecaseProvider),
    ref.watch(currentStatusPostUsecaseProvider),
  )..initialize();
});

/// State
class FriendsPostsNotifier extends StateNotifier<AsyncValue<List<PostBase>>> {
  FriendsPostsNotifier(
    this.ref,
    this.asyncValue,
    this.postUsecase,
    this.currentStatusPostUsecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final AsyncValue<List<FriendInfo>> asyncValue;
  final PostUsecase postUsecase;
  final CurrentStatusPostUsecase currentStatusPostUsecase;

  //TODO フレンドが変更されるたびに全てのPostを取得し直している
  // blockしたらすぐに反映されているから悪くはないが、グリッチしてしまう。
  Future<void> initialize() async {
    List<PostBase> posts = [];

    asyncValue.maybeWhen(
      data: (infos) async {
        List<Future<List<PostBase>>> futures = [];
        futures.add(getMyPosts());
        futures.add(getMyCurrentStatusPosts());
        for (String userId in infos.map((item) => item.userId)) {
          futures.add(postUsecase.getPostFromUserId(userId));
          futures.add(currentStatusPostUsecase.getUsersPosts(userId));
        }
        await Future.wait(futures);
        for (var item in futures) {
          final list = await item;
          if (list.runtimeType == List<Post>) {
            ref
                .read(allPostsNotifierProvider.notifier)
                .addPosts(list as List<Post>);
          } else {
            ref
                .read(allCurrentStatusPostsNotifierProvider.notifier)
                .addPosts(list as List<CurrentStatusPost>);
          }
          posts.addAll(list);
        }
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (mounted) {
          state = AsyncValue.data(posts);
        }
      },
      orElse: () {},
    );
  }

  Future<void> refresh() async {
    List<PostBase> posts = [];
    final friendIds =
        ref.read(friendIdListNotifierProvider).asData?.value ?? [];
    List<Future<List<PostBase>>> futures = [];
    futures.add(getMyPosts());
    futures.add(getMyCurrentStatusPosts());
    for (String userId in friendIds.map((item) => item.userId)) {
      futures.add(postUsecase.getPostFromUserId(userId));
      futures.add(currentStatusPostUsecase.getUsersPosts(userId));
    }
    await Future.wait(futures);
    for (var item in futures) {
      final list = await item;
      if (list.runtimeType == List<Post>) {
        ref
            .read(allPostsNotifierProvider.notifier)
            .addPosts(list as List<Post>);
      } else {
        ref
            .read(allCurrentStatusPostsNotifierProvider.notifier)
            .addPosts(list as List<CurrentStatusPost>);
      }
      posts.addAll(list);
    }
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) {
      state = AsyncValue.data(posts);
    }
  }

  Future<List<PostBase>> getMyPosts() async {
    final myId = ref.read(authProvider).currentUser!.uid;

    return postUsecase.getPostFromUserId(myId);
  }

  Future<List<PostBase>> getMyCurrentStatusPosts() async {
    final myId = ref.read(authProvider).currentUser!.uid;
    return currentStatusPostUsecase.getUsersPosts(myId);
  }
}

/*final friendsCurrentStatusPostsNotiferProvider =
    StateNotifierProvider.autoDispose<FriendsCurrentStatusPostsNotifier,
        AsyncValue<List<CurrentStatusPost>>>((ref) {
  return FriendsCurrentStatusPostsNotifier(
    ref,
    ref.watch(currentStatusPostUsecaseProvider),
  )..initialize();
});

/// State
class FriendsCurrentStatusPostsNotifier
    extends StateNotifier<AsyncValue<List<CurrentStatusPost>>> {
  FriendsCurrentStatusPostsNotifier(
    this.ref,
    this.usecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final CurrentStatusPostUsecase usecase;
  bool initialized = false;

  Future<void> initialize() async {
    List<CurrentStatusPost> posts = [];
    while (!initialized) {
      final friendIds = ref.read(friendIdListNotifierProvider);
      if (friendIds.hasValue) {
        List<Future<List<CurrentStatusPost>>> futures = [];
        for (String userId in friendIds.asData!.value) {
          futures.add(usecase.getUsersNewestPost(userId));
        }
        await Future.wait(futures);
        for (var future in futures) {
          posts.addAll(await future);
        }
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        DebugPrint("posts : ${posts.length}");
        if (mounted) {
          state = AsyncValue.data(posts);
        }
        initialized = true;
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
}
 */
final friendFriendsPostsNotiferProvider = StateNotifierProvider.autoDispose<
    FriendFriendsPostsNotifier, AsyncValue<List<Post>>>((ref) {
  return FriendFriendsPostsNotifier(
    ref,
    ref.watch(friendsFriendListNotifierProvider),
    ref.watch(postUsecaseProvider),
  )..initialize();
});

class FriendFriendsPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  FriendFriendsPostsNotifier(
    this.ref,
    this.asyncValue,
    this.usecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final AsyncValue<List<UserAccount>> asyncValue;
  final PostUsecase usecase;

  Future<void> initialize() async {
    List<Post> posts = [];
    asyncValue.maybeWhen(
      data: (users) async {
        users.removeWhere((user) =>
            (user.privacy.contentRange == PublicityRange.onlyFriends));
        List<Future<List<Post>>> futures = [];
        for (String userId in users.map((user) => user.userId)) {
          futures.add(usecase.getPostFromUserId(userId));
        }
        await Future.wait(futures);
        for (var future in futures) {
          posts.addAll(await future);
        }
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        ref.read(allPostsNotifierProvider.notifier).addPosts(posts);
        if (mounted) {
          state = AsyncValue.data(posts);
        }
      },
      orElse: () {},
    );
  }

  Future<void> refresh() async {
    List<Post> posts = [];
    final users =
        ref.read(friendsFriendListNotifierProvider).asData?.value ?? [];
    List<Future<List<Post>>> futures = [];
    for (String userId in users.map((user) => user.userId)) {
      futures.add(usecase.getPostFromUserId(userId));
    }
    await Future.wait(futures);
    for (var future in futures) {
      posts.addAll(await future);
    }
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    ref.read(allPostsNotifierProvider.notifier).addPosts(posts);
    if (mounted) {
      state = AsyncValue.data(posts);
    }
  }
}
