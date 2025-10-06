import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/pages/posts/core/components/post_card/post_card.dart';
import 'package:app/presentation/providers/posts/following_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// フォロー投稿のコンテンツ（RefreshIndicatorとListViewを含まない）
class FollowingPostsContent extends ConsumerWidget {
  const FollowingPostsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postList = ref.watch(followingPostsNotifierProvider);

    return postList.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'フォロー中の投稿はありません',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }
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
