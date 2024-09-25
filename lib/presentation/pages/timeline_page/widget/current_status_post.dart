import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

class CurrentStatusPostWidgets {
  final BuildContext context;
  final WidgetRef ref;
  final CurrentStatusPost postRef;
  final UserAccount user;

  CurrentStatusPostWidgets(this.context, this.ref, this.postRef, this.user);

  Widget timelinePost() {
    final post = ref
        .watch(allCurrentStatusPostsNotifierProvider)
        .asData!
        .value[postRef.id]!;
    if (post.noNewChange) return const SizedBox();

    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final notifier = ref.read(isHeartVisibleProvider.notifier);
    final isAnimating = ref.watch(isAnimatingProvider);

    final angleNotifier = ref.watch(angleProvider.notifier);
    void shake() async {
      int count = 0;
      while (count < 4) {
        count++;
        angleNotifier.state = (count % 2 == 0) ? pi / 12 : -pi / 12;
        await Future.delayed(Duration(milliseconds: 40 + count * 30));
      }
      angleNotifier.state = 0;
    }

    animateSize() async {
      while (ref.watch(heartSizeProvider) > 20.0) {
        ref.read(heartSizeProvider.notifier).state =
            ref.watch(heartSizeProvider) * 0.95;
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }

    void showHeart(double x, double y, double diff) {
      if (isAnimating) return;

      ref.read(isAnimatingProvider.notifier).state = true;
      shake();
      notifier.state = false;
      ref.read(xPosProvider.notifier).state = x - 24;
      ref.read(yPosProvider.notifier).state = y - 24 - themeSize.appbarHeight;

      Future.delayed(const Duration(milliseconds: 50), () {
        notifier.state = true;
      });

      // 指定の場所に移動するアニメーション
      Future.delayed(
        const Duration(milliseconds: 800),
        () {
          ref.read(xPosProvider.notifier).state =
              themeSize.screenWidth / 2 - 12;
          ref.read(yPosProvider.notifier).state = -24;
          animateSize();
        },
      );

      // アニメーションが終了したらハートを消す
      Future.delayed(const Duration(milliseconds: 1200), () {
        notifier.state = false;
        ref.read(isAnimatingProvider.notifier).state = false;
      });

      Future.delayed(const Duration(milliseconds: 1600), () {
        ref.read(heartSizeProvider.notifier).state = 50.0;
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref
              .read(navigationRouterProvider(context))
              .goToCurrentStatusPost(post, user);
        },
        onDoubleTapDown: (details) {
          HapticFeedback.mediumImpact();
          ref
              .read(allCurrentStatusPostsNotifierProvider.notifier)
              .incrementLikeCount(post);
          showHeart(
            details.globalPosition.dx,
            details.globalPosition.dy,
            (details.globalPosition.dy - details.localPosition.dy),
          );
        },
        child: Container(
          padding: const EdgeInsets.only(
            top: 12,
            left: 12,
            right: 12,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: ThemeColor.accent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                      color: ThemeColor.stroke,
                      width: 0.4,
                    ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(navigationRouterProvider(context))
                          .goToProfile(user);
                    },
                    child: UserIcon.postIcon(user),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.username,
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
                                                          const EdgeInsets.all(
                                                              4),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: Colors.white
                                                            .withOpacity(0.1),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 2),
                                                        child: Text(
                                                          tag,
                                                          style:
                                                              textStyle.w600(),
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
                                            "食べてる : ",
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
                                            "気分 : ",
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
                                            "場所 : ",
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
                                            "次の場所 : ",
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
                                      .where((id) =>
                                          !post.before.nowWith.contains(id))
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        children: [
                                          Text(
                                            "一緒にいる人 : ",
                                            style: textStyle.w600(),
                                          ),
                                          const Gap(8),
                                          FutureBuilder(
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
                                                        margin: const EdgeInsets
                                                            .all(4),
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
                                                                child: UserIcon
                                                                    .tileIcon(
                                                                        user,
                                                                        width:
                                                                            32,
                                                                        ontapped:
                                                                            () {
                                                                  ref
                                                                      .read(navigationRouterProvider(
                                                                          context))
                                                                      .goToProfile(
                                                                          user);
                                                                }),
                                                                /*  CachedNetworkImage(
                                                                  imageUrl: user
                                                                      .imageUrl!,
                                                                  fadeInDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              120),
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
                                                                          Container(
                                                                    height: 32,
                                                                    width: 32,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .transparent,
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const SizedBox(),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const SizedBox(),
                                                                ), */
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
                ],
              ),
              _buildPostBottomSection(context, post),
            ],
          ),
        ),
      ),
    );
  }

  _buildPostBottomSection(
    BuildContext context,
    CurrentStatusPost post,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (post.replyCount > 0)
            Row(
              children: [
                Text(
                  post.replyCount.toString(),
                  style: const TextStyle(
                    color: ThemeColor.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                const Text(
                  "件の反応",
                  style: TextStyle(
                    color: ThemeColor.subText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          if (post.likeCount > 0)
            Row(
              children: [
                const Gap(12),
                GradientText(
                  post.likeCount.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF0064),
                      Color(0xFFFF7600),
                      Color(0xFFFFD500),
                      Color(0xFF8CFE00),
                      Color(0xFF00E86C),
                      Color(0xFF00F4F2),
                      Color(0xFF00CCFF),
                      Color(0xFF70A2FF),
                      Color(0xFFA96CFF),
                    ],
                  ),
                ),
              ],
            ),
          const Gap(12),
          const Icon(
            Icons.more_horiz_rounded,
            color: ThemeColor.subText,
            size: 20,
          )
        ],
      ),
    );
  }

  Widget bottomSheet(CurrentStatusPost post) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref
            .read(navigationRouterProvider(context))
            .goToCurrentStatusPost(post, user);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.only(
          top: 12,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: MediaQuery.sizeOf(context).width / 8,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const Gap(12),
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      ref
                          .read(navigationRouterProvider(context))
                          .goToProfile(user);
                    },
                    child: UserIcon.bottomSheetIcon(user)),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.createdAt.xxAgo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                    Text("${user.username}がステータスを更新しました。"),
                  ],
                ),
              ],
            ),
            const Gap(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.after.tags
                    .where((tag) => !post.before.tags.contains(tag))
                    .isNotEmpty)
                  Row(
                    children: [
                      const Text(
                        "タグ : ",
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: Wrap(
                          children: user.currentStatus.tags
                              .map(
                                (tag) => Container(
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 14,
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
                if (post.after.doing != post.before.doing &&
                    post.after.doing.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Text(
                          "してること",
                          style: TextStyle(
                            fontSize: 14,
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
                            post.after.doing,
                            style: const TextStyle(
                              fontSize: 16,
                              color: ThemeColor.background,
                              fontWeight: FontWeight.w400,
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
                            fontSize: 14,
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
                            post.after.eating,
                            style: const TextStyle(
                              fontSize: 16,
                              color: ThemeColor.background,
                              fontWeight: FontWeight.w400,
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
                            fontSize: 14,
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
                            post.after.mood,
                            style: const TextStyle(
                              fontSize: 16,
                              color: ThemeColor.background,
                              fontWeight: FontWeight.w400,
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
                            fontSize: 14,
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
                            post.after.nowAt,
                            style: const TextStyle(
                              fontSize: 16,
                              color: ThemeColor.background,
                              fontWeight: FontWeight.w400,
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
                          "次の場所",
                          style: TextStyle(
                            fontSize: 14,
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
                              fontSize: 16,
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
                            fontSize: 14,
                            color: ThemeColor.text,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Gap(8),
                        FutureBuilder(
                          future: ref
                              .read(allUsersNotifierProvider.notifier)
                              .getUserAccounts(post.after.nowWith),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }
                            final users = snapshot.data!;
                            if (users.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    "No Top Friends",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }
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
                                            child: SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: CachedNetworkImage(
                                                imageUrl: user.imageUrl!,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 120),
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    const SizedBox(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const SizedBox(),
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
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget dmWidget() {
    final themeSize = ref.watch(themeSizeProvider(context));
    final post = ref
        .watch(allCurrentStatusPostsNotifierProvider)
        .asData!
        .value[postRef.id]!;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref
            .read(navigationRouterProvider(context))
            .goToCurrentStatusPost(post, user);
      },
      child: Container(
        width: themeSize.screenWidth * 0.55,
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
                    Container(
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
                    Container(
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
                    Container(
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
                    Container(
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
                    FutureBuilder(
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
                                        borderRadius: BorderRadius.circular(9),
                                        child: SizedBox(
                                          height: 32,
                                          width: 32,
                                          child: CachedNetworkImage(
                                            imageUrl: user.imageUrl!,
                                            fadeInDuration: const Duration(
                                                milliseconds: 120),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              height: 32,
                                              width: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                const SizedBox(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const SizedBox(),
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
