import 'package:app/domain/entity/posts/post.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/domain/usecases/posts/post_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userPostsNotiferProvider = StateNotifierProvider.family<UserPostsNotifier,
    AsyncValue<List<Post>>, String>((ref, userId) {
  return UserPostsNotifier(
    ref,
    userId,
    ref.watch(postUsecaseProvider),
  )..initialize();
});

class UserPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  UserPostsNotifier(this.ref, this.userId, this.usecase)
      : super(const AsyncValue.loading());

  final Ref ref;
  final String userId;
  final PostUsecase usecase;

  Future<void> initialize() async {
    final posts = await ref
        .read(allPostsNotifierProvider.notifier)
        .getPostsFromUserId(userId);
    state = AsyncValue.data(posts);
  }

  refresh() async {
    initialize();
  }
}

final userImagePostsNotiferProvider = StateNotifierProvider.family<
    UserImagePostsNotifier, AsyncValue<List<Post>>, String>((ref, userId) {
  return UserImagePostsNotifier(
    ref,
    userId,
    ref.watch(postUsecaseProvider),
  )..initialize();
});

class UserImagePostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  UserImagePostsNotifier(this.ref, this.userId, this.usecase)
      : super(const AsyncValue.loading());

  final Ref ref;
  final String userId;
  final PostUsecase usecase;

  Future<void> initialize() async {
    final posts = await ref
        .read(allPostsNotifierProvider.notifier)
        .getImagePostsFromUserId(userId);
    state = AsyncValue.data(posts);
  }

  refresh() async {
    initialize();
  }
}
