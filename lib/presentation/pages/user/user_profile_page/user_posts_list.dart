import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/pages/posts/core/components/post_card/post_card.dart';
import 'package:app/presentation/providers/posts/user_posts.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPostsList extends ConsumerStatefulWidget {
  const UserPostsList({super.key, required this.userId});
  final String userId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserPostsListState();
}

class _UserPostsListState extends ConsumerState<UserPostsList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final postList = ref.watch(userPostsNotiferProvider(widget.userId));
    final imageList = ref.watch(userImagePostsNotiferProvider(widget.userId));
    const imageHeight = 92.0;
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        imageList.when(
          data: (list) {
            if (list.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  bottom: 4,
                ),
                child: SizedBox(
                  height: imageHeight,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final post = list[index];
                      return GestureDetector(
                        onTap: () async {
                          final user = await ref
                              .read(allUsersNotifierProvider.notifier)
                              .getUserByUserId(widget.userId);
                          ref
                              .read(navigationRouterProvider(context))
                              .goToPost(post, user);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: imageHeight,
                              height: imageHeight,
                              child:
                                  CachedImage.postImage(post.mediaUrls.first),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
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
        ),
        postList.when(
          data: (list) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final post = list[index];
                return Column(
                  children: [
                    UserWidget(
                      userId: widget.userId,
                      builder: (user) => PostCard(
                        postRef: post,
                        user: user,
                      ),
                    ),
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
        ),
      ],
    );
  }
}
