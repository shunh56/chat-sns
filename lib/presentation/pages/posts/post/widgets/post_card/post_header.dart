// lib/presentation/pages/posts/post/widgets/post_card/post_header.dart
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/pages/posts/post/components/style/post_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/posts/post/components/vibe/vibe_indicator.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:gap/gap.dart';

/// 投稿カードのヘッダー部分を表示するウィジェット
class PostHeader extends ConsumerWidget {
  const PostHeader({
    super.key,
    required this.user,
    required this.post,
    this.showVibeIndicator = false,
    this.isDetailView = false,
    this.onUserTap,
  });

  final UserAccount user;
  final Post post;
  final bool showVibeIndicator;
  final bool isDetailView;
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vibeColor = VibeColorManager.getVibeColor(user);
    final vibeText = VibeTextAnalyzer.analyzePostVibe(user, post);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isDetailView ? 20 : 16,
        16,
        0,
      ),
      child: Row(
        children: [
          _buildUserAvatar(vibeColor),
          const Gap(12),
          _buildUserInfo(),
          const Spacer(),
          if (showVibeIndicator)
            VibeIndicator(
              mood: vibeText,
              color: vibeColor,
            ),
          GestureDetector(
            onTap: () {
              PostBottomModelSheet(context).openPostAction(post, user);
            },
            child: Icon(
              Icons.more_horiz_outlined,
              color: ThemeColor.subText,
            ),
          ),
        ],
      ),
    );
  }

  /// ユーザーアバターを構築
  Widget _buildUserAvatar(Color vibeColor) {
    return UserIcon(user: user);
  }

  /// ユーザー情報を構築
  Widget _buildUserInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ユーザー名
          Text(
            user.name,
            style: PostTextStyles.getHeaderText(
              fontSize: isDetailView ? 16 : 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(2),

          // タイムスタンプとアイコン
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.7),
              ),
              const Gap(4),
              Text(
                post.createdAt.xxAgo,
                style: PostTextStyles.getTimestampText(),
              ),
              if (isDetailView) ...[
                const Gap(8),
                _buildPrivacyIndicator(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// プライバシーインジケーターを構築
  Widget _buildPrivacyIndicator() {
    return Icon(
      post.isPublic ? Icons.public_outlined : Icons.lock_outline,
      size: 14,
      color: Colors.white.withOpacity(0.5),
    );
  }
}

/// 詳細画面用の拡張ヘッダー
class PostDetailHeader extends ConsumerWidget {
  const PostDetailHeader({
    super.key,
    required this.user,
    required this.post,
  });

  final UserAccount user;
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vibeColor = VibeColorManager.getVibeColor(user);
    final vibeText = VibeTextAnalyzer.analyzePostVibe(user, post);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: PostCardStyling.getCardDecoration(vibeColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(
            user: user,
            post: post,
            isDetailView: true,
            onUserTap: () {
              ref.read(navigationRouterProvider(context)).goToProfile(user);
            },
          ),
          const Gap(16),
          _buildDetailContent(),
        ],
      ),
    );
  }

  /// 詳細コンテンツを構築
  Widget _buildDetailContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // タイトル
        Text(
          post.title ?? "NULL TITLE",
          style: PostTextStyles.getHeaderText(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        // テキスト内容
        if (post.text != null) ...[
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              post.text!,
              style: PostTextStyles.getContentText(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// コンパクトなヘッダー（リスト表示用）
class CompactPostHeader extends ConsumerWidget {
  const CompactPostHeader({
    super.key,
    required this.user,
    required this.post,
    this.onUserTap,
  });

  final UserAccount user;
  final Post post;
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        GestureDetector(
          onTap: onUserTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: VibeColorManager.getVibeColor(user).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: user.imageUrl != null
                  ? CachedImage.userIcon(user.imageUrl!, user.name, 14)
                  : Container(
                      color: const Color(0xFF2A2A2A),
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
            ),
          ),
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: PostTextStyles.getHeaderText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(2),
              Text(
                post.createdAt.xxAgo,
                style: PostTextStyles.getTimestampText(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ヘッダーのスケルトンローディング
class PostHeaderSkeleton extends StatelessWidget {
  const PostHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Gap(4),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
