/*// Flutter imports:

// Package imports:
import 'package:app/datasource/post/algolia_post_datasource.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/posts/timeline_post.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/usecase/posts/algolia_post_usecase.dart';
import 'package:app/usecase/posts/current_status_post_usecase.dart';
import 'package:app/usecase/posts/post_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsPostsNotifierProvider = StateNotifierProvider.autoDispose<
    FriendsPostsNotifier, AsyncValue<List<PostBase>>>((ref) {
  return FriendsPostsNotifier(
    ref,
    ref.watch(postUsecaseProvider),
    ref.watch(currentStatusPostUsecaseProvider),
    ref.watch(algoliaPostUsecaseProvider),
  )..initialize();
});

/// State
class FriendsPostsNotifier extends StateNotifier<AsyncValue<List<PostBase>>> {
  FriendsPostsNotifier(
    this.ref,
    this.postUsecase,
    this.currentStatusPostUsecase,
    this._algoliaPostUsecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;

  final PostUsecase postUsecase;
  final CurrentStatusPostUsecase currentStatusPostUsecase;
  final AlgoliaPostUsecase _algoliaPostUsecase;
  bool initialized = false;

  Future<void> initialize() async {
    final myId = ref.read(authProvider).currentUser!.uid;
    List<PostBase> posts = [];
    final asyncValue = ref.read(friendIdsStreamNotifier);
    asyncValue.maybeWhen(
      data: (friendIds) async {
        if (initialized) return;
        initialized = true;
        List<Future<List<PostBase>>> futures = [];
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
        return;
      },
      orElse: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        initialize();
      },
    );
  }

  Future<void> refresh() async {
    List<PostBase> posts = [];
    List<Future<List<PostBase>>> futures = [];
    final myId = ref.read(authProvider).currentUser!.uid;
    final friendIds = ref.read(friendIdsProvider);
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
    if (ref.read(friendIdsProvider).length > 30) {
      final cache = state.asData?.value ?? [];
      final list = await fetch(page: (cache.length) ~/ hitsPerPage);
      state = AsyncValue.data([...cache, ...list]);
    }
  }

  Future<List<PostBase>> fetch({int page = 0}) async {
    final myId = ref.read(authProvider).currentUser!.uid;
    List<PostBase> posts = [];

    final friendIds = ref.read(friendIdsProvider);

    List<Future<List<PostBase>>> futures = [];
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

  Future<List<PostBase>> getMyCurrentStatusPosts() async {
    final myId = ref.read(authProvider).currentUser!.uid;
    return currentStatusPostUsecase.getUsersPosts(myId);
  }
}

/*final friendsCurrentStatusPostsNotiferProvider =
    StateNotifierProvider.autoDispose<FriendsCurrentStatusPostsNotifier,
        AsyncValue<Map<String, List<CurrentStatusPost>>>>((ref) {
  return FriendsCurrentStatusPostsNotifier(
    ref,
    ref.watch(friendIdListNotifierProvider),
    ref.watch(currentStatusPostUsecaseProvider),
  )..initialize();
});

/// State
class FriendsCurrentStatusPostsNotifier
    extends StateNotifier<AsyncValue<Map<String, List<CurrentStatusPost>>>> {
  FriendsCurrentStatusPostsNotifier(
    this.ref,
    this.asyncValue,
    this.currentStatusPostUsecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final AsyncValue<List<FriendInfo>> asyncValue;

  final CurrentStatusPostUsecase currentStatusPostUsecase;

  bool initialized = false;

  Future<void> initialize() async {
    final myId = ref.read(authProvider).currentUser!.uid;
    Map<String, List<CurrentStatusPost>> map = {};
    List<CurrentStatusPost> posts = [];
    asyncValue.maybeWhen(
      data: (infos) async {
        if (initialized) return;
        initialized = true;
        List<Future<List<CurrentStatusPost>>> futures = [];
        final friendIds = infos.map((info) => info.userId).toList();
        final userIds = [...friendIds, myId];
        futures.add(currentStatusPostUsecase.getPostFromUserIds(userIds));
        await Future.wait(futures);
        for (var item in futures) {
          final list = await item;
          ref
              .read(allCurrentStatusPostsNotifierProvider.notifier)
              .addPosts(list);
          posts.addAll(list);
        }
        posts.removeWhere((post) => post.noNewChange);
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        for (var post in posts) {
          if (map[post.userId] == null) {
            map[post.userId] = [post];
          } else {
            map[post.userId]!.add(post);
          }
        }
        if (mounted) {
          state = AsyncValue.data(map);
        }
      },
      orElse: () {},
    );
  }

  Future<void> refresh() async {
    Map<String, List<CurrentStatusPost>> map = {};
    List<CurrentStatusPost> posts = [];
    List<Future<List<CurrentStatusPost>>> futures = [];
    final myId = ref.read(authProvider).currentUser!.uid;
    final friendIds =
        (ref.read(friendIdListNotifierProvider).asData?.value ?? [])
            .map((info) => info.userId)
            .toList();
    final userIds = [...friendIds, myId];
    futures.add(currentStatusPostUsecase.getPostFromUserIds(userIds));
    await Future.wait(futures);
    for (var item in futures) {
      final list = await item;
      ref.read(allCurrentStatusPostsNotifierProvider.notifier).addPosts(list);
      posts.addAll(list);
    }
    posts.removeWhere((post) => post.noNewChange);
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (var post in posts) {
      if (map[post.userId] == null) {
        map[post.userId] = [post];
      } else {
        map[post.userId]!.add(post);
      }
    }
    if (mounted) {
      state = AsyncValue.data(map);
    }
  }
}
 */
