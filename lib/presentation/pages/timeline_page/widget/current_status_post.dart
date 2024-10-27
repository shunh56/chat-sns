import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/widgets/right_message.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/notifier/heart_animation_notifier.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class CurrentStatusPostWidget extends ConsumerWidget {
  const CurrentStatusPostWidget({
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

    final heartAnimationNotifier = ref.read(heartAnimationNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GestureDetector(
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
            color: ThemeColor.accent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeColor.stroke,
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserIconPostIcon(user: user),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // name time
                          Row(
                            children: [
                              Text(
                                user.name,
                                style: textStyle.w600(fontSize: 16),
                              ),
                              const Gap(4),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: SvgPicture.asset(
                                    "assets/images/icons/edit.svg",
                                    color: ThemeColor.white,
                                  ),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                "・${post.createdAt.xxAgo}",
                                style: textStyle.w600(
                                  fontSize: 12,
                                  color: ThemeColor.subText,
                                ),
                              ),
                            ],
                          ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          "タグ : ",
                                          style: textStyle.w600(),
                                        ),
                                      ),
                                      const Gap(8),
                                      Expanded(
                                        child: Wrap(
                                          children: post.after.tags
                                              .map(
                                                (tag) => Container(
                                                  margin:
                                                      const EdgeInsets.all(4),
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                                      style: textStyle.w600(),
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
                                        style: textStyle.w600(),
                                      ),
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          post.after.doing,
                                          style: textStyle.w600(
                                            color: ThemeColor.background,
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
                                        style: textStyle.w600(),
                                      ),
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          post.after.eating,
                                          style: textStyle.w600(
                                            color: ThemeColor.background,
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
                                        style: textStyle.w600(),
                                      ),
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          post.after.mood,
                                          style: textStyle.w600(
                                            color: ThemeColor.background,
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
                                        style: textStyle.w600(),
                                      ),
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          post.after.nowAt,
                                          style: textStyle.w600(
                                            color: ThemeColor.background,
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
                                        style: textStyle.w600(),
                                      ),
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          post.after.nextAt,
                                          style: textStyle.w600(
                                            color: ThemeColor.background,
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
                                        style: textStyle.w600(),
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
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Column(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        9),
                                                            child: SizedBox(
                                                              height: 32,
                                                              width: 32,
                                                              child:
                                                                  UserIconSmallIcon(
                                                                user: user,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
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
                  ],
                ),
              ),
              _buildPostBottomSection(
                context,
                ref,
                post,
                user,
              ),
              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }

  _buildPostBottomSection(
    BuildContext context,
    WidgetRef ref,
    CurrentStatusPost post,
    UserAccount user,
  ) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 12,
      ),
      child: SizedBox(
        height: 24,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (post.replyCount > 0)
              Row(
                children: [
                  Text(
                    post.replyCount.toString(),
                    style: textStyle.numText(fontSize: 16),
                  ),
                  const Gap(4),
                  Text(
                    "件の反応",
                    style: textStyle.w600(color: ThemeColor.subText),
                  ),
                ],
              ),
            if (post.likeCount > 0)
              Row(
                children: [
                  const Gap(18),
                  GradientText(
                    text: post.likeCount.toString(),
                  ),
                  const Gap(4),
                  Text(
                    "いいね",
                    style: textStyle.w600(color: ThemeColor.subText),
                  ),
                ],
              ),
            const Gap(18),
            GestureDetector(
              onTap: () {
                PostBottomModelSheet(context)
                    .openCurrentStatusPostAction(post, user);
              },
              child: const Icon(
                Icons.more_horiz_rounded,
                color: ThemeColor.subText,
                size: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CurrentStatusDmWidget extends ConsumerWidget {
  const CurrentStatusDmWidget(
      {super.key, required this.post, required this.user});
  final CurrentStatusPost post;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return GestureDetector(
      onTap: () {
        ref
            .read(navigationRouterProvider(context))
            .goToCurrentStatusPost(post, user);
      },
      child: Container(
        width: themeSize.screenWidth * 0.6,
        padding: const EdgeInsets.only(
          top: 12,
          left: 12,
          right: 12,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: ThemeColor.accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.createdAt.toDateStr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Gap(4),
            if (post.after.tags
                    .where((tag) => !post.before.tags.contains(tag))
                    .isNotEmpty ||
                post.after.tags.length != post.before.tags.length)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "タグ : ",
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Wrap(
                        children: post.after.tags
                            .map(
                              (tag) => Container(
                                margin:
                                    const EdgeInsets.only(right: 4, bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
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
                    const Text(
                      "してること",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.text,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Gap(8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          post.after.doing,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeColor.background,
                            fontWeight: FontWeight.w400,
                          ),
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
                    const Text(
                      "食べてる : ",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.text,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Gap(8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          post.after.eating,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeColor.background,
                            fontWeight: FontWeight.w400,
                          ),
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
                    const Text(
                      "気分 : ",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.text,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Gap(8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          post.after.mood,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeColor.background,
                            fontWeight: FontWeight.w400,
                          ),
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
                    const Text(
                      "場所 : ",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.text,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Gap(8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          post.after.nowAt,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeColor.background,
                            fontWeight: FontWeight.w400,
                          ),
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
                    const Text(
                      "次の場所 : ",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.text,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Text(
                        post.after.nextAt,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColor.background,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (post.after.nowWith
                .where((id) => !post.before.nowWith.contains(id))
                .isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Text(
                      "一緒にいる人 : ",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.text,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Gap(8),
                    Flexible(
                      child: FutureBuilder(
                        future: ref
                            .read(allUsersNotifierProvider.notifier)
                            .getUserAccounts(post.after.nowWith),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }
                          final users = snapshot.data!;

                          return Wrap(
                            children: users
                                .map(
                                  (user) => Container(
                                    margin: const EdgeInsets.all(4),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          child: Container(
                                            color: ThemeColor.accent,
                                            height: 32,
                                            width: 32,
                                            child: user.imageUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl: user.imageUrl!,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 120),
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      height: 32,
                                                      width: 32,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            const SizedBox(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const SizedBox(),
                                                  )
                                                : const Icon(
                                                    Icons.person_outline,
                                                    size: 32 * 0.8,
                                                    color: ThemeColor.stroke,
                                                  ),
                                          ),
                                        ),
                                      ],
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
      ),
    );
  }
}
