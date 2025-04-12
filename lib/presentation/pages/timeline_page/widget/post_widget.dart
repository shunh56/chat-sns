import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/sub_pages/post_images_screen.dart';
import 'package:app/presentation/providers/notifier/heart_animation_notifier.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class PostWidget extends ConsumerWidget {
  const PostWidget({
    super.key,
    required this.postRef,
  });
  final Post postRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final post = ref.watch(allPostsNotifierProvider).asData!.value[postRef.id];
    if (post == null) return const SizedBox();
    final user = ref.read(allUsersNotifierProvider).asData!.value[post.userId];
    if (user == null) return const SizedBox();
    if (user.accountStatus != AccountStatus.normal) return const SizedBox();
    if (post.isDeletedByUser ||
        post.isDeletedByModerator ||
        post.isDeletedByAdmin) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: (){
        ref.read(navigationRouterProvider(context)).goToPost(post, user);
      },
      child: Container(
        margin: const EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: 8,
          right: 8,
        ),
        padding: const EdgeInsets.only(
          top: 12,
          left: 12,
          right: 12,
          bottom: 12,
        ),
        //padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: ThemeColor.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeColor.cardBorderColor,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ユーザー名と時間
      
            Row(
              children: [
                UserIcon(
                  user: user,
                  width: 28,
                  isCircle: true,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: textStyle.w600(
                          fontSize: 12,
                          height: 1.0,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        post.createdAt.xxAgo,
                        style: textStyle.w400(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      
            const Gap(8),
            Text(
              post.title,
              style: textStyle.w700(
                fontSize: 16,
              ),
            ),
            const Gap(6),
            // 投稿テキスト
            if (post.text != null) BuildText(text: post.text!),
      
            // 画像
            if (post.mediaUrls.isNotEmpty) const Gap(8),
            _buildImages(context, post),
            _buildActionButton(context, ref, post, user),
            // アクション
          ],
        ),
      ),
    );
  }

