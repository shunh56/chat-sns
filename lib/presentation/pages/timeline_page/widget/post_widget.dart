import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/components/widgets/fade_transition_widget.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/sub_pages/post_images_screen.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final isHeartVisibleProvider = StateProvider(
  (ref) => false,
);
final angleProvider = StateProvider((ref) => 0.0);
final xPosProvider = StateProvider((ref) => 0.0);
final yPosProvider = StateProvider((ref) => 0.0);
final tyPostProvider = StateProvider((ref) => 0.0);
final heartSizeProvider = StateProvider((ref) => 50.0);
final isAnimatingProvider = StateProvider((ref) => false);
final isPressedProvider = StateProvider((ref) => false);

class PostWidget extends ConsumerWidget {
  const PostWidget({
    super.key,
    required this.postRef,
    required this.user,
  });
  final Post postRef;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(allPostsNotifierProvider).asData!.value[postRef.id]!;
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
          ref.read(navigationRouterProvider(context)).goToPost(post, user);
        },
        onDoubleTapDown: (details) {
          HapticFeedback.mediumImpact();
          ref.read(allPostsNotifierProvider.notifier).incrementLikeCount(post);
          showHeart(
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
              width: 0.4,
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
                                      user.name,
                                      style: textStyle.w600(fontSize: 16),
                                    ),
                                    const Gap(4),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Icon(
                                        size: 12,
                                        post.isPublic
                                            ? Icons.public_outlined
                                            : Icons.lock_outline,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "・${post.createdAt.xxAgo}",
                                      style: textStyle.w600(
                                        fontSize: 12,
                                        color: ThemeColor.subText,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(4),
                                Text(
                                  post.text,
                                  style: textStyle.w400(fontSize: 16),
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
              _buildPostBottomSection(context, ref, post),
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
                    Navigator.push(
                      context,
                      PageTransitionMethods.fadeIn(
                        PostImageHero(
                          imageUrls: post.mediaUrls,
                          aspectRatios: post.aspectRatios,
                          initialIndex: 0,
                          tag: 'imageHero-${post.mediaUrls[0]}',
                        ),
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
                              PostImageHero(
                                imageUrls: post.mediaUrls,
                                aspectRatios: post.aspectRatios,
                                initialIndex: 0,
                                tag: 'imageHero-${post.mediaUrls[0]}',
                              ),
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

  _buildPostBottomSection(BuildContext context, WidgetRef ref, Post post) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (post.replyCount > 0)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                PostBottomModelSheet(context).openReplies(post);
              },
              child: Row(
                children: [
                  Text(
                    post.replyCount.toString(),
                    style: textStyle.numText(fontSize: 16),
                  ),
                  const Gap(4),
                  Text(
                    "コメント",
                    style: textStyle.numText(color: ThemeColor.subText),
                  ),
                ],
              ),
            ),
          if (post.likeCount > 0)
            Row(
              children: [
                const Gap(12),
                GradientText(
                  text: post.likeCount.toString(),
                ),
              ],
            ),
          const Gap(12),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
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
