import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/pages/posts/core/components/post_card/post_card.dart';
import 'package:app/presentation/providers/posts/public_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// パブリック投稿のコンテンツ（RefreshIndicatorとListViewを含まない）
class PublicPostsContent extends ConsumerWidget {
  const PublicPostsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postList = ref.watch(publicPostsNotiferProvider);

    return postList.when(
      data: (list) {
        return Column(
          children: list.map((post) {
            return UserWidget(
              userId: post.userId,
              builder: (user) => PostCard(
                postRef: post,
                user: user,
              ),
            );
          }).toList(),
        );
      },
      error: (e, s) {
        return const SizedBox();
      },
      loading: () {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(
              color: ThemeColor.text,
            ),
          ),
        );
      },
    );
  }
}
