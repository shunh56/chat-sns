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
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/sub_pages/post_images_screen.dart';
import 'package:app/presentation/pages/timeline_page/timeline_page.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/pages/timeline_page/widget/reply_widget.dart';
import 'package:app/presentation/providers/notifier/heart_animation_notifier.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/provider/posts/replies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${user.name}の投稿",
          style: textStyle.appbarText(isSmall: true),
        ),
      ),
      body: Stack(
        children: [
          Column(
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
                          hintText: "メッセージを入力",
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
          const HeartAnimationArea(),
        ],
      ),
    );
  }

  _buildPostSection(BuildContext context, WidgetRef ref, Post post) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final heartAnimationNotifier = ref.read(heartAnimationNotifierProvider);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTapDown: (details) {
        ref
            .read(allPostsNotifierProvider.notifier)
            .incrementLikeCount(user, post);
        heartAnimationNotifier.showHeart(
          context,
          details.globalPosition.dx,
          details.globalPosition.dy - themeSize.appbarHeight,
          (details.globalPosition.dy -
              themeSize.appbarHeight -
              details.localPosition.dy),
        );
      },
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
                            const Gap(4),
                            Row(
                              children: [
                                Text(
                                  user.name,
                                  style: textStyle.w600(
                                    fontSize: 15,
                                    height: 1.0,
                                  ),
                                ),
                                const Gap(4),
                                Icon(
                                  size: 12,
                                  post.isPublic
                                      ? Icons.public_outlined
                                      : Icons.lock_outline,
                                  color: Colors.white,
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
                            BuildText(text: post.text)
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
          const Gap(8),
        ],
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
                left: 12 + 40 + 12,
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
                  left: 12 + 40 + 12,
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
        bottom: 8,
      ),
      child: Row(
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
                Text(
                  "コメント",
                  style: textStyle.w600(color: ThemeColor.subText),
                ),
              ],
            ),
          if (post.likeCount > 0)
            Row(
              children: [
                const Gap(12),
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
          const Gap(12),
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
              color: ThemeColor.subText,
              size: 20,
            ),
          )
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
