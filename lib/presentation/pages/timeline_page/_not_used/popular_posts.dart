import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/provider/posts/popular_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopularPostsThread extends ConsumerWidget {
  const PopularPostsThread({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postList = ref.watch(popularPostsNotiferProvider);
    return postList.when(
      data: (list) {
        return RefreshIndicator(
          onRefresh: () async {
            return await ref
                .read(popularPostsNotiferProvider.notifier)
                .initialize();
          },
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final post = list[index];
              final user = ref
                  .read(allUsersNotifierProvider)
                  .asData!
                  .value[post.userId]!;

              return PostWidget(postRef: post, user: user);
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
