import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/user_bottomsheet.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/dialogs/dialogs.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class UserRequestWidget extends ConsumerWidget {
  const UserRequestWidget({super.key, required this.user});
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final mutualIds = ref.read(relationNotifier).getMutualIds(user.userId);

    final shorten = mutualIds.length > 2;
    final requests =
        ref.watch(friendRequestIdListNotifierProvider).asData?.value ?? [];
    final requesteds =
        ref.watch(friendRequestedIdListNotifierProvider).asData?.value ?? [];

    if (requesteds.contains(user.userId)) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(navigationRouterProvider(context)).goToProfile(user);
        },
        child: Container(
          height: 92,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              UserIcon.tileIcon(user, width: 72),
              const Gap(12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(4),
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
                      "@" + user.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeColor.subText,
                        height: 1,
                      ),
                    ),
                    const Gap(4),
                    /* SizedBox(
                      height: 36,
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Material(
                                color: Colors.pink,
                                child: InkWell(
                                  splashColor: Colors.black.withOpacity(0.3),
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    ref
                                        .read(
                                            friendRequestedIdListNotifierProvider
                                                .notifier)
                                        .admitFriendRequested(user);
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: Text(
                                        "承認",
                                        style: textStyle.w600(
                                          fontSize: 14,
                                          color: ThemeColor.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Material(
                                color: Colors.white.withOpacity(0.1),
                                child: InkWell(
                                  splashColor: Colors.black.withOpacity(0.3),
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return showDeleteRequestDialog(
                                            context, ref, user);
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: Text(
                                        "削除",
                                        style: textStyle.w600(
                                          fontSize: 14,
                                          color: ThemeColor.text,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ), */
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (requests.contains(user.userId)) {
      return Container(
        height: 92,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(navigationRouterProvider(context)).goToProfile(user);
              },
              child: UserIcon.tileIcon(user, width: 72),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(4),
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
                  const SizedBox(
                    height: 24,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "リクエスト済み",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const Gap(4),
                  SizedBox(
                    height: 36,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Material(
                        color: Colors.white.withOpacity(0.1),
                        child: InkWell(
                          splashColor: Colors.black.withOpacity(0.3),
                          highlightColor: Colors.transparent,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return showQuitRequestDialog(
                                    context, ref, user);
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Text(
                                "キャンセル",
                                style: textStyle.w600(
                                  fontSize: 14,
                                  color: ThemeColor.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 92,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(navigationRouterProvider(context)).goToProfile(user);
            },
            child: UserIcon.tileIcon(user, width: 72),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(4),
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
                SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      Wrap(
                        children: (shorten
                                ? mutualIds.toList().sublist(0, 2)
                                : mutualIds)
                            .map((userId) {
                          final user = ref
                              .read(allUsersNotifierProvider)
                              .asData!
                              .value[userId]!;
                          return Container(
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
                          );
                        }).toList(),
                      ),
                      const Gap(4),
                      Text(
                        "共通の友達${mutualIds.length}人",
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(4),
                SizedBox(
                  height: 36,
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Material(
                            color: Colors.pink,
                            child: InkWell(
                              splashColor: Colors.black.withOpacity(0.3),
                              highlightColor: Colors.transparent,
                              onTap: () {
                                ref
                                    .read(friendRequestIdListNotifierProvider
                                        .notifier)
                                    .sendFriendRequest(user);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Text(
                                    "リクエスト",
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Material(
                            color: Colors.white.withOpacity(0.1),
                            child: InkWell(
                              splashColor: Colors.black.withOpacity(0.3),
                              highlightColor: Colors.transparent,
                              onTap: () {
                                ref
                                    .read(
                                        deletesIdListNotifierProvider.notifier)
                                    .deleteUser(user);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Text(
                                    "削除",
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      color: ThemeColor.text,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}

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
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    final subscribed = false; // me.subscriptionStatus
    final requests =
        ref.watch(friendRequestIdListNotifierProvider).asData?.value ?? [];
    final requesteds =
        ref.watch(friendRequestedIdListNotifierProvider).asData?.value ?? [];

    if (requesteds.contains(user.userId)) {
      return Column(
        children: [
          Text(
            "フレンドリクエストが届いています",
            style: textStyle.w600(
              fontSize: 12,
              color: user.canvasTheme.profileSecondaryTextColor,
            ),
          ),
          const Gap(12),
          SizedBox(
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Material(
                      color: Colors.pink,
                      child: InkWell(
                        splashColor: Colors.black.withOpacity(0.3),
                        highlightColor: Colors.transparent,
                        onTap: () {
                          if (hasNoMutualFriends && !subscribed) {
                            showUpcomingSnackbar();
                            UserBottomModelSheet(context)
                                .admitNonMutualUserBottomSheet(user);
                            return;
                          }
                          ref
                              .read(friendRequestedIdListNotifierProvider
                                  .notifier)
                              .admitFriendRequested(user);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              "承認",
                              style: textStyle.w600(
                                fontSize: 14,
                                color: ThemeColor.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ClipRRect(
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
                          showDialog(
                            context: context,
                            builder: (context) {
                              return showDeleteRequestDialog(
                                  context, ref, user);
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              "削除",
                              style: textStyle.w600(
                                fontSize: 14,
                                color: ThemeColor.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              showDialog(
                context: context,
                builder: (context) {
                  return showQuitRequestDialog(context, ref, user);
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 48),
              child: Text(
                "フレンドリクエスト済み",
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.pink,
        child: InkWell(
          splashColor: Colors.black.withOpacity(0.3),
          highlightColor: Colors.transparent,
          onTap: () {
            ref
                .read(friendRequestIdListNotifierProvider.notifier)
                .sendFriendRequest(user);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 48),
            child: Text(
              "リクエスト",
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
