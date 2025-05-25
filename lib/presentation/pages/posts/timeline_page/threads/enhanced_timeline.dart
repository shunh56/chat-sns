
import 'package:app/presentation/pages/posts/timeline_page/widget/enhanced_post_widget.dart';
import 'package:app/presentation/providers/posts/following_posts.dart';
import 'package:app/presentation/providers/posts/public_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnhancedFollowingPostsThread extends ConsumerWidget {
  const EnhancedFollowingPostsThread({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postList = ref.watch(followingPostsNotifierProvider);

    return postList.when(
      data: (list) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(followingPostsNotifierProvider.notifier).refresh();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final post = list[index];
              return EnhancedPostWidget(
                postRef: post,
                index: index,
              );
            },
          ),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class EnhancedPublicPostsThread extends ConsumerWidget {
  const EnhancedPublicPostsThread({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postList = ref.watch(publicPostsNotiferProvider);

    return postList.when(
      data: (list) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.read(publicPostsNotiferProvider.notifier).refresh();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final post = list[index];
              return EnhancedPostWidget(
                postRef: post,
                index: index,
              );
            },
          ),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}