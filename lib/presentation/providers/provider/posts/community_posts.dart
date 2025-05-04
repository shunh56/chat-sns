import 'package:app/domain/entity/posts/post.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/domain/usecases/posts/post_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final communityPostsNotifierProvider = StateNotifierProvider.family<
    CommunityPostsNotifiier, AsyncValue<List<Post>>, String>((ref, comunityId) {
  return CommunityPostsNotifiier(
    ref,
    comunityId,
    ref.watch(postUsecaseProvider),
  )..initialize();
});

/// State
class CommunityPostsNotifiier extends StateNotifier<AsyncValue<List<Post>>> {
  CommunityPostsNotifiier(
    this.ref,
    this.communityId,
    this.postUsecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final String communityId;
  final PostUsecase postUsecase;

  Future<void> initialize() async {
    final res = await postUsecase.getPostsFromCommunityId(communityId);
    final userIds = res.map((e) => e.userId).toSet().toList();
    ref.read(allPostsNotifierProvider.notifier).addPosts(res);
    await ref.read(allUsersNotifierProvider.notifier).getUserAccounts(userIds);
    state = AsyncValue.data(res);
  }

/*  Future<void> refresh() async {
    List<Post> posts = [];
    List<Future<List<Post>>> futures = [];
    final myId = ref.read(authProvider).currentUser!.uid;
    final friendIds =
        (ref.read(friendIdListNotifierProvider).asData?.value ?? [])
            .map((info) => info.userId)
            .toList();
    final userIds = [...friendIds, myId];
    futures.add(postUsecase.getPostFromUserIds(userIds));
    //futures.add(currentStatusPostUsecase.getPostFromUserIds(userIds));
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

  Future<void> load() async {
    if (ref.read(friendIdListNotifierProvider).asData!.value.length > 30) {
      final cache = state.asData?.value ?? [];
      final list = await fetch(page: (cache.length) ~/ hitsPerPage);
      state = AsyncValue.data([...cache, ...list]);
    }
  }

  Future<List<Post>> fetch({int page = 0}) async {
    final myId = ref.read(authProvider).currentUser!.uid;
    List<Post> posts = [];
    final infos = ref.read(friendIdListNotifierProvider).asData?.value ?? [];
    final friendIds = infos.map((info) => info.userId).toList();

    List<Future<List<Post>>> futures = [];
    futures.add(getMyCurrentStatusPosts());
    if (friendIds.length > 30) {
      futures.add(_algoliaPostUsecase
          .getUserIdsPosts([...friendIds, myId], page: page));
    }
    for (String userId in friendIds) {
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
