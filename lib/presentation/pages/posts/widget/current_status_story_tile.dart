/*import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';

import 'package:app/domain/entity/posts/UNUSED/current_status_post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/providers/heart_animation_notifier.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/posts/all_current_status_posts.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CurrentStatusStoryTileWidget extends ConsumerWidget {
  const CurrentStatusStoryTileWidget({
    super.key,
    required this.postRef,
  });
  final CurrentStatusPost postRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final post = ref
        .watch(allCurrentStatusPostsNotifierProvider)
        .asData!
        .value[postRef.id];
    if (post == null) return const SizedBox();
    final user = ref.read(allUsersNotifierProvider).asData!.value[post.userId];
    if (user == null) return const SizedBox();
    if (user.accountStatus != AccountStatus.normal) return const SizedBox();

    final heartAnimationNotifier = ref.read(
      heartAnimationNotifierProvider,
    );
    final canvasTheme = user.canvasTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.createdAt.xxAgo,
            style: textStyle.w600(
              fontSize: 24,
              color: canvasTheme.profileAboutMeColor,
            ),
          ),
          const Gap(4),
          GestureDetector(
            onTap: () {
              ref
                  .read(navigationRouterProvider(context))
                  .goToCurrentStatusPost(post, user);
            },
            onDoubleTapDown: (details) {
              ref
                  .read(allCurrentStatusPostsNotifierProvider.notifier)
                  .incrementLikeCount(user, post);
              heartAnimationNotifier.showHeart(
                context,
                details.globalPosition.dx,
                details.globalPosition.dy,
                (details.globalPosition.dy - details.localPosition.dy),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: canvasTheme.boxBgColor,
                borderRadius: BorderRadius.circular(
                  canvasTheme.boxRadius,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 12, left: 12, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // list
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.after.tags
                                    .where((tag) =>
                                        !post.before.tags.contains(tag))
                                    .isNotEmpty ||
                                post.after.tags.length !=
                                    post.before.tags.length)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        "タグ : ",
                                        style: textStyle.w600(
                                            color: canvasTheme.boxTextColor),
                                      ),
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: Wrap(
                                        children: post.after.tags
                                            .map(
                                              (tag) => Container(
                                                margin: const EdgeInsets.all(4),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2),
                                                  child: Text(
                                                    tag,
                                                    style: textStyle.w600(
                                                        color: canvasTheme
                                                            .boxTextColor),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (post.after.doing != post.before.doing &&
                                post.after.doing.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      "してること",
                                      style: textStyle.w600(
                                          color: canvasTheme.boxTextColor),
                                    ),
                                    const Gap(8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                      child: Text(
                                        post.after.doing,
                                        style: textStyle.w600(
                                          color:
                                              canvasTheme.boxSecondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (post.after.eating != post.before.eating &&
                                post.after.eating.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      "食べてる",
                                      style: textStyle.w600(
                                          color: canvasTheme.boxTextColor),
                                    ),
                                    const Gap(8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                      child: Text(
                                        post.after.eating,
                                        style: textStyle.w600(
                                          color:
                                              canvasTheme.boxSecondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (post.after.mood != post.before.mood &&
                                post.after.mood.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      "気分",
                                      style: textStyle.w600(
                                          color: canvasTheme.boxTextColor),
                                    ),
                                    const Gap(8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                      child: Text(
                                        post.after.mood,
                                        style: textStyle.w600(
                                          color:
                                              canvasTheme.boxSecondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (post.after.nowAt != post.before.nowAt &&
                                post.after.nowAt.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      "場所",
                                      style: textStyle.w600(
                                          color: canvasTheme.boxTextColor),
                                    ),
                                    const Gap(8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                      child: Text(
                                        post.after.nowAt,
                                        style: textStyle.w600(
                                          color:
                                              canvasTheme.boxSecondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (post.after.nextAt != post.before.nextAt &&
                                post.after.nextAt.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      "次の場所",
                                      style: textStyle.w600(
                                          color: canvasTheme.boxTextColor),
                                    ),
                                    const Gap(8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                      child: Text(
                                        post.after.nextAt,
                                        style: textStyle.w600(
                                          color:
                                              canvasTheme.boxSecondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (post.after.nowWith
                                .where(
                                    (id) => !post.before.nowWith.contains(id))
                                .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      "一緒にいる人",
                                      style: textStyle.w600(
                                          color: canvasTheme.boxTextColor),
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: FutureBuilder(
                                        future: ref
                                            .read(allUsersNotifierProvider
                                                .notifier)
                                            .getUserAccounts(
                                                post.after.nowWith),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const SizedBox();
                                          }
                                          final users = snapshot.data!;

                                          return Wrap(
                                            children: users
                                                .map(
                                                  (user) => Container(
                                                    margin:
                                                        const EdgeInsets.all(4),
                                                    child: UserIconSmallIcon(
                                                      user: user,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  /* _buildPostBottomSection(
                    context,
                    ref,
                    post,
                    user,
                  ), */
                  const Gap(16),
                ],
              ),
            ),
          ),
          //if (post.isHost)
          if (user.userId == ref.read(authProvider).currentUser!.uid &&
              post.seenUserIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 24,
                child: FutureBuilder(
                    future: ref
                        .read(allUsersNotifierProvider.notifier)
                        .getUserAccounts(post.seenUserIds),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.seenUserIds.length,
                        itemBuilder: (context, index) {
                          final userId = post.seenUserIds[index];
                          final e = ref
                              .read(allUsersNotifierProvider)
                              .asData!
                              .value[userId]!;
                          return Container(
                            padding: const EdgeInsets.only(right: 4),
                            child: UserIconMiniIcon(
                              user: e,
                            ),
                          );
                        },
                      );
                    }),
              ),
            ),
        ],
      ),
    );
  }
}
 */
