import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/components/transition/fade_transition_widget.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/routes/page_transition.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/presentation/pages/user/post_images_screen.dart';
import 'package:app/presentation/providers/heart_animation_notifier.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomPostWidget extends ConsumerWidget {
  const CustomPostWidget({
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
    final canvasTheme = user.canvasTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: GestureDetector(
        onTap: () {
          ref.read(navigationRouterProvider(context)).goToPost(post, user);
        },
        onDoubleTapDown: (details) {
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
        child: Container(
          decoration: BoxDecoration(
            color: canvasTheme.boxBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
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
                    UserIconPostIcon(user: user),
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
                                        color: canvasTheme.boxTextColor,
                                        fontSize: 14,
                                        height: 1.0,
                                      ),
                                    ),
                                    const Gap(4),
                                    if (postPrivacyMode)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Icon(
                                          size: 12,
                                          post.isPublic
                                              ? Icons.public_outlined
                                              : Icons.lock_outline,
                                          color: canvasTheme.boxTextColor,
                                        ),
                                      ),
                                    const Expanded(child: SizedBox()),
                                    Text(
                                      post.createdAt.xxAgo,
                                      style: textStyle.w400(
                                        fontSize: 12,
                                        color: canvasTheme.boxTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(4),
                                if (post.text != null)
                                  BuildText(
                                    text: post.text!,
                                    canvasTheme: user.canvasTheme,
                                  ),
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
    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
        right: 12,
      ),
      child: SizedBox(
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Gap(12 + 44.4 + 8),
            Expanded(
              child: Row(
                children: [
                  if (post.likeCount > 0)
                    Row(
                      children: [
                        GradientText(
                          text: post.likeCount.toString(),
                        ),
                        const Gap(8),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            color: user.canvasTheme.boxTextColor,
                            size: 20,
                          ),
                        ),
                        const Gap(60),
                        /*
                    Text(
                      "いいね",
                      style: textStyle.w600(color: ThemeColor.subText),
                    ),
                    */
                      ],
                    ),
                  if (post.replyCount > 0)
                    GestureDetector(
                      onTap: () {
                        PostBottomModelSheet(context).openReplies(user, post);
                      },
                      child: Row(
                        children: [
                          Text(
                            post.replyCount.toString(),
                            style: textStyle.numText(
                              fontSize: 16,
                              color: user.canvasTheme.boxTextColor,
                            ),
                          ),
                          const Gap(8),
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: SvgPicture.asset(
                              "assets/images/icons/chat.svg",
                              color: user.canvasTheme.boxTextColor,
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
              child: Icon(
                Icons.more_horiz_rounded,
                color: user.canvasTheme.boxTextColor,
                size: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}

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
        style: textStyle.w600(fontSize: 16),
      ),
    );
  }
}

class BuildText extends ConsumerWidget {
  const BuildText({
    super.key,
    required this.text,
    required this.canvasTheme,
  });
  final String text;
  final CanvasTheme canvasTheme;

  // URLを検出する正規表現パターン
  static final urlPattern = RegExp(
    r'https?:\/\/([\w-]+\.)+[\w-]+(\/[\w- .\/?%&=]*)?',
    caseSensitive: false,
  );

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
    // 文字数制限を適用

    // URLとテキストを分割
    final spans = <TextSpan>[];
    var start = 0;

    for (final match in urlPattern.allMatches(text)) {
      // URL前のテキスト
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: textStyle.w400(fontSize: 14),
        ));
      }

      // URL部分
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: textStyle.w400(
            color: Colors.blue,
            fontSize: 14,
            underline: true,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
        ),
      );

      start = match.end;
    }

    // 残りのテキスト
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: textStyle.w400(
            fontSize: 14,
            color: canvasTheme.boxSecondaryTextColor,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
