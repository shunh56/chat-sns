import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/posts/post/components/animations/post_animation.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/state/scroll_controller.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_card_content_layout.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_card_animated_container.dart';

/// タイムライン用の投稿カードウィジェット
class PostCard extends HookConsumerWidget with AnimatedTapHandler {
  const PostCard({
    super.key,
    required this.postRef,
    required this.user,
  });

  final Post postRef;
  final UserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(allPostsNotifierProvider).asData?.value[postRef.id];

    // 投稿が無効な場合は表示しない
    if (post == null || !post.isValidPost(user)) {
      return const SizedBox();
    }

    final animations = usePostAnimations(
      index: 0,
      postId: post.id,
      ref: ref,
    );

    //final vibeColor = VibeColorManager.getVibeColor(user);
    final isDeleting = ref.watch(deletingPostsProvider).contains(post.id);

    // カードウィジェットを構築
    final cardWidget = _buildCard(
      context: context,
      ref: ref,
      post: post,
      animations: animations,
    );

    // 削除中の場合は削除アニメーションを適用
    if (isDeleting) {
      return PostCardDeletingAnimation(child: cardWidget);
    }

    // 通常のアニメーションを適用
    return PostCardAnimatedContainer(
      animations: animations,
      child: cardWidget,
    );
  }

  /// カードウィジェットの構築
  Widget _buildCard({
    required BuildContext context,
    required WidgetRef ref,
    required Post post,
    required PostAnimations animations,
  }) {
    return GestureDetector(
      onTap: () => _handleCardTap(context, ref, post),
      onTapDown: (details) =>
          handleTapDown(animations.scaleController, details),
      onTapUp: (details) => handleTapUp(animations.scaleController, details),
      onTapCancel: () => handleTapCancel(animations.scaleController),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: ThemeColor.cardColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: PostCardContentLayout(
            post: post,
            user: user,
            onUserTap: () => _handleUserTap(context, ref),
            onMoreTap: () => _handleMoreTap(context, ref, post),
          ),
        ),
      ),
    );
  }

  /// カードマージンを取得

  /// カードタップ処理
  void _handleCardTap(BuildContext context, WidgetRef ref, Post post) {
    ref.read(navigationRouterProvider(context)).goToPost(post, user);
  }

  /// ユーザータップ処理
  void _handleUserTap(BuildContext context, WidgetRef ref) {
    ref.read(navigationRouterProvider(context)).goToProfile(user);
  }

  /// その他ボタンタップ処理
  void _handleMoreTap(BuildContext context, WidgetRef ref, Post post) {
    PostBottomModelSheet(context).openPostAction(post, user);
  }
}
