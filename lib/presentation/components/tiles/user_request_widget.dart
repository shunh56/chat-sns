import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class UserRequestWidget extends ConsumerWidget {
  const UserRequestWidget({super.key, required this.user, this.padding = 12.0});
  final UserAccount user;
  final double padding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return InkWell(
      onTap: () {
        ref.read(navigationRouterProvider(context)).goToProfile(user);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserIcon(
              user: user,
              width: 48,
              isCircle: true,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ThemeColor.text,
                          height: 1,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        "@${user.username}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildFollowButton(user),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(UserAccount user) {
    if (user.isMe) return const SizedBox();
    return Consumer(
      builder: (context, ref, child) {
        final themeSize = ref.watch(themeSizeProvider(context));
        final textStyle = ThemeTextStyle(themeSize: themeSize);

        final notifier = ref.read(followingListNotifierProvider.notifier);
        final isFollowing = notifier.isFollowing(user.userId);

        return Material(
          color: isFollowing ? Colors.blue : ThemeColor.white,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            onTap: () {
              if (!isFollowing) {
                notifier.followUser(user);
              } else {
                notifier.unfollowUser(user);
              }
            },
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 36,
              width: 96,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  !isFollowing ? 'フォロー' : 'フォロー中',
                  style: textStyle.w600(
                    fontSize: 12,
                    color:
                        isFollowing ? ThemeColor.white : ThemeColor.background,
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

    const subscribed = false;
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
