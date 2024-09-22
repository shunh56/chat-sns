// Flutter imports:

// Package imports:
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/usecase/posts/post_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final popularPostsNotiferProvider =
    StateNotifierProvider<PopularPostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PopularPostsNotifier(
    ref,
    ref.watch(postUsecaseProvider),
  )..initialize();
});

/// State
class PopularPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  PopularPostsNotifier(this.ref, this.usecase)
      : super(const AsyncValue.loading());

  final Ref ref;
  final PostUsecase usecase;

  Future<void> initialize() async {
    final posts = await usecase.getPopularPosts();
    await ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(posts.map((post) => post.userId).toList());
    ref.read(allPostsNotifierProvider.notifier).addPosts(posts);
    state = AsyncValue.data(posts);
  }
}
