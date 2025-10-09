import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/pages/chat_request/send_chat_request_helper.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/follow/followers_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class UserRequestWidget extends ConsumerWidget {
  const UserRequestWidget({super.key, required this.user, this.padding = 12.0});
  final UserAccount user;
  final double padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowing = ref.watch(isFollowingProvider(user.userId));
    final isFollower = ref.watch(isFollowerProvider(user.userId));
    final isMutual = isFollowing && isFollower;

    return InkWell(
      onTap: () {
        ref.read(navigationRouterProvider(context)).goToProfile(user);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ThemeColor.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                UserIcon(
                  user: user,
                  r: 28,
                ),
                if (isMutual)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemeColor.accent,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColor.text,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMutual) ...[
                        const Gap(4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '相互',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Gap(2),
                  Text(
                    "@${user.username}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: ThemeColor.subText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.aboutMe.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      user.aboutMe,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColor.subText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Gap(8),
            Column(
              children: [
                if (!user.isMe) ...[
                  _buildFollowButton(user, isFollowing, isFollower),
                  const Gap(6),
                  _buildMessageButton(context, ref, user),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(
      UserAccount user, bool isFollowing, bool isFollower) {
    return Consumer(
      builder: (context, ref, child) {
        final themeSize = ref.watch(themeSizeProvider(context));
        final textStyle = ThemeTextStyle(themeSize: themeSize);
        final notifier = ref.read(followingListNotifierProvider.notifier);

        // フォローしていない && 相手がフォロワー = フォローバック
        final isFollowBack = !isFollowing && isFollower;

        if (isFollowing) {
          // フォロー中の場合
          return OutlinedButton(
            onPressed: () => notifier.unfollowUser(user),
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColor.text,
              side: BorderSide(
                color: ThemeColor.stroke.withOpacity(0.5),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(80, 32),
            ),
            child: Text(
              'フォロー中',
              style: textStyle.w600(fontSize: 12),
            ),
          );
        } else {
          // 未フォローの場合
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFollowBack
                    ? [Colors.green.shade400, Colors.teal.shade400]
                    : [ThemeColor.highlight, Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isFollowBack ? Colors.green : ThemeColor.highlight)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => notifier.followUser(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(80, 32),
              ),
              child: Text(
                isFollowBack ? 'フォロバ' : 'フォロー',
                style: textStyle.w600(fontSize: 12),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMessageButton(
      BuildContext context, WidgetRef ref, UserAccount user) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: ThemeColor.background.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: ThemeColor.stroke.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(
          Icons.chat_bubble_outline,
          size: 16,
          color: ThemeColor.text,
        ),
        onPressed: () {
          SendChatRequestHelper.startChatOrRequest(
            context: context,
            ref: ref,
            targetUserId: user.userId,
          );
        },
      ),
    );
  }
}

//user profile screen
class UserRequestButton extends ConsumerWidget {
  const UserRequestButton({
    super.key,
    required this.user,
    required this.hasNoMutualFriends,
  });
  final UserAccount user;
  final bool hasNoMutualFriends;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    //const subscribed = false;
    final requests = []; // ref.watch(requestIdsProvider);
    final requesteds = []; // ref.watch(requestedIdsProvider);

    final privateMode = user.privacy.privateMode;
    final range = user.privacy.requestRange;

    if (requesteds.contains(user.userId)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Color.alphaBlend(
            Colors.white.withOpacity(0.1),
            ThemeColor.accent,
          ),
          child: InkWell(
            splashColor: Colors.black.withOpacity(0.3),
            highlightColor: Colors.transparent,
            onTap: () {
              /*showDialog(
                context: context,
                builder: (context) =>
                    showFriendRequestDialog(context, ref, user),
              ); */
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: Text(
                "リクエストが届いています",
                style: textStyle.w600(
                  fontSize: 14,
                  color: ThemeColor.text,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (requests.contains(user.userId)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Color.alphaBlend(
            Colors.white.withOpacity(0.1),
            ThemeColor.accent,
          ),
          child: InkWell(
            splashColor: Colors.black.withOpacity(0.3),
            highlightColor: Colors.transparent,
            onTap: () {
              /* showDialog(
                context: context,
                builder: (context) {
                  return showQuitRequestDialog(context, ref, user);
                },
              ); */
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: Text(
                "リクエスト済み",
                style: textStyle.w600(
                  fontSize: 14,
                  color: ThemeColor.text,
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (privateMode ||
        (range == PublicityRange.friendOfFriend && !hasNoMutualFriends) ||
        (range == PublicityRange.onlyFriends)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Color.alphaBlend(
            Colors.white.withOpacity(0.1),
            ThemeColor.accent,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Text(
              "プライベートモード",
              style: textStyle.w600(
                fontSize: 14,
                color: ThemeColor.text,
              ),
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.pink,
        child: InkWell(
          splashColor: Colors.black.withOpacity(0.3),
          highlightColor: Colors.transparent,
          onTap: () {
            // ref.read(relationUsecaseProvider).sendRequest(user.userId);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Text(
              "フレンドリクエスト",
              style: textStyle.w600(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FriendRequestDialog extends ConsumerWidget {
  const FriendRequestDialog({
    super.key,
    required this.user,
  });

  final UserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'フレンドリクエスト',
              style: textStyle.w600(
                fontSize: 18,
                color: ThemeColor.text,
              ),
            ),
            const Gap(16),
            Text(
              '${user.name}さんからフレンドリクエストが届いています。',
              textAlign: TextAlign.center,
              style: textStyle.w400(
                fontSize: 14,
                color: ThemeColor.text,
              ),
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      /*ref
                          .read(relationUsecaseProvider)
                          .deleteRequested(user.userId);
                      ref
                          .read(deletesIdListNotifierProvider.notifier)
                          .deleteUser(user); */
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: ThemeColor.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '削除',
                      style: textStyle.w600(
                        fontSize: 14,
                        color: ThemeColor.text,
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      /* ref.read(friendsUsecaseProvider).addFriend(user.userId);
                      ref
                          .read(relationUsecaseProvider)
                          .deleteRequested(user.userId); */
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '承認',
                      style: textStyle.w600(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
