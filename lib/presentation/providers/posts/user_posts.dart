import 'package:app/domain/entity/posts/post.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
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
    final posts = await usecase.getPostFromUserId(userId);
    await ref.read(allUsersNotifierProvider.notifier).getUserAccounts([userId]);
    ref.read(allPostsNotifierProvider.notifier).addPosts(posts);
    state = AsyncValue.data(posts);
  }

  refresh() async {
    initialize();
  }
}
