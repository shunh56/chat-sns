import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/presentation/pages/posts/features/post_detail/replies/reply_item.dart';
import 'package:app/presentation/providers/posts/replies.dart';

/// リプライセクション
///
/// 機能:
/// - リプライ一覧の表示
/// - リプライ投稿フォーム
class ReplySection extends ConsumerWidget {
  const ReplySection({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesAsync = ref.watch(postRepliesNotifierProvider(postId));

    return repliesAsync.when(
      data: (replies) {
        if (replies.isEmpty) {
          return const Center(
            child: Text(
              'まだリプライがありません',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: replies.length,
          itemBuilder: (context, index) {
            final reply = replies[index];
            return ReplyItem(reply: reply);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'エラーが発生しました: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
