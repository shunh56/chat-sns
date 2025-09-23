import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_header.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_content.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_media_gallery.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_action_bar.dart';

/// 投稿カードのスケルトンローディング
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeaderSkeleton(),
          Gap(16),
          PostContentSkeleton(),
          Gap(16),
          PostMediaGallerySkeleton(),
          Gap(16),
          PostActionBarSkeleton(),
        ],
      ),
    );
  }
}