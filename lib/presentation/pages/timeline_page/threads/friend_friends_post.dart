import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/share_widget.dart';
import 'package:app/presentation/pages/timeline_page/widget/friend_friends_post_widget.dart';
import 'package:app/presentation/providers/provider/posts/friends_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendFriendsPostsThread extends ConsumerStatefulWidget {
  const FriendFriendsPostsThread({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FriendFriendsPostsThreadState();
}

class _FriendFriendsPostsThreadState
    extends ConsumerState<FriendFriendsPostsThread>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final postList = ref.watch(friendFriendsPostsNotiferProvider);
    return postList.when(
      data: (list) {
        if (list.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 60),
            child: const ShareWidget(),
          );
        }
        return RefreshIndicator(
          color: ThemeColor.text,
          backgroundColor: ThemeColor.stroke,
          onRefresh: () async {
            return await ref
                .read(friendFriendsPostsNotiferProvider.notifier)
                .refresh();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final post = list[index];
              final user = ref
                  .read(allUsersNotifierProvider)
                  .asData!
                  .value[post.userId]!;

              return FriendFriendsPostWidget(postRef: post, user: user);
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
