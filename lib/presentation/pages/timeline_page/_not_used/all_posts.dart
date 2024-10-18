import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/provider/posts/timeline_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllPostsThread extends ConsumerWidget {
  const AllPostsThread({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postList = ref.watch(timelinePostsNotiferProvider);
    return postList.when(
      data: (list) {
        return RefreshIndicator(
          onRefresh: () async {
            return await ref
                .read(timelinePostsNotiferProvider.notifier)
                .initialize();
          },
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final post = list[index];

              return PostWidget(postRef: post, userId: post.userId);
            },
          ),
        );
      },
      error: (e, s) {
        return const SizedBox();
      },
      loading: () {
        return const SizedBox();
      },
    );
  }
}
