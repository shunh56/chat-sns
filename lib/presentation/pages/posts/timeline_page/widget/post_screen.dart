import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/pages/main_page/heart_animation_overlay.dart';
import 'package:app/presentation/routes/page_transition.dart';
import 'package:app/presentation/pages/user/post_images_screen.dart';
import 'package:app/presentation/pages/posts/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/pages/posts/timeline_page/widget/reply_widget.dart';
import 'package:app/presentation/providers/heart_animation_notifier.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/posts/replies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final controllerProvider =
    Provider.autoDispose((ref) => TextEditingController());

class PostScreen extends ConsumerWidget {
  const PostScreen({super.key, required this.postRef, required this.user});
  final Post postRef;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final post = ref.watch(allPostsNotifierProvider).asData!.value[postRef.id]!;
    final controller = ref.watch(controllerProvider);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              post.title,
              style: textStyle.w700(
                fontSize: 16,
              ),
            ),
            titleSpacing: 0,
            leading: GestureDetector(
              onTap: () {
                primaryFocus?.unfocus();
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildPostSection(context, ref, post),
                    const Gap(4),
                    const Divider(
                      height: 0,
                      thickness: 0.8,
                      color: ThemeColor.stroke,
                    ),
                    _buildPostBottomSection(context, ref, post),
                    const Divider(
                      height: 0,
                      thickness: 0.8,
                      color: ThemeColor.stroke,
                    ),
                    _buildPostRepliesList(context, ref, post),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                padding: EdgeInsets.only(
                  top: 12,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewPadding.bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 6,
                        style: textStyle.w600(
                          fontSize: 14,
                        ),
                        onChanged: (value) {
                          ref.read(inputTextProvider.notifier).state = value;
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            ref
                                .read(allPostsNotifierProvider.notifier)
                                .addReply(user, post, value);
                            controller.clear();
                            ref.read(inputTextProvider.notifier).state = "";
                            primaryFocus?.unfocus();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "コメントを入力",
                          filled: true,
                          isDense: true,
                          fillColor: ThemeColor.stroke,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintStyle: textStyle.w400(
                            color: ThemeColor.subText,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                    ref.watch(inputTextProvider).isNotEmpty
                        ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              String text = ref.read(inputTextProvider);
                              ref
                                  .read(allPostsNotifierProvider.notifier)
                                  .addReply(user, post, text);

                              controller.clear();
                              ref.read(inputTextProvider.notifier).state = "";
                              primaryFocus?.unfocus();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Icon(
                                Icons.send,
                                color: ThemeColor.highlight,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const HeartAnimationArea(),
      ],
    );
  }

  _buildPostSection(BuildContext context, WidgetRef ref, Post post) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        left: 12,
        right: 12,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserIcon(
                user: user,
                width: 40,
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
                        fontSize: 14,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      post.createdAt.xxAgo,
                      style: textStyle.w400(
                        fontSize: 12,
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
          if (post.text != null)
            BuildText(
              text: post.text!,
              isShort: false,
            ),
          if (post.mediaUrls.isNotEmpty) const Gap(8),
          _buildImages(context, post),
        ],
      ),
    );
  }

  _buildImages(BuildContext context, Post post) {
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

  _buildPostBottomSection(BuildContext context, WidgetRef ref, Post post) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final heartAnimationNotifier = ref.read(heartAnimationNotifierProvider);

    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        left: 12,
        right: 12,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
                  // スクロールしてコメントセクションに移動する処理をここに追加できます
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
          GestureDetector(
            onTap: () {
              PostBottomModelSheet(context).openPostAction(
                post,
                user,
                hideComments: true,
              );
            },
            child: const Icon(
              Icons.more_horiz_rounded,
              color: ThemeColor.cardSecondaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  _buildPostRepliesList(BuildContext context, WidgetRef ref, Post post) {
    final asyncValue = ref.watch(postRepliesNotifierProvider(post.id));
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: asyncValue.when(
        data: (list) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final reply = list[index];
              return ReplyWidget(reply: reply);
            },
          );
        },
        error: (e, s) => Text("error : $e, $s"),
        loading: () {
          return const SizedBox();
        },
      ),
    );
  }
}
