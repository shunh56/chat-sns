import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_card.dart';
import 'package:app/presentation/providers/posts/public_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicPostsThread extends ConsumerStatefulWidget {
  const PublicPostsThread({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PublicPostsThreadState();
}

class _PublicPostsThreadState extends ConsumerState<PublicPostsThread>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final postList = ref.watch(publicPostsNotiferProvider);
    return postList.when(
      data: (list) {
        return RefreshIndicator(
          color: ThemeColor.text,
          backgroundColor: ThemeColor.stroke,
          onRefresh: () async {
            return await ref
                .read(publicPostsNotiferProvider.notifier)
                .refresh();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final post = list[index];
              return UserWidget(
                userId: post.userId,
                builder: (user) => PostCard(
                  postRef: post,
                  user: user,
                ),
              );
            },
          ),
        );
      },
      error: (e, s) {
        return const SizedBox();
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(
            color: ThemeColor.text,
          ),
        );
      },
    );
  }
}