/*  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    required ThemeTextStyle textStyle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF9CA3AF),
          ),
          const Gap(6),
          if (count > 0)
            Text(
              count.toString(),
              style: textStyle.w500(
                fontSize: 13,
                color: const Color(0xFF9CA3AF),
              ),
            ),
        ],
      ),
    );
  } */

  _buildActionButton(
      BuildContext context, WidgetRef ref, Post post, UserAccount user) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final heartAnimationNotifier = ref.read(
      heartAnimationNotifierProvider,
    );
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 12,
      ),
      child: SizedBox(
        height: 24,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTapDown: (details) {
                      ref
                          .read(allPostsNotifierProvider.notifier)
                          .incrementLikeCount(user, post);
                      heartAnimationNotifier.showHeart(
                        context,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        (details.globalPosition.dy - details.localPosition.dy),
                      );
                    },
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            color: ThemeColor.cardSecondaryColor,
                            size: 20,
                          ),
                        ),
                        const Gap(4),
                        SizedBox(
                          width: 48,
                          child: Text(
                            post.likeCount.toString(),
                            style: textStyle.numText(
                              fontSize: 14,
                              color: ThemeColor.cardSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(navigationRouterProvider(context))
                          .goToPost(post, user);
                      //PostBottomModelSheet(context).openReplies(user, post);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: SvgPicture.asset(
                            "assets/images/icons/chat.svg",
                            color: ThemeColor.cardSecondaryColor,
                          ),
                        ),
                        const Gap(8),
                        SizedBox(
                          width: 48,
                          child: Text(
                            post.replyCount.toString(),
                            style: textStyle.numText(
                              fontSize: 14,
                              color: ThemeColor.cardSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                PostBottomModelSheet(context).openPostAction(post, user);
              },
              child: const Icon(
                Icons.more_horiz_rounded,
                color: ThemeColor.cardSecondaryColor,
                size: 20,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImages(BuildContext context, Post post) {
    if (post.mediaUrls.isEmpty) return const SizedBox();

    if (post.mediaUrls.length == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransitionMethods.fadeIn(
              PostImageHero(
                imageUrls: post.mediaUrls,
                aspectRatios: post.aspectRatios,
                initialIndex: 0,
                // tag: 'imageHero-${post.mediaUrls[0]}',
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: post.aspectRatios.isNotEmpty
                ? post.aspectRatios[0] < 1
                    ? min(1 / post.aspectRatios[0], 16 / 9)
                    : max(1 / post.aspectRatios[0], 4 / 5)
                : 16 / 9,
            child: CachedImage.postImage(
              post.mediaUrls[0],
              ms: 100,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: post.mediaUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransitionMethods.fadeIn(
                  PostImageHero(
                    imageUrls: post.mediaUrls,
                    aspectRatios: post.aspectRatios,
                    initialIndex: index,
                    //tag: 'imageHero-${post.mediaUrls[0]}',
                  ),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: EdgeInsets.only(
                  right: index < post.mediaUrls.length - 1 ? 8 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedImage.postImage(
                  post.mediaUrls[index],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/*
class PostWidget extends ConsumerWidget {
  const PostWidget({
    super.key,
    required this.postRef,
  });
  final Post postRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final post = ref.watch(allPostsNotifierProvider).asData!.value[postRef.id];
    if (post == null) return const SizedBox();
    final user = ref.read(allUsersNotifierProvider).asData!.value[post.userId];
    if (user == null) return const SizedBox();
    if (user.accountStatus != AccountStatus.normal) return const SizedBox();
    if (post.isDeletedByUser ||
        post.isDeletedByModerator ||
        post.isDeletedByAdmin) {
      return const SizedBox();
    }

    final heartAnimationNotifier = ref.read(
      heartAnimationNotifierProvider,
    );

    return InkWell(
      onTap: () {
        ref.read(navigationRouterProvider(context)).goToPost(post, user);
      },

      /* onDoubleTapDown: (details) {
      ref
          .read(allPostsNotifierProvider.notifier)
          .incrementLikeCount(user, post);
      heartAnimationNotifier.showHeart(
        context,
        details.globalPosition.dx,
        details.globalPosition.dy,
        (details.globalPosition.dy - details.localPosition.dy),
      );
    }, */
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        /*decoration: BoxDecoration(
          color: ThemeColor.accent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeColor.stroke,
            width: 0.8,
          ),
        ), */
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 12,
                right: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserIcon(
                    user: user,
                    width: 40,
                    isCircle: true,
                  ),
                  // UserIconPostIcon(user: user),
                  const Gap(12),
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
                                    user.name,
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      height: 1.0,
                                    ),
                                  ),
                                  /* const Gap(4),
                                  if (postPrivacyMode)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Icon(
                                        size: 12,
                                        post.isPublic
                                            ? Icons.public_outlined
                                            : Icons.lock_outline,
                                        color: Colors.white,
                                      ),
                                    ), */
                                  const Gap(4),
                                  Text(
                                    "・${post.createdAt.xxAgo}",
                                    style: textStyle.w400(
                                      fontSize: 12,
                                      color: ThemeColor.subText,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              BuildText(text: post.text),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildImages(context, post),
            _buildPostBottomSection(context, ref, post, user),
            const Gap(8),
          ],
        ),
      ),
    );
  }

  _buildImages(BuildContext context, Post post) {
    if ((post.mediaUrls.isNotEmpty)) {
      return (post.mediaUrls.length == 1)
          ? Container(
              width: MediaQuery.sizeOf(context).width,
              margin: const EdgeInsets.only(
                top: 8,
                left: 12 + 44.4 + 8,
                right: 12,
              ),
              child: FadeTransitionWidget(
                child: GestureDetector(
                  onTap: () {
                    /*Navigator.push(
                      context,
                      PageTransitionMethods.fadeIn(
                        PostImageHero(
                          imageUrls: post.mediaUrls,
                          aspectRatios: post.aspectRatios,
                          initialIndex: 0,
                          tag: 'imageHero-${post.mediaUrls[0]}',
                        ),
                      ),
                    ); */
                    Navigator.push(
                      context,
                      PageTransitionMethods.fadeIn(
                        VerticalScrollview(
                          scrollToPopOption: ScrollToPopOption.both,
                          dragToPopDirection: DragToPopDirection.toBottom,
                          child: PostImageHero(
                            imageUrls: post.mediaUrls,
                            aspectRatios: post.aspectRatios,
                            initialIndex: 0,
                            //tag: 'imageHero-${post.mediaUrls[0]}',
                          ),
                        ),
                        /*  */
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    // child: Hero(
                    // tag: 'imageHero-${post.mediaUrls[0]}0',
                    child: Container(
                      width: MediaQuery.sizeOf(context).width -
                          (8 * 2 + 48 + 12 + 4),
                      constraints: BoxConstraints.expand(
                        height: (MediaQuery.sizeOf(context).width - 88) *
                            (post.aspectRatios.isNotEmpty
                                ? min(post.aspectRatios[0], 5 / 4)
                                : 1),
                      ),
                      child: CachedImage.postImage(
                        post.mediaUrls[0],
                        ms: 100,
                      ),
                    ),
                    //  ),
                  ),
                ),
              ),
            )
          : SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: post.mediaUrls.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 12 + 44.4 + 8,
                  right: 4,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FadeTransitionWidget(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransitionMethods.fadeIn(
                              VerticalScrollview(
                                scrollToPopOption: ScrollToPopOption.both,
                                dragToPopDirection: DragToPopDirection.toBottom,
                                child: ImagesView(
                                  imageUrls: post.mediaUrls,
                                  initialIndex: index,
                                ),
                              ),
                              /* PostImageHero(
                                  imageUrls: post.mediaUrls,
                                  aspectRatios: post.aspectRatios,
                                  initialIndex: 0,
                                  tag: 'imageHero-${post.mediaUrls[0]}',
                                ), */
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          // child: Hero(
                          //tag:'imageHero-$index-${post.mediaUrls[index]}$index',
                          child: SizedBox(
                            width: 160,
                            child: CachedImage.postImage(
                              post.mediaUrls[index],
                            ),
                          ),
                          //   ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
    } else {
      return const Gap(0);
    }
  }

  _buildPostBottomSection(
      BuildContext context, WidgetRef ref, Post post, UserAccount user) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final heartAnimationNotifier = ref.read(
      heartAnimationNotifierProvider,
    );
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 12,
      ),
      child: SizedBox(
        height: 24,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Gap(12 + 44.4 + 8),
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTapDown: (details) {
                      ref
                          .read(allPostsNotifierProvider.notifier)
                          .incrementLikeCount(user, post);
                      heartAnimationNotifier.showHeart(
                        context,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        (details.globalPosition.dy - details.localPosition.dy),
                      );
                    },
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            color: ThemeColor.icon,
                            size: 18,
                          ),
                        ),
                        const Gap(8),
                        SizedBox(
                          width: 60,
                          child: Row(
                            children: [
                              (post.likeCount > 0)
                                  ? GradientText(
                                      text: post.likeCount.toString(),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      PostBottomModelSheet(context).openReplies(user, post);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          height: 14,
                          width: 14,
                          child: SvgPicture.asset(
                            "assets/images/icons/chat.svg",
                            color: ThemeColor.icon,
                          ),
                        ),
                        const Gap(8),
                        SizedBox(
                          width: 60,
                          child: Row(
                            children: [
                              (post.replyCount > 0)
                                  ? Text(
                                      post.replyCount.toString(),
                                      style: textStyle.numText(
                                        fontSize: 14,
                                        color: ThemeColor.icon,
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),

                        /* Text(
                        "コメント",
                        style: textStyle.w600(color: ThemeColor.subText),
                      ), */
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                PostBottomModelSheet(context).openPostAction(post, user);
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
*/
class GradientText extends ConsumerWidget {
  const GradientText({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
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
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: textStyle.w600(fontSize: 14),
      ),
    );
  }
}

class BuildText extends ConsumerWidget {
  const BuildText({
    super.key,
    required this.text,
    this.isDynamicSize = false, // 動的サイズの切り替えフラグ
    this.isShort = true,
  });

  final String text;
  final bool isDynamicSize;
  final bool isShort;

  static final urlPattern = RegExp(
    r'https?:\/\/([\w-]+\.)+[\w-]+(\/[\w- .\/?%&=]*)?',
    caseSensitive: false,
  );

  // 固定サイズの設定
  static const TextConfig fixedConfig = TextConfig(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    lineHeight: 1.4,
  );

  // 文字数に応じたテキスト設定を取得
  TextConfig _getDynamicConfig(int length) {
    if (length <= 10) {
      return const TextConfig(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        lineHeight: 1.3,
      );
    } else if (length <= 30) {
      return const TextConfig(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        lineHeight: 1.3,
      );
    } else if (length <= 100) {
      return const TextConfig(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        lineHeight: 1.5,
      );
    } else {
      return const TextConfig(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        lineHeight: 1.5,
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    // テキスト設定の取得
    final textLength = text.replaceAll(urlPattern, '').length;
    final config = isDynamicSize ? _getDynamicConfig(textLength) : fixedConfig;

    final spans = <TextSpan>[];
    var start = 0;

    for (final match in urlPattern.allMatches(text)) {
      // URL前のテキスト
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: textStyle.custom(
            fontSize: config.fontSize,
            fontWeight: config.fontWeight,
            height: config.lineHeight,
            color: Colors.white,
          ),
        ));
      }

      // URL部分
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: textStyle.custom(
            fontSize: isDynamicSize ? min(16.0, config.fontSize - 2) : 14.0,
            fontWeight: FontWeight.w500,
            height: config.lineHeight,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
        ),
      );

      start = match.end;
    }

    // 残りのテキスト
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: textStyle.custom(
          fontSize: config.fontSize,
          fontWeight: config.fontWeight,
          height: config.lineHeight,
          color: Colors.white,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: isShort ? 2 : null,
    );
  }
}

// テキスト設定を保持するクラス
class TextConfig {
  final double fontSize;
  final FontWeight fontWeight;
  final double lineHeight;

  const TextConfig({
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
  });
}
