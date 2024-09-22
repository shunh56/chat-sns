// Flutter imports:

// Package imports:
import 'package:app/domain/entity/posts/blog.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/usecase/posts/blog_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allBlogsNotiferProvider =
    StateNotifierProvider.autoDispose<AllBlogsNotifier, AsyncValue<List<Blog>>>(
        (ref) {
  return AllBlogsNotifier(
    ref,
    ref.watch(blogUsecaseProvider),
  )..initialize();
});

/// State
class AllBlogsNotifier extends StateNotifier<AsyncValue<List<Blog>>> {
  AllBlogsNotifier(
    this.ref,
    this.usecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final BlogUsecase usecase;

  bool initialized = false;

  Future<void> initialize() async {
    final posts = await usecase.getPosts();
    await ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(posts.map((post) => post.userId).toList());
    state = AsyncValue.data(posts);
  }

  Future<void> refresh() async {
    final posts = await usecase.getPosts();
    await ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(posts.map((post) => post.userId).toList());
    state = AsyncValue.data(posts);
  }
}
