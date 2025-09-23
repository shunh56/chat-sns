import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/presentation/pages/posts/enhanced_reaction_button.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_content.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_media_gallery.dart';
import 'package:gap/gap.dart';

/// 投稿カードのメインコンテンツレイアウト
class PostCardContentLayout extends ConsumerWidget {
  const PostCardContentLayout({
    super.key,
    required this.post,
    required this.user,
    this.onUserTap,
    this.onMoreTap,
    this.onDoubleTap,
    this.onReaction,
  });

  final Post post;
  final UserAccount user;
  final VoidCallback? onUserTap;
  final VoidCallback? onMoreTap;
  final Function(Offset position)? onDoubleTap;
  final Function(String reactionType)? onReaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // アイコン
        GestureDetector(
          onTap: onUserTap,
          child: UserIcon(user: user),
        ),
        const Gap(12),
        // その他（カラム）
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(8),
              // ヘッダー情報
              _PostHeaderInfo(
                user: user,
                post: post,
                onMoreTap: onMoreTap,
              ),

              // コンテンツ
              PostContent(post: post),

              // メディア
              if (post.mediaUrls.isNotEmpty) ...[
                const Gap(8),
                PostMediaGallery(
                  mediaUrls: post.mediaUrls,
                  aspectRatios: post.aspectRatios,
                  borderRadius: 12,
                  onDoubleTap: onDoubleTap,
                )
              ],

              // アクションバー
              const Gap(8),
              EnhancedReactionButton(
                post: post,
                user: user,
                onReaction: (reaction) {
                  onReaction?.call(reaction);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ヘッダー情報ウィジェット
class _PostHeaderInfo extends StatelessWidget {
  const _PostHeaderInfo({
    required this.user,
    required this.post,
    this.onMoreTap,
  });

  final UserAccount user;
  final Post post;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              // ユーザー名
              Flexible(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8),
              // タイムスタンプ
              Text(
                post.createdAt.xxAgo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
        // その他ボタン
        if (onMoreTap != null)
          GestureDetector(
            onTap: onMoreTap,
            child: const Icon(
              Icons.more_horiz_outlined,
              size: 20,
              color: Color(0xFF999999),
            ),
          ),
      ],
    );
  }
}
