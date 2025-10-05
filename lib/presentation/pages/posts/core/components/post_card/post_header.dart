import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/routes/navigator.dart';
import '../style/post_style.dart';

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
    return _buildUserAvatar(vibeColor);
  }

  /// ユーザーアバターを構築
  Widget _buildUserAvatar(Color vibeColor) {
    return UserIcon(user: user);
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
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
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
          post.title,
          style: PostTextStyles.getHeaderText(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        // テキスト内容
        ...[
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
              post.text,
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
