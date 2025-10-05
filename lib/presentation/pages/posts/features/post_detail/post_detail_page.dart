import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/presentation/pages/posts/core/components/reply_input.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/pages/posts/core/components/post_card/post_card.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'components/reply_section.dart';

/// 投稿詳細ページ
///
/// 機能:
/// - 投稿の詳細表示
/// - リプライ一覧表示
/// - リプライ投稿機能
class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPostsAsync = ref.watch(allPostsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿詳細'),
      ),
      body: allPostsAsync.when(
        data: (allPosts) {
          final post = allPosts[postId];
          if (post == null) {
            return const Center(
              child: Text('投稿が見つかりません'),
            );
          }

          // timelineと同じようにUserWidgetを使用
          return UserWidget(
            userId: post.userId,
            builder: (user) => Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      PostCard(
                        postRef: post,
                        user: user,
                      ),
                      ReplySection(postId: postId),
                    ],
                  ),
                ),
                ReplyInput(
                  placeholder: 'リプライを入力...',
                  onSubmit: (content) async {
                    // 現在のユーザーと投稿を取得
                    final currentUser = ref.read(authProvider).currentUser;
                    final allPostsAsync = ref.read(allPostsNotifierProvider);
                    final allPosts = allPostsAsync.asData?.value;
                    final post = allPosts?[postId];
                    final user = await ref
                        .read(allUsersNotifierProvider.notifier)
                        .getUserByUserId(currentUser!.uid);

                    if (post != null) {
                      // リプライを投稿
                      ref
                          .read(allPostsNotifierProvider.notifier)
                          .addReply(user, post, content);
                    }
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }
}
