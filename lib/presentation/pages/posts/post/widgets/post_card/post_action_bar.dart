// lib/presentation/pages/posts/post/widgets/post_card/post_action_bar.dart
import 'package:app/presentation/pages/posts/post/components/style/post_style.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/posts/enhanced_reaction_button.dart';
import 'package:gap/gap.dart';

/// アクションバーのスタイル
enum ActionBarStyle {
  full, // 全機能表示
  compact, // コンパクト表示
  minimal, // 最小限の表示
}

/// 投稿のアクションバーウィジェット
class PostActionBar extends HookConsumerWidget {
  const PostActionBar({
    super.key,
    required this.post,
    required this.user,
    this.style = ActionBarStyle.full,
    this.onReaction,
    this.onComment,
    this.onShare,
    this.onMore,
  });

  final Post post;
  final UserAccount user;
  final ActionBarStyle style;
  final Function(String reactionType)? onReaction;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: EnhancedReactionButton(
        user: user,
        post: post,
        onReaction: (reaction) {
          onReaction?.call(reaction);
        },
      ),
    );
  }
}

/// リアクション専用のアクションバー
class ReactionOnlyActionBar extends HookConsumerWidget {
  const ReactionOnlyActionBar({
    super.key,
    required this.post,
    required this.user,
    this.onReaction,
  });

  final Post post;
  final UserAccount user;
  final Function(String reactionType)? onReaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: EnhancedReactionButton(
        user: user,
        post: post,
        onReaction: (reaction) {
          onReaction?.call(reaction);
        },
      ),
    );
  }
}

/// 統計のみ表示するアクションバー
class StatisticsOnlyActionBar extends ConsumerWidget {
  const StatisticsOnlyActionBar({
    super.key,
    required this.post,
    this.showLabels = true,
  });

  final Post post;
  final bool showLabels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (post.likeCount > 0) ...[
            _buildStatItem(
              icon: Icons.favorite,
              count: post.likeCount,
              label: showLabels ? 'いいね' : null,
              color: VibeColorManager.getReactionColor('love'),
            ),
            const Gap(16),
          ],
          if (post.replyCount > 0) ...[
            _buildStatItem(
              icon: Icons.chat_bubble_outline,
              count: post.replyCount,
              label: showLabels ? 'コメント' : null,
              color: Colors.blue,
            ),
            const Gap(16),
          ],
          /*if (post.shareCount > 0) ...[
            _buildStatItem(
              icon: Icons.share_outlined,
              count: post.shareCount,
              label: showLabels ? 'シェア' : null,
              color: Colors.grey,
            ),
          ], */
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    String? label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const Gap(4),
        Text(
          _formatCount(count),
          style: PostTextStyles.getReactionText(color: color),
        ),
        if (label != null) ...[
          const Gap(4),
          Text(
            label,
            style: PostTextStyles.getReactionText(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}

/// アクションバーのスケルトンローディング
class PostActionBarSkeleton extends StatelessWidget {
  const PostActionBarSkeleton({
    super.key,
    this.style = ActionBarStyle.full,
  });

  final ActionBarStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // アクションボタンのスケルトン
          Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Gap(16),
          Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Spacer(),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
