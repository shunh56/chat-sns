import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
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
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final post = ref.watch(allPostsNotifierProvider).asData!.value[postRef.id]!;
    final controller = ref.watch(controllerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${user.name}の投稿",
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildPostSection(context, ref, post),
                Divider(
                  height: 0,
                  thickness: 0.8,
                  color: ThemeColor.white.withOpacity(0.3),
                ),
                _buildPostBottomSection(context, ref, post),
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
            decoration: BoxDecoration(
              color: ThemeColor.highlight.withOpacity(0.3),
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                PostBottomModelSheet(context).openReplies(post);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                decoration: BoxDecoration(
                  color: ThemeColor.background,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  "メッセージを入力",
                ),
              ),
            ),
            /*Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 6,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      ref.read(inputTextProvider.notifier).state = value;
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        ref
                            .read(allPostsNotifierProvider.notifier)
                            .addReply(post, value);
                        controller.clear();
                        ref.read(inputTextProvider.notifier).state = "";
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "メッセージを入力",
                      filled: true,
                      isDense: true,
                      fillColor: ThemeColor.background,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: ThemeColor.highlight,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                    ),
                  ),
                ),
                ref.watch(inputTextProvider).isNotEmpty
                    ? GestureDetector(
                        onTap: () async {
                          String text = ref.read(inputTextProvider);
                          ref
                              .read(allPostsNotifierProvider.notifier)
                              .addReply(post, text);
                          showMessage("メッセージを送信しました。");
                          controller.clear();
                          ref.read(inputTextProvider.notifier).state = "";
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
            ), */
          ),
        ],
      ),
    );
  }

  _buildPostSection(BuildContext context, WidgetRef ref, Post post) {
    return Column(
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
                  ref.read(navigationRouterProvider(context)).goToProfile(user);
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
                          const Gap(4),
                          Row(
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: ThemeColor.text,
                                  fontWeight: FontWeight.w500,
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ThemeColor.subText,
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          Text(
                            post.text,
                            style: const TextStyle(
                              fontSize: 16,
                              color: ThemeColor.text,
                              fontWeight: FontWeight.w400,
                            ),
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
        const Gap(8),
      ],
    );
  }

  _buildImages(BuildContext context, Post post) {
    if ((post.mediaUrls.isNotEmpty)) {
      return (post.mediaUrls.length == 1)
          ? Container(
              width: MediaQuery.sizeOf(context).width,
              margin: const EdgeInsets.only(
                top: 8,
                left: 12 + 48 + 12,
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
                  left: 12 + 48 + 12,
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
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
                    style: const TextStyle(
                      color: ThemeColor.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  const Text(
                    "コメント",
                    style: TextStyle(
                      color: ThemeColor.subText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
          const Icon(
            Icons.more_horiz_rounded,
            color: ThemeColor.subText,
            size: 20,
          )
        ],
      ),
    );
  }
}
