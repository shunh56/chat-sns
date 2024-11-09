import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/provider/posts/user_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPostsThread extends ConsumerStatefulWidget {
  const UserPostsThread({super.key, required this.userId});
  final String userId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserPostsThreadState();
}

class _UserPostsThreadState extends ConsumerState<UserPostsThread>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final postList = ref.watch(userPostsNotiferProvider(widget.userId));
    return postList.when(
      data: (list) {
        return ListView.builder(
          // physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 12, bottom: 120),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final post = list[index];
            return Column(
              children: [
                PostWidget(postRef: post),
              ],
            );
          },
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