/*final friendFriendsPostsNotiferProvider = StateNotifierProvider.autoDispose<
    FriendFriendsPostsNotifier, AsyncValue<List<Post>>>((ref) {
  return FriendFriendsPostsNotifier(
    ref,
    ref.watch(postUsecaseProvider),
    // ref.watch(algoliaPostUsecaseProvider),
  )..initialize();
});

class FriendFriendsPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  FriendFriendsPostsNotifier(
    this.ref,
    this.usecase,
    //this._algoliaPostUsecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;

  final PostUsecase usecase;
  //final AlgoliaPostUsecase _algoliaPostUsecase;

  Future<void> initialize() async {
    List<Post> posts = [];
    final userIds = ref.read(relationNotifier).getMaybeFriends();
    List<Future<List<Post>>> futures = [];
    futures.add(usecase.getPostFromUserIds(userIds, onlyPublic: false));
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

  Future<void> refresh() async {
    List<Post> posts = [];
    final userIds = ref.read(relationNotifier).getMaybeFriends();
    List<Future<List<Post>>> futures = [];
    futures.add(usecase.getPostFromUserIds(userIds, onlyPublic: false));
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

 */
/*
final maybeFriendIdsNotiferProvider = StateNotifierProvider.autoDispose<
    MaybeFriendIdsNotifier, AsyncValue<List<String>>>((ref) {
  return MaybeFriendIdsNotifier(
    ref,
    ref.watch(friendIdListNotifierProvider),
  )..initialize();
});

class MaybeFriendIdsNotifier extends StateNotifier<AsyncValue<List<String>>> {
  MaybeFriendIdsNotifier(
    this.ref,
    this.asyncValue,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final AsyncValue<List<FriendInfo>> asyncValue;

  bool initialized = false;

  Future<void> initialize() async {
    final myId = ref.read(authProvider).currentUser!.uid;
    List<PostBase> posts = [];
    asyncValue.maybeWhen(
      data: (infos) async {
        if (initialized) {
          return [];
        }
        final maybeFriendIds =
       
        futures.add(getMyCurrentStatusPosts());
        for (String userId in infos.map((item) => item.userId)) {
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
    if (ref.read(friendIdListNotifierProvider).asData!.value.length > 30) {
      final list = await fetch();
      state = AsyncValue.data(list);
    }
  }
}
*/ */