// Flutter imports:

// Package imports:
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/domain/usecases/posts/post_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followingPostsNotifierProvider = StateNotifierProvider.autoDispose<
    FollowingPostsNotifier, AsyncValue<List<Post>>>((ref) {
  return FollowingPostsNotifier(
    ref,
    ref.watch(postUsecaseProvider),
  )..initialize();
});

/// State
class FollowingPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  FollowingPostsNotifier(
    this.ref,
    this.postUsecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;

  final PostUsecase postUsecase;

  bool initialized = false;

  Future<void> initialize() async {
    final myId = ref.read(authProvider).currentUser!.uid;
    final postsNotifier = ref.read(allPostsNotifierProvider.notifier);

    final asyncValue = ref.read(followingListNotifierProvider);

    asyncValue.maybeWhen(
      data: (followingIds) async {
        if (initialized) return;
        initialized = true;

        final userIds = [...followingIds, myId];
        final posts = await postsNotifier.getPostsFromUserIds(userIds);
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (mounted) {
          state = AsyncValue.data(posts);
        }
        return;
      },
      orElse: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        initialize();
      },
    );
  }

  Future<void> refresh() async {
    final myId = ref.read(authProvider).currentUser!.uid;
    final postsNotifier = ref.read(allPostsNotifierProvider.notifier);

    final followingIds =
        ref.read(followingListNotifierProvider).asData?.value ?? [];
    final List<String> userIds = [...followingIds, myId];
    final posts = await postsNotifier.getPostsFromUserIds(userIds);
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (mounted) {
      state = AsyncValue.data(posts);
    }
  }
/*
  Future<void> load() async {
    if (ref.read(followingIdsProvider).length > 30) {
      final cache = state.asData?.value ?? [];
      final list = await fetch(page: (cache.length) ~/ hitsPerPage);
      state = AsyncValue.data([...cache, ...list]);
    }
  }

  Future<List<Post>> fetch({int page = 0}) async {
    final myId = ref.read(authProvider).currentUser!.uid;
    List<Post> posts = [];

    final followingIds = ref.read(followingIdsProvider);

    List<Future<List<Post>>> futures = [];

    if (followingIds.length > 30) {
      futures.add(_algoliaPostUsecase
          .getUserIdsPosts([...followingIds, myId], page: page));
    }
    for (String userId in followingIds) {
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
    return posts;
  }

 */
}
