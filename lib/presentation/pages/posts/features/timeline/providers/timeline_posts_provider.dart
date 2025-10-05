import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/usecases/posts/post_usecase.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';

/// タイムライン投稿データプロバイダー
final timelinePostsNotiferProvider =
    StateNotifierProvider<TimelinePostsNotifier, AsyncValue<List<Post>>>((ref) {
  return TimelinePostsNotifier(
    ref,
    ref.watch(postUsecaseProvider),
  )..initialize();
});

/// タイムライン投稿データ管理
class TimelinePostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  TimelinePostsNotifier(this.ref, this.usecase)
      : super(const AsyncValue.loading());

  final Ref ref;
  final PostUsecase usecase;

  /// 初期化処理
  Future<void> initialize() async {
    try {
      final posts = await usecase.getPosts();

      // ユーザー情報を事前取得
      await ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(posts.map((post) => post.userId).toList());

      // 全投稿プロバイダーにも追加
      ref.read(allPostsNotifierProvider.notifier).addPosts(posts);

      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 投稿リストから特定の投稿を削除
  void removePost(Post post) {
    final currentPosts = state.valueOrNull;
    if (currentPosts == null) return;

    final updatedPosts = currentPosts.where((p) => p.id != post.id).toList();
    state = AsyncValue.data(updatedPosts);
  }

  /// データを再読み込み
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await initialize();
  }
}
