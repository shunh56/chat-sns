import 'dart:math';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/icons.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/components/widgets/fade_transition_widget.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/sub_pages/user_profile_page/users_friends_screen.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/images/images.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.user});
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final canvasTheme = user.canvasTheme;
    final friendInfos =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];
    final friendIds = friendInfos.map((item) => item.userId);

    if (!friendInfos.map((item) => item.userId).contains(user.userId)) {
      // TODO return not friend screen
      return NotFriendScreen(user: user);
    }
    return Scaffold(
      backgroundColor: canvasTheme.bgColor,
      body: /* NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          debugPrint(notification.runtimeType.toString());
          if (notification is ScrollUpdateNotification) {
            if (notification.dragDetails != null &&
                notification.dragDetails!.primaryDelta != null &&
                notification.dragDetails!.primaryDelta! > 100 &&
                !popped) {
              popped = true;
              Navigator.pop(context);
              return true;
            }
          }
          return false;
        },
        child:*/
          ListView(
        padding: const EdgeInsets.only(
          bottom: 120,
        ),
        children: [
          AppBar(
            forceMaterialTransparency: true,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              //android
              statusBarColor: canvasTheme.bgColor,
              statusBarIconBrightness: Brightness.dark, // => black text
            ),
            iconTheme: IconThemeData(
              color: canvasTheme.profileTextColor,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    color: user.canvasTheme.profileTextColor,
                    fontSize: 24,
                  ),
                ),
                Text(
                  "${user.username}・${user.createdAt.toDateStr}〜",
                  style: TextStyle(
                    color: user.canvasTheme.profileSecondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              if (friendIds.contains(user.userId))
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(navigationRouterProvider(context))
                          .goToChat(user);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    shareIcon,
                    color: Colors.white,
                  ),
                ),
              ),
              const Gap(12),
              (friendInfos.map((item) => item.userId).contains(user.userId))
                  ? FocusedMenuHolder(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                      menuWidth: 120,
                      blurSize: 0,
                      animateMenuItems: false,
                      openWithTap: true,
                      menuBoxDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      menuItems: <FocusedMenuItem>[
                        FocusedMenuItem(
                          backgroundColor: ThemeColor.background,
                          title: const Text(
                            "フレンド解除",
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(friendIdListNotifierProvider.notifier)
                                .deleteFriend(user);
                            ref
                                .read(dmOverviewListNotifierProvider.notifier)
                                .leaveChat(user);
                          },
                        ),
                        FocusedMenuItem(
                          backgroundColor: ThemeColor.background,
                          title: const Text(
                            "報告",
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                          },
                        ),
                        FocusedMenuItem(
                          backgroundColor: ThemeColor.background,
                          title: const Text(
                            "ブロック",
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(blocksListNotifierProvider.notifier)
                                .blockUser(user);
                            ref
                                .read(dmOverviewListNotifierProvider.notifier)
                                .closeChat(user);
                            Navigator.pop(context);
                            showMessage("ユーザーをブロックしました。");
                          },
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : FocusedMenuHolder(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                      menuWidth: 120,
                      blurSize: 0,
                      animateMenuItems: false,
                      openWithTap: true,
                      menuBoxDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      menuItems: <FocusedMenuItem>[
                        FocusedMenuItem(
                          backgroundColor: ThemeColor.background,
                          title: const Text(
                            "フレンド申請",
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(friendRequestIdListNotifierProvider
                                    .notifier)
                                .sendFriendRequest(user);
                          },
                        ),
                        FocusedMenuItem(
                          backgroundColor: ThemeColor.background,
                          title: const Text(
                            "報告",
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                          },
                        ),
                        FocusedMenuItem(
                          backgroundColor: ThemeColor.background,
                          title: const Text(
                            "ブロック",
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(blocksListNotifierProvider.notifier)
                                .blockUser(user);
                            ref
                                .read(dmOverviewListNotifierProvider.notifier)
                                .closeChat(user);
                            Navigator.pop(context);
                            showMessage("ユーザーをブロックしました。");
                          },
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
          const Gap(24),
          _buildIconAndBio(context, ref, canvasTheme, user),
          _buildImages(context, ref, user),
          _buildAboutMe(context, ref, canvasTheme, user),
          _buildCurrentStatus(context, ref, canvasTheme, user),
          _buildTopFriends(context, ref, canvasTheme, user),
          _buildFriends(context, ref, canvasTheme, user),
          // _buildWishList(context, ref, canvasTheme, user),
          // _buildWantToDoList(context, ref, canvasTheme, user),
          // _buildActivities(context, ref, canvasTheme, user),
        ],
      ),
      // ),
    );
  }

  Widget _buildImages(BuildContext context, WidgetRef ref, UserAccount me) {
    final asyncValue = ref.watch(userImagesNotiferProvider(me.userId));
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    const imageHeight = 96.0;

    return asyncValue.when(
      data: (imageUrls) {
        if (imageUrls.isEmpty) return const SizedBox();
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: themeSize.horizontalPadding,
          ),
          child: Column(
            children: [
              box(
                me.canvasTheme,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Photos",
                      style: textStyle.w600(
                        fontSize: 18,
                        color: me.canvasTheme.profileTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
            ],
          ),
        );
      },
      error: (e, s) => Text("error : $e, $s"),
      loading: () => const SizedBox(),
    );
  }

  Widget _buildIconAndBio(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount user) {
    const imageHeight = 80.0;
    final themeSize = ref.watch(themeSizeProvider(context));
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: themeSize.horizontalPadding,
      ),
      child: Column(
        children: [
          //icon bio
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(canvasTheme.iconStrokeWidth),
                    decoration: BoxDecoration(
                      gradient: !canvasTheme.iconHideBorder
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                canvasTheme.iconGradientStartColor,
                                canvasTheme.iconGradientEndColor,
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(
                        canvasTheme.iconRadius + 12,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(12 - canvasTheme.iconStrokeWidth),
                      decoration: BoxDecoration(
                        color: canvasTheme.bgColor,
                        borderRadius: BorderRadius.circular(
                          canvasTheme.iconRadius +
                              12 -
                              canvasTheme.iconStrokeWidth,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(canvasTheme.iconRadius),
                        child: SizedBox(
                          height: imageHeight,
                          width: imageHeight,
                          child: user.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: user.imageUrl!,
                                  fadeInDuration:
                                      const Duration(milliseconds: 120),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    height: imageHeight,
                                    width: imageHeight,
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
                                  size: imageHeight * 0.8,
                                  color: ThemeColor.stroke,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    !canvasTheme.iconHideLevel ? "LEVEL 1" : "",
                    style: TextStyle(
                      color: canvasTheme.profileTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Expanded(
                child: box(
                  canvasTheme,
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "年齢",
                            style: TextStyle(
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            user.bio.age != null
                                ? user.bio.age.toString()
                                : "未設定",
                            style: TextStyle(
                              color: canvasTheme.boxSecondaryTextColor,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "誕生日",
                            style: TextStyle(
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            user.bio.birthday != null
                                ? user.bio.birthday!.toDateStr
                                : "未設定",
                            style: TextStyle(
                              color: canvasTheme.boxSecondaryTextColor,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "性別",
                            style: TextStyle(
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            user.bio.gender == null
                                ? "未設定"
                                : user.bio.gender == "system_male"
                                    ? "男性"
                                    : user.bio.gender == "system_female"
                                        ? "女性"
                                        : user.bio.gender!
                                                .startsWith("system_custom")
                                            ? user.bio.gender!.substring(
                                                13, user.bio.gender!.length)
                                            : "未設定",
                            style: TextStyle(
                              color: canvasTheme.boxSecondaryTextColor,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "興味",
                            style: TextStyle(
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            user.bio.interestedIn == null
                                ? "未設定"
                                : user.bio.interestedIn == "system_male"
                                    ? "男性"
                                    : user.bio.interestedIn == "system_female"
                                        ? "女性"
                                        : user.bio.interestedIn!
                                                .startsWith("system_custom")
                                            ? user.bio.interestedIn!.substring(
                                                13,
                                                user.bio.interestedIn!.length)
                                            : "未設定",
                            style: TextStyle(
                              color: canvasTheme.boxSecondaryTextColor,
                              fontSize: 14,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Gap(12),
        ],
      ),
    );
  }

  Widget _buildAboutMe(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount user) {
    final themeSize = ref.watch(themeSizeProvider(context));
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: themeSize.horizontalPadding,
      ),
      child: Column(
        children: [
          box(
            canvasTheme,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ひとこと",
                  style: TextStyle(
                    fontSize: 16,
                    color: canvasTheme.boxTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Text(
                  user.aboutMe,
                  style: TextStyle(
                    fontSize: 16,
                    color: canvasTheme.boxSecondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount user) {
    final themeSize = ref.watch(themeSizeProvider(context));
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: themeSize.horizontalPadding,
      ),
      child: Column(
        children: [
          box(
            canvasTheme,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "「いま」ボード",
                  style: TextStyle(
                    fontSize: 16,
                    color: canvasTheme.boxTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    children: user.currentStatus.tags
                        .map((tag) => Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.black.withOpacity(0.1),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: canvasTheme.boxSecondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "なにしてる？",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            user.currentStatus.doing,
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "なに食べてる？",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            user.currentStatus.eating,
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "今の気分は？",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            user.currentStatus.mood,
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "どこにいる？",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.currentStatus.nowAt,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: canvasTheme.boxSecondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "next: ${user.currentStatus.nextAt}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: canvasTheme.boxSecondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (user.currentStatus.nowWith.isNotEmpty || true)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            "一緒にいる人",
                            style: TextStyle(
                              fontSize: 14,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: FutureBuilder(
                            future: ref
                                .read(allUsersNotifierProvider.notifier)
                                .getUserAccounts(user.currentStatus.nowWith),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox();
                              }
                              final users = snapshot.data!;
                              return SizedBox(
                                height: 48,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: users
                                      .map(
                                        (user) => Container(
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              color: ThemeColor.accent,
                                              height: 48,
                                              width: 48,
                                              child: user.imageUrl != null
                                                  ? CachedNetworkImage(
                                                      imageUrl: user.imageUrl!,
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  120),
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        height: 48,
                                                        width: 48,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      placeholder:
                                                          (context, url) =>
                                                              const SizedBox(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const SizedBox(),
                                                    )
                                                  : const Icon(
                                                      Icons.person_outline,
                                                      size: 48 * 0.8,
                                                      color: ThemeColor.stroke,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Gap(12),
        ],
      ),
    );
  }

  Widget _buildTopFriends(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount user) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final imageWidth = (themeSize.screenWidth -
                2 * themeSize.horizontalPadding -
                canvasTheme.boxWidth * 2 -
                32) /
            5 -
        8;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: themeSize.horizontalPadding,
      ),
      child: Column(
        children: [
          box(
            canvasTheme,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TOP 10 Friends",
                  style: TextStyle(
                    fontSize: 16,
                    color: canvasTheme.boxTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                FutureBuilder(
                  future: ref
                      .read(allUsersNotifierProvider.notifier)
                      .getUserAccounts(user.topFriends),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }
                    final users = snapshot.data!;
                    if (users.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            "TOPフレンドはいません",
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                    return Wrap(
                      children: users
                          .map(
                            (user) => GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(navigationRouterProvider(context))
                                    .goToProfile(user);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                width: imageWidth,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        color: ThemeColor.accent,
                                        height: imageWidth,
                                        width: imageWidth,
                                        child: user.imageUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: user.imageUrl!,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 120),
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  height: imageWidth,
                                                  width: imageWidth,
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
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const SizedBox(),
                                              )
                                            : Icon(
                                                Icons.person_outline,
                                                size: imageWidth * 0.8,
                                                color: ThemeColor.stroke,
                                              ),
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      user.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            canvasTheme.boxSecondaryTextColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const Gap(12),
        ],
      ),
    );
  }

  Widget _buildFriends(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount user) {
    final themeSize = ref.watch(themeSizeProvider(context));
    const displayCount = 5;
    const imageRadius = 24.0;
    const stroke = 4.0;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: themeSize.horizontalPadding,
      ),
      child: Column(
        children: [
          box(
            canvasTheme,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.name}のフレンド",
                  style: TextStyle(
                    fontSize: 16,
                    color: canvasTheme.boxTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                FutureBuilder(
                  future: ref
                      .read(friendIdListNotifierProvider.notifier)
                      .getFriends(user.userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }
                    final friends = snapshot.data!;
                    final users = friends
                        .where((item) => !user.topFriends.contains(item.userId))
                        .toList();
                    if (users.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            user.topFriends.isNotEmpty
                                ? "TOP10に全てのフレンドがいます"
                                : "フレンドはいません。",
                            style: TextStyle(
                              fontSize: 14,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }

                    List<Widget> stack = [];
                    for (int i = 0; i < min(displayCount, users.length); i++) {
                      stack.add(
                        Positioned(
                          left: i * (imageRadius * 3 / 2),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: stroke,
                                color: Color.alphaBlend(
                                  Colors.black.withOpacity(0.05),
                                  canvasTheme.boxBgColor,
                                ),
                              ),
                            ),
                            child: UserIcon.circleIcon(users[i],
                                radius: imageRadius),
                          ),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UsersFriendsScreen(
                              user: user,
                              friends: friends,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withOpacity(0.05),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              width: (imageRadius * 2 + stroke) +
                                  (min(displayCount, users.length) - 1) *
                                      (imageRadius * 3 / 2),
                              height: imageRadius * 2,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: stack,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            Text(
                              friends.length.toString(),
                              style: TextStyle(
                                color: canvasTheme.boxSecondaryTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const Gap(4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: canvasTheme.boxSecondaryTextColor,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Gap(12),
        ],
      ),
    );
  }

/*
  Widget _buildWishList(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount user) {
    return Column(
      children: [
        box(
          canvasTheme,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "欲しいもの",
                style: TextStyle(
                  fontSize: 16,
                  color: canvasTheme.boxTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              if (user.wishList.isEmpty)
                Center(
                  child: Text(
                    "No WishList",
                    style: TextStyle(
                      fontSize: 16,
                      color: canvasTheme.boxSecondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: user.wishList
                    .map(
                      (item) => Container(
                        margin: const EdgeInsets.all(4),
                        child: Text(
                          "・$item",
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 16,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            ],
          ),
        ),
        const Gap(12),
      ],
    );
  }

  Widget _buildWantToDoList(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount user) {
    return Column(
      children: [
        box(
          canvasTheme,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "近いうちに行きたい・したいこと",
                style: TextStyle(
                  fontSize: 16,
                  color: canvasTheme.boxTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              if (user.wantToDoList.isEmpty)
                Center(
                  child: Text(
                    "No Dreams",
                    style: TextStyle(
                      fontSize: 16,
                      color: canvasTheme.boxSecondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: user.wantToDoList
                    .map(
                      (item) => Container(
                        margin: const EdgeInsets.all(4),
                        child: Text(
                          "・$item",
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 16,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            ],
          ),
        ),
        const Gap(12),
      ],
    );
  }

  Widget _buildActivities(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount user) {
    return box(
      canvasTheme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "アクティビティ",
            style: TextStyle(
              fontSize: 16,
              color: canvasTheme.boxTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          FutureBuilder(
            future: ref
                .read(allCurrentStatusPostsNotifierProvider.notifier)
                .getUsersPosts(user.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              final posts = snapshot.data!;
              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    "No Activities",
                    style: TextStyle(
                      fontSize: 16,
                      color: canvasTheme.boxSecondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    /* decoration: BoxDecoration(
                        border: Border(
                          bottom: (index < 10 - 1)
                              ? BorderSide(
                                  width: 0.8,
                                  color: Colors.black.withOpacity(0.3),
                                )
                              : BorderSide.none,
                        ),
                      ), */
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CurrentStatusPostWidgets(context, ref, post, user)
                            .timelinePost(),
                      ],
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
 */
  Widget box(CanvasTheme canvasTheme, Widget child) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: canvasTheme.boxBgColor,
              borderRadius: BorderRadius.circular(canvasTheme.boxRadius),
              border: Border.all(
                width: canvasTheme.boxWidth,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class NotFriendScreen extends ConsumerWidget {
  const NotFriendScreen({super.key, required this.user});
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final canvasTheme = user.canvasTheme;
    final friendInfos =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];
    final friendIds = friendInfos.map((item) => item.userId);
    bool popped = false;

    final mutualIds = ref.watch(friendsFriendMapProvider)[user.userId] ?? {};
    final mutualFriends = ref
        .read(allUsersNotifierProvider)
        .asData!
        .value
        .entries
        .where((e) => mutualIds.contains(e.value.userId))
        .map((e) => e.value)
        .toList();
    final shorten = mutualFriends.length > 2;
    const imageHeight = 108.0;

    return Scaffold(
      backgroundColor: canvasTheme.bgColor,
      appBar: AppBar(
        backgroundColor: canvasTheme.bgColor,
        iconTheme: IconThemeData(
          color: canvasTheme.profileTextColor,
        ),
        actions: [
          FocusedMenuHolder(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            menuWidth: 120,
            blurSize: 0,
            animateMenuItems: false,
            openWithTap: true,
            menuBoxDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
            ),
            menuItems: <FocusedMenuItem>[
              FocusedMenuItem(
                backgroundColor: ThemeColor.background,
                title: const Text(
                  "報告",
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
              ),
              FocusedMenuItem(
                backgroundColor: ThemeColor.background,
                title: const Text(
                  "ブロック",
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(blocksListNotifierProvider.notifier).blockUser(user);
                  ref
                      .read(dmOverviewListNotifierProvider.notifier)
                      .closeChat(user);
                  Navigator.pop(context);
                  showMessage("ユーザーをブロックしました。");
                },
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.more_horiz,
                color: Colors.white,
              ),
            ),
          ),
          Gap(themeSize.horizontalPadding),
        ],
      ),
      body: FadeTransitionWidget(
        ms: 600,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(canvasTheme.iconStrokeWidth),
                decoration: BoxDecoration(
                  gradient: !canvasTheme.iconHideBorder
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            canvasTheme.iconGradientStartColor,
                            canvasTheme.iconGradientEndColor,
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(
                    canvasTheme.iconRadius + 12,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(12 - canvasTheme.iconStrokeWidth),
                  decoration: BoxDecoration(
                    color: canvasTheme.bgColor,
                    borderRadius: BorderRadius.circular(
                      canvasTheme.iconRadius + 12 - canvasTheme.iconStrokeWidth,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(canvasTheme.iconRadius),
                    child: SizedBox(
                      height: imageHeight,
                      width: imageHeight,
                      child: user.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: user.imageUrl!,
                              fadeInDuration: const Duration(milliseconds: 120),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: imageHeight,
                                width: imageHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => const SizedBox(),
                              errorWidget: (context, url, error) =>
                                  const SizedBox(),
                            )
                          : const Icon(
                              Icons.person_outline,
                              size: imageHeight * 0.8,
                              color: ThemeColor.stroke,
                            ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Text(
                user.name,
                style: TextStyle(
                  color: user.canvasTheme.profileTextColor,
                  fontSize: 24,
                ),
              ),
              const Gap(4),
              SizedBox(
                height: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      "共通の友達${mutualIds.length}人",
                      style: textStyle.w600(
                        fontSize: 12,
                        color: user.canvasTheme.profileSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              //フレンドリクエスト受付中なら
              (!user.privacy.privateMode &&
                      user.privacy.requestRange == PublicityRange.public)
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: themeSize.horizontalPaddingLarge,
                      ),
                      child: UserRequestButton(
                        user: user,
                      ),
                    )
                  //受付中じゃない場合
                  : (user.privacy.privateMode ||
                          user.privacy.requestRange ==
                              PublicityRange.onlyFriends)
                      ? const SizedBox()
                      //フレンドがいるかどうか判別
                      // privateMode = false で requestRange == friendOfFriendの場合
                      : mutualIds.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: themeSize.horizontalPaddingLarge,
                              ),
                              child: UserRequestButton(
                                user: user,
                              ),
                            )
                          : FutureBuilder(
                              future: ref
                                  .read(friendIdListNotifierProvider.notifier)
                                  .getFriends(user.userId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox();
                                final userFriendIds =
                                    snapshot.data!.map((user) => user.userId);
                                final requestable = (friendIds.any((userId) =>
                                    userFriendIds.contains(userId)));
                                if (!requestable) return const SizedBox();
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        themeSize.horizontalPaddingLarge,
                                  ),
                                  child: UserRequestButton(
                                    user: user,
                                  ),
                                );
                              },
                            ),
              Gap(themeSize.screenHeight * 0.3),
            ],
          ),
        ),
      ),
    );
  }
}

/*class BottomSection extends HookConsumerWidget {
  final UserAccount user;
  final controller = TextEditingController();
  BottomSection({super.key, required this.user});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendInfos =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];
    final friendIds = friendInfos.map((item) => item.userId);
    final requestIds =
        ref.watch(friendRequestIdListNotifierProvider).asData?.value ?? [];
    final requestedIds =
        ref.watch(friendRequestedIdListNotifierProvider).asData?.value ?? [];
    final text = useState('');
    if (user.userId == ref.watch(authProvider).currentUser!.uid) {
      return Container(
        padding: const EdgeInsets.only(
          bottom: 24,
        ),
        child: const Text(
          "THIS IS ME",
          style: TextStyle(
            color: ThemeColor.beige,
          ),
        ),
      );
    }
    if (friendIds.contains(user.userId)) {
      return Container(
        margin: const EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 24,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ThemeColor.beige,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ChattingScreen(user: user),
              ),
            );
          },
          child: const Center(
            child: Text(
              "チャットへ",
              style: TextStyle(
                color: ThemeColor.beige,
              ),
            ),
          ),
        ),
      );
    }
    if (requestIds.contains(user.userId)) {
      return Container(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 24,
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(friendRequestIdListNotifierProvider.notifier)
                      .cancelFriendRequest(user.userId);
                  showMessage("リクエストを取り消しました。");
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ThemeColor.beige,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "リクエスト済み",
                      style: TextStyle(
                        color: ThemeColor.beige,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChattingScreen(user: user),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ThemeColor.beige,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "チャットへ",
                      style: TextStyle(
                        color: ThemeColor.beige,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (requestedIds.contains(user.userId)) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 24,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ThemeColor.beige,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ChattingScreen(user: user),
              ),
            );
          },
          child: const Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "リクエストが届いています",
                style: TextStyle(
                  color: ThemeColor.beige,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        maxLength: 30,
        style: const TextStyle(
          fontSize: 14,
          color: ThemeColor.text,
        ),
        onChanged: (value) {
          text.value = value;
        },
        cursorColor: ThemeColor.highlight,
        decoration: InputDecoration(
          hintText: "チャットを送る",
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
          counterText: "",
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          suffixIcon: text.value.isNotEmpty
              ? GestureDetector(
                  onTap: () async {
                    try {
                      await ref
                          .read(friendRequestIdListNotifierProvider.notifier)
                          .sendFriendRequest(user);
                    
                    } catch (e) {
                      showMessage("チャットは最初の一回のみ送信できます。");
                    }
                    text.value = '';
                    controller.clear();
                  },
                  child: const Icon(
                    Icons.send,
                    color: ThemeColor.highlight,
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
    /*return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeColor.beige,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          ref
              .read(friendRequestIdListNotifierProvider.notifier)
              .sendFriendRequest(user.userId, "I sent you a friend request!");
      
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "チャットを送信",
              style: TextStyle(
                color: ThemeColor.beige,
              ),
            ),
          ],
        ),
      ),
    ); */
  }
}

class NotFriendScreen extends ConsumerWidget {
  const NotFriendScreen({super.key, required this.user});
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final imageHeight = themeSize.screenWidth * 0.25;
    final canvasTheme = CanvasTheme.defaultCanvasTheme();

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gap(themeSize.screenHeight * 0.25),
              Container(
                padding: EdgeInsets.all(canvasTheme.iconStrokeWidth),
                decoration: BoxDecoration(
                  gradient: !canvasTheme.iconHideBorder
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            canvasTheme.iconGradientStartColor,
                            canvasTheme.iconGradientEndColor,
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(
                    canvasTheme.iconRadius + 12,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(12 - canvasTheme.iconStrokeWidth),
                  decoration: BoxDecoration(
                    color: ThemeColor.background,
                    borderRadius: BorderRadius.circular(
                      canvasTheme.iconRadius + 12 - canvasTheme.iconStrokeWidth,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(canvasTheme.iconRadius),
                    child: SizedBox(
                      height: imageHeight,
                      width: imageHeight,
                      child: CachedNetworkImage(
                        imageUrl: user.imageUrl!,
                        fadeInDuration: const Duration(milliseconds: 120),
                        imageBuilder: (context, imageProvider) => Container(
                          height: imageHeight,
                          width: imageHeight,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => const SizedBox(),
                        errorWidget: (context, url, error) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Text(
                user.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              Text(
                "${user.createdAt.toDateStr}〜",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const Gap(24),
              _buildButton(ref),
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: SizedBox(
                    height: 32,
                    width: 32,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.black.withOpacity(0.7),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(WidgetRef ref) {
    final requests =
        ref.watch(friendRequestIdListNotifierProvider).asData?.value ?? [];
    final requesteds =
        ref.watch(friendRequestedIdListNotifierProvider).asData?.value ?? [];
    if (requesteds.contains(user.userId)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.pink,
          child: InkWell(
            splashColor: Colors.black.withOpacity(0.3),
            highlightColor: Colors.transparent,
            onTap: () {
              ref
                  .read(friendRequestedIdListNotifierProvider.notifier)
                  .admitFriendRequested(user.userId);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text(
                "リクエストを承認する",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (requests.contains(user.userId)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.cyan,
          child: InkWell(
            splashColor: Colors.black.withOpacity(0.3),
            highlightColor: Colors.transparent,
            onTap: () {
              ref
                  .read(friendRequestIdListNotifierProvider.notifier)
                  .cancelFriendRequest(user.userId);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text(
                "リクエスト済み",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: const Text(
              "フレンド申請を送る",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */