/*import 'dart:math';

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
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/notifier/heart_animation_notifier.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class FriendFriendsPostWidget extends ConsumerWidget {
  const FriendFriendsPostWidget(
      {super.key, required this.postRef, required this.user});
  final Post postRef;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.read(allPostsNotifierProvider).asData!.value[postRef.id]!;
    if (user.privacy.contentRange == PublicityRange.onlyFriends) {
      return const SizedBox();
    }
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final heartAnimationNotifier = ref.read(
      heartAnimationNotifierProvider,
    );
    final mutualIds =
        ref.watch(friendsGraphProvider).asData?.value[user.userId] ?? [];
    final friendIds = ref.watch(friendIdsProvider);

    final mutualFriends = ref
        .read(allUsersNotifierProvider)
        .asData!
        .value
        .values
        .where((e) => mutualIds.contains(e.userId))
        .toList();
    mutualFriends.removeWhere((e) => !friendIds.contains(e.userId));
    final shorten = mutualFriends.length > 2;
    final shortenCount = mutualFriends.length - 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GestureDetector(
        onTap: () {
          ref.read(navigationRouterProvider(context)).goToPost(post, user);
        },
        onDoubleTapDown: (details) {
          HapticFeedback.mediumImpact();
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
                padding: const EdgeInsets.only(left: 10, top: 12),
                child: Row(
                  children: [
                    Wrap(
                      children: (shorten
                              ? mutualFriends.sublist(0, 2)
                              : mutualFriends)
                          .map(
                            (user) => Container(
                              margin: const EdgeInsets.all(2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  color: ThemeColor.stroke,
                                  height: 20,
                                  width: 20,
                                  child: user.imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: user.imageUrl!,
                                          fadeInDuration:
                                              const Duration(milliseconds: 120),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            height: 20,
                                            width: 20,
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
                                          errorWidget: (context, url, error) =>
                                              const SizedBox(),
                                        )
                                      : const Icon(
                                          Icons.person_outline,
                                          size: 20 * 0.8,
                                          color: ThemeColor.accent,
                                        ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const Gap(4),
                    Text(
                      shorten
                          ? "${mutualFriends.sublist(0, 2).map((user) => user.name).toList().join("、")} 他$shortenCount人 の友達"
                          : "${mutualFriends.map((user) => user.name).toList().join("、")} の友達",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserIconPostIcon(user: user),
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
                          //tag: 'imageHero-${post.mediaUrls[0]}',
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
                                //tag: 'imageHero-${post.mediaUrls[0]}',
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
                PostBottomModelSheet(context).openReplies(user, post);
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
 */
