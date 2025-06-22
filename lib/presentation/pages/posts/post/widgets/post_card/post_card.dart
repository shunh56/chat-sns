// lib/presentation/pages/posts/post/widgets/post_card/post_card.dart
import 'package:app/presentation/pages/posts/enhanced_reaction_button.dart';
import 'package:app/presentation/pages/posts/post/components/animations/post_animation.dart';
import 'package:app/presentation/pages/posts/post/components/style/post_style.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';

import 'package:app/presentation/pages/posts/post/widgets/post_card/post_header.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_content.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_media_gallery.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_action_bar.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:gap/gap.dart';

/// 投稿カードの表示スタイル
enum PostCardStyle {
  timeline, // タイムライン表示用
  detail, // 詳細画面表示用
}

/// メインの投稿カードウィジェット
class PostCard extends HookConsumerWidget with AnimatedTapHandler {
  const PostCard({
    super.key,
    required this.postRef,
    required this.user,
    this.style = PostCardStyle.timeline,
    this.index = 0,
    this.showVibeIndicator = false,
    this.onTap,
    this.onDoubleTap,
    this.onReaction,
    this.onComment,
    this.onShare,
  });

  final Post postRef;
  final UserAccount user;
  final PostCardStyle style;
  final int index;
  final bool showVibeIndicator;

  final VoidCallback? onTap;
  final Function(Offset position)? onDoubleTap;
  final Function(String reactionType)? onReaction;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(allPostsNotifierProvider).asData?.value[postRef.id];
    if (post == null) return const SizedBox();
    if (user.accountStatus != AccountStatus.normal) return const SizedBox();
    if (post.isDeletedByUser ||
        post.isDeletedByModerator ||
        post.isDeletedByAdmin) {
      return const SizedBox();
    }

    final animations = usePostAnimations(index: index, style: style);
    final vibeColor = VibeColorManager.getVibeColor(user);

    return AnimatedBuilder(
      animation: Listenable.merge([
        animations.slideAnimation,
        animations.fadeAnimation,
        animations.scaleAnimation,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: animations.slideAnimation,
          child: FadeTransition(
            opacity: animations.fadeAnimation,
            child: Transform.scale(
              scale: animations.scaleAnimation.value,
              child: _buildCard(context, ref, post, vibeColor, animations),
            ),
          ),
        );
      },
    );
  }

  /// 基本カードの構築
  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    Post post,
    Color vibeColor,
    PostAnimations animations,
  ) {
    return GestureDetector(
      onTap: () => _handleCardTap(context, ref, post),
      onTapDown: (details) =>
          handleTapDown(animations.scaleController, details),
      onTapUp: (details) => handleTapUp(animations.scaleController, details),
      onTapCancel: () => handleTapCancel(animations.scaleController),
      onDoubleTapDown: onDoubleTap != null
          ? (details) => onDoubleTap!(details.localPosition)
          : null,
      child: Container(
        margin: _getCardMargin(),
        decoration: PostCardStyling.getCardDecoration(vibeColor),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: _buildCardContent(context, ref, post),
        ),
      ),
    );
  }

  /// カードコンテンツの構築
  Widget _buildCardContent(BuildContext context, WidgetRef ref, Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ヘッダー
        PostHeader(
          user: user,
          post: post,
          showVibeIndicator: showVibeIndicator,
          onUserTap: () => _handleUserTap(context, ref, post),
        ),

        // コンテンツ
        PostContent(post: post),

        // メディア
        if (post.mediaUrls.isNotEmpty) ...[
          const Gap(4),
          PostMediaGallery(
            mediaUrls: post.mediaUrls,
            aspectRatios: post.aspectRatios,
            borderRadius: 12,
            onDoubleTap: onDoubleTap,
          )
        ],

        // アクションバー
        _buildActionBar(context, ref, post),
      ],
    );
  }

  /// アクションバーの構築
  Widget _buildActionBar(BuildContext context, WidgetRef ref, Post post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: EnhancedReactionButton(
        post: post,
        user: user,

        // onComment: onComment,
        // onShare: onShare,
        // onMore: () => _handleMoreTap(context, ref, post),

        onReaction: (reaction) {
          onReaction?.call(reaction);
        },
      ),
    );
  }

  /// カードマージンを取得
  EdgeInsets _getCardMargin() {
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  }

  /// ボーダー半径を取得
  double _getBorderRadius() {
    switch (style) {
      case PostCardStyle.timeline:
      case PostCardStyle.detail:
      default:
        return 20;
    }
  }

  /// アクションバースタイルを取得
  ActionBarStyle _getActionBarStyle() {
    switch (style) {
      case PostCardStyle.timeline:
      case PostCardStyle.detail:
      default:
        return ActionBarStyle.full;
    }
  }

  /// カードタップ処理
  void _handleCardTap(BuildContext context, WidgetRef ref, Post post) {
    if (style == PostCardStyle.detail) {
      return;
    }
    if (onTap != null) {
      onTap!();
    } else {
      ref.read(navigationRouterProvider(context)).goToPost(post, user);
    }
  }

  /// ユーザータップ処理
  void _handleUserTap(BuildContext context, WidgetRef ref, Post post) {
    ref.read(navigationRouterProvider(context)).goToProfile(user);
  }

  /// その他ボタンタップ処理
  void _handleMoreTap(BuildContext context, WidgetRef ref, Post post) {
    PostBottomModelSheet(context).openPostAction(post, user);
  }
}

/// 投稿カードのスケルトンローディング
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({
    super.key,
    this.style = PostCardStyle.timeline,
  });

  final PostCardStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _getCardMargin(),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PostHeaderSkeleton(),
          const Gap(16),
          const PostContentSkeleton(),
          const Gap(16),
          const PostMediaGallerySkeleton(),
          const Gap(16),
          PostActionBarSkeleton(style: ActionBarStyle.minimal),
        ],
      ),
    );
  }

  EdgeInsets _getCardMargin() {
    switch (style) {
      case PostCardStyle.timeline:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

      case PostCardStyle.detail:
      default:
        return EdgeInsets.zero;
    }
  }

  double _getBorderRadius() {
    switch (style) {
      case PostCardStyle.timeline:
      case PostCardStyle.detail:
      default:
        return 20;
    }
  }

  ActionBarStyle _getActionBarStyle() {
    switch (style) {
      case PostCardStyle.timeline:
      case PostCardStyle.detail:
      default:
        return ActionBarStyle.full;
    }
  }
}

/// 投稿カードのエラー表示
class PostCardError extends StatelessWidget {
  const PostCardError({
    super.key,
    this.error,
    this.onRetry,
  });

  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const Gap(16),
          Text(
            error ?? '投稿の読み込みに失敗しました',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const Gap(16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('再試行'),
            ),
          ],
        ],
      ),
    );
  }
}
