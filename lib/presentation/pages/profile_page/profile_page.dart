import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/profile_bottomsheet.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/profile_page/edit_canvas_theme_screem.dart';
import 'package:app/presentation/pages/profile_page/edit_current_status_screen.dart';
import 'package:app/presentation/pages/profile_page/edit_top_friends.dart';
import 'package:app/presentation/phase_01/friends_screen.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:overscroll_pop/overscroll_pop.dart';
import 'package:url_launcher/url_launcher.dart';

final canvasThemeProvider =
    StateProvider((ref) => CanvasTheme.defaultCanvasTheme());

final nameStateProvider = StateProvider((ref) => "");
final usernameStateProvider = StateProvider((ref) => "");
final bioStateProvider = StateProvider((ref) => Bio.defaultBio());
final aboutMeStateProvider = StateProvider((ref) => "");

final linksStateProvider = StateProvider(
  (ref) => Links.defaultLinks(),
);
final currentStatusStateProvider =
    StateProvider((ref) => CurrentStatus.defaultCurrentStatus());
final topFriendsProvider = StateProvider<List<String>>((ref) => []);

final notificationDataProvider =
    StateProvider((ref) => NotificationData.defaultSettings());
final privacyProvider = StateProvider((ref) => Privacy.defaultPrivacy());

//test
final changeProvider = StateProvider((ref) => true);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(myAccountNotifierProvider);
    bool popped = false;
    return asyncValue.when(
      data: (me) {
        final canvasTheme = me.canvasTheme;
        return Scaffold(
          backgroundColor: canvasTheme.bgColor,
          body: NotificationListener(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                if (notification.dragDetails != null &&
                    notification.dragDetails!.primaryDelta != null &&
                    notification.dragDetails!.primaryDelta! > 85 &&
                    !popped) {
                  popped = true;
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  return true;
                }
              }
              return false;
            },
            child: ListView(
              padding: const EdgeInsets.only(
                top: kToolbarHeight,
                bottom: 120,
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: themeSize.horizontalPadding,
                    right: themeSize.horizontalPadding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UserIconCanvasIcon(user: me),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            /* GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransitionMethods.slideUp(
                                      const QrCodeScreen()),
                                );
                              },
                              child: Icon(
                                Icons.qr_code_rounded,
                                color: canvasTheme.profileTextColor,
                              ),
                            ), */
                            const Gap(12),
                            GestureDetector(
                              onTap: () {
                                ref.read(canvasThemeProvider.notifier).state =
                                    canvasTheme;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const EditCanvasThemeScreen(),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.palette_outlined,
                                color: canvasTheme.profileTextColor,
                              ),
                            ),
                            const Gap(12),
                            GestureDetector(
                              onTap: () {
                                ProfileBottomSheet(context).openBottomSheet(me);
                              },
                              child: Icon(
                                Icons.settings_outlined,
                                color: canvasTheme.profileTextColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: themeSize.horizontalPadding,
                    right: themeSize.horizontalPadding,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              me.name,
                              style: textStyle.w600(
                                fontSize: 24,
                                color: canvasTheme.profileTextColor,
                              ),
                            ),
                            Text(
                              "${me.createdAt.toDateStr}〜",
                              style: textStyle.w600(
                                fontSize: 14,
                                color: canvasTheme.profileSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (me.links.isShown)
                        Row(
                          children: [
                            /* if (me.links.line.isShown && me.links.line.path != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(Uri.parse(me.links.line.url!));
                            },
                            child: SizedBox(
                              height: 32,
                              width: 32,
                              child: Image.asset(
                                me.links.line.assetString,
                                color: canvasTheme.profileLinksColor,
                              ),
                            ),
                          ),
                        ), */
                            if (me.links.instagram.isShown &&
                                me.links.instagram.path != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: GestureDetector(
                                  onTap: () async {
                                    launchUrl(
                                      Uri.parse(
                                        me.links.instagram.url!,
                                      ),
                                      mode: LaunchMode.externalApplication,
                                    );
                                    //showMessage("${me.links.instagram.url}");
                                  },
                                  child: SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: Image.asset(
                                      me.links.instagram.assetString,
                                      color: canvasTheme.profileLinksColor,
                                    ),
                                  ),
                                ),
                              ),
                            if (me.links.x.isShown && me.links.x.path != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    launchUrl(
                                      Uri.parse(me.links.x.url!),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Image.asset(
                                      me.links.x.assetString,
                                      color: canvasTheme.profileLinksColor,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding,
                  ),
                  child: Text(
                    me.aboutMe,
                    style: textStyle.w600(
                      fontSize: 14,
                      color: canvasTheme.profileAboutMeColor,
                    ),
                  ),
                ),
                const Gap(24),
                //_buildImages(context, ref, me),
                _buildCurrentStatus(context, ref, canvasTheme, me),
                _buildTopFriends(context, ref, canvasTheme, me),
                _buildFriends(context, ref, canvasTheme, me),
              ],
            ),
          ),
        );
      },
      error: (e, s) => const Scaffold(),
      loading: () => const Scaffold(),
    );
  }

  navToEditCurrentStatus(BuildContext context, WidgetRef ref, UserAccount me) {
    ref.read(currentStatusStateProvider.notifier).state = me.currentStatus;
    Navigator.push(
      context,
      PageTransitionMethods.slideUp(
        const EditCurrentStatusScreen(),
      ),
    );
  }

  navToEditTopFriends(BuildContext context, WidgetRef ref, UserAccount me) {
    ref.read(topFriendsProvider.notifier).state = me.topFriends;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditTopFriendsScreen(),
      ),
    );
  }

/*  Widget _buildIconAndBio(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
    const imageHeight = 72.0;
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
                  GestureDetector(
                    onTap: () {
                      navToEditIconBioAboutMe(context, ref, me);
                    },
                    child: Container(
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
                        padding:
                            EdgeInsets.all(12 - canvasTheme.iconStrokeWidth),
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
                            child: me.imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: me.imageUrl!,
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
                                    size: imageHeight,
                                    color: ThemeColor.stroke,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    !canvasTheme.iconHideLevel ? "LEVEL 1" : "",
                    style: TextStyle(
                      color: canvasTheme.profileTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1,
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
                            me.bio.age != null ? me.bio.age.toString() : "未設定",
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
                            me.bio.birthday != null
                                ? me.bio.birthday!.toDateStr
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
                            me.bio.gender == null
                                ? "未設定"
                                : me.bio.gender == "system_male"
                                    ? "男性"
                                    : me.bio.gender == "system_female"
                                        ? "女性"
                                        : me.bio.gender!
                                                .startsWith("system_custom")
                                            ? me.bio.gender!.substring(
                                                13, me.bio.gender!.length)
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
                            me.bio.interestedIn == null
                                ? "未設定"
                                : me.bio.interestedIn == "system_male"
                                    ? "男性"
                                    : me.bio.interestedIn == "system_female"
                                        ? "女性"
                                        : me.bio.interestedIn!
                                                .startsWith("system_custom")
                                            ? me.bio.interestedIn!.substring(
                                                13, me.bio.interestedIn!.length)
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
                  () {
                    navToEditIconBioAboutMe(context, ref, me);
                  },
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
      CanvasTheme canvasTheme, UserAccount me) {
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
                    fontSize: 12,
                    color: canvasTheme.boxTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(6),
                Text(
                  me.aboutMe,
                  style: TextStyle(
                    fontSize: 14,
                    color: canvasTheme.boxSecondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(24),
                Text(
                  "メンバーになった日",
                  style: TextStyle(
                    fontSize: 12,
                    color: canvasTheme.boxTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(6),
                Text(
                  me.createdAt.toDateStr,
                  style: TextStyle(
                    color: canvasTheme.boxSecondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            () {
              navToEditIconBioAboutMe(context, ref, me);
            },
          ),
          const Gap(12),
        ],
      ),
    );
  }
 */
  Widget _buildCurrentStatus(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
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
                  "いまボード",
                  style: TextStyle(
                    fontSize: 14,
                    color: canvasTheme.boxTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                /*   Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: me.currentStatus.tags
                          .map((tag) => Container(
                                margin: const EdgeInsets.only(
                                  right: 8,
                                  bottom: 4,
                                  top: 4,
                                ),
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
                                    fontSize: 14,
                                    color: canvasTheme.boxSecondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ), */
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "してること",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            me.currentStatus.doing,
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
                        flex: 2,
                        child: Text(
                          "食べてる",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            me.currentStatus.eating,
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
                        flex: 2,
                        child: Text(
                          "気分",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            me.currentStatus.mood,
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
                        flex: 2,
                        child: Text(
                          "場所",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            me.currentStatus.nowAt,
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
                        flex: 2,
                        child: Text(
                          "次の場所",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            me.currentStatus.nextAt,
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
                if (me.currentStatus.nowWith.isNotEmpty || true)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "一緒にいる人",
                            style: TextStyle(
                              fontSize: 14,
                              color: canvasTheme.boxTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: SizedBox(
                            height: 48,
                            child: FutureBuilder(
                                future: ref
                                    .read(allUsersNotifierProvider.notifier)
                                    .getUserAccounts(me.currentStatus.nowWith),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  }
                                  final users = snapshot.data!;
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: users.length,
                                    itemBuilder: (context, index) {
                                      final user = users[index];
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
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
                                                            milliseconds: 120),
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      height: 48,
                                                      width: 48,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            const SizedBox(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const SizedBox(),
                                                  )
                                                : const Icon(
                                                    Icons.person_outline,
                                                    size: 48 * 0.8,
                                                    color: ThemeColor.stroke,
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
            () {
              navToEditCurrentStatus(context, ref, me);
            },
          ),
          const Gap(12),
        ],
      ),
    );
  }

  Widget _buildTopFriends(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final map = ref.read(allUsersNotifierProvider).asData!.value;
    final users = me.topFriends.map((userId) => map[userId]!).toList();
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
                  "TOP フレンド",
                  style: TextStyle(
                    fontSize: 16,
                    color: canvasTheme.boxTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Builder(
                  builder: (
                    context,
                  ) {
                    if (users.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            "お気に入りのフレンドを追加しよう",
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
            () {
              navToEditTopFriends(context, ref, me);
            },
          ),
          const Gap(12),
        ],
      ),
    );
  }

  Widget _buildFriends(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
    final themeSize = ref.watch(themeSizeProvider(context));

    const displayCount = 5;
    const imageRadius = 24.0;
    const stroke = 4.0;
    final asyncValue = ref.watch(friendIdListNotifierProvider);
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
                  "自分のフレンド",
                  style: TextStyle(
                    fontSize: 14,
                    color: canvasTheme.boxTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                asyncValue.when(
                  data: (friendInfos) {
                    final friendIds = friendInfos.map((item) => item.userId);

                    final userIds = friendIds
                        .where((userId) => !me.topFriends.contains(userId))
                        .toList();

                    final users = ref
                        .read(allUsersNotifierProvider)
                        .asData!
                        .value
                        .values
                        .where((user) => userIds.contains(user.userId))
                        .toList();

                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          me.topFriends.isNotEmpty
                              ? "TOP10に全てのフレンドがいます"
                              : "フレンドはいません。",
                          style: TextStyle(
                            fontSize: 16,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
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
                            child: UserIcon(
                              user: users[i],
                              width: imageRadius * 2,
                              isCircle: true,
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
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
                            friendIds.length.toString(),
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
                    );
                  },
                  error: (e, s) => const SizedBox(),
                  loading: () => const SizedBox(),
                ),
              ],
            ),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FriendsScreen(),
                ),
              );
            },
            isEditable: false,
          ),
          const Gap(12),
        ],
      ),
    );
  }

  /* Widget _buildImages(BuildContext context, WidgetRef ref, UserAccount me) {
    final asyncValue = ref.watch(userImagesNotiferProvider(me.userId));
    final themeSize = ref.watch(themeSizeProvider(context));

    const imageHeight = 96.0;

    return asyncValue.when(
      data: (imageUrls) {
        if (imageUrls.isEmpty) return const SizedBox();
        /*return Padding(
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
                        style: TextStyle(
                          fontSize: 14,
                          color: canvasTheme.boxTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: imageHeight + 16,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            final imageUrl = imageUrls[index];
                            return Container(
                              margin: EdgeInsets.only(
                                right: 8,
                              ),
                              height: imageHeight,
                              width: imageHeight,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: imageHeight - 4,
                                    width: imageHeight - 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 2,
                                          spreadRadius: 4,
                                          color:
                                              Colors.black.withOpacity(0.5),
                                          offset: Offset(0, 4),
                                        )
                                      ],
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: imageHeight,
                                      width: imageHeight,
                                      color: Colors.orange,
                                      child: CachedImage.profileBoardImage(
                                        imageUrl,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  () {},
                  isEditable: false,
                ),
                const Gap(12),
              ],
            ),
          ); */

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: themeSize.horizontalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "最近の写真",
                    style: TextStyle(
                      fontSize: 14,
                      color: me.canvasTheme.profileAboutMeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  /* Icon(
                    Icons.arrow_forward_ios,
                    color: me.canvasTheme.profileAboutMeColor,
                    size: 18,
                  ), */
                ],
              ),
            ),
            const Gap(8),
            /* Container(
                color: Colors.cyan,
                height: sqrt((imageHeight + 16) * (imageHeight + 16) +
                    (imageHeight * 1.2 + 32) * (imageHeight * 1.2 + 32)),
                child: Stack(
                  alignment: Alignment.center,
                  children: imageUrls.reversed
                      .map(
                        (imageUrl) => Positioned(
                          left: 24.0 * (imageUrls.indexOf(imageUrl)),
                          child: Transform.rotate(
                            alignment: Alignment.center,
                            angle: pi / 24 * (imageUrls.indexOf(imageUrl)),
                            child: Transform.scale(
                              scale: cos(
                                pi / 24 * (imageUrls.indexOf(imageUrl)),
                              ),
                              child: Container(
                                height: imageHeight * 1.2 + 32,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                padding: EdgeInsets.only(
                                  top: 8,
                                  left: 8,
                                  right: 8,
                                  bottom: 24,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 0.2,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Container(
                                  height: imageHeight * 1.2,
                                  width: imageHeight,
                                  child: CachedImage.profileBoardImage(
                                    imageUrl,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ), */
            SizedBox(
              height: imageHeight * 1.2 + 32 + 24,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                padding: EdgeInsets.symmetric(
                  horizontal: themeSize.horizontalPadding - 4,
                ),
                itemBuilder: (context, index) {
                  final userImage = imageUrls[index];
                  return GestureDetector(
                    onLongPress: () {
                      UserImageBottomSheet(context).showImageMenu(userImage);
                    },
                    onTap: () {
                      /*pushPage(
                        context,
                        VerticalScrollview(
                          scrollToPopOption: ScrollToPopOption.start,
                          dragToPopDirection: DragToPopDirection.toBottom,
                          child: ImagesView(
                            imageUrls:
                                imageUrls.map((item) => item.imageUrl).toList(),
                            initialIndex: index,
                          ),
                        ),
                      ); */
                      Navigator.push(
                        context,
                        PageTransitionMethods.fadeIn(
                          VerticalScrollview(
                            scrollToPopOption: ScrollToPopOption.both,
                            dragToPopDirection: DragToPopDirection.toBottom,
                            child: ImagesView(
                              imageUrls: imageUrls
                                  .map((item) => item.imageUrl)
                                  .toList(),
                              initialIndex: index,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        /*    Container(
                          margin: const EdgeInsets.only(top: 32),
                          height: imageHeight * 1.2,
                          width: imageHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12,
                                offset: const Offset(0, 8),
                                color: Colors.black.withOpacity(0.3),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 8,
                            right: 8,
                            bottom: 24,
                          ),
                          color: Colors.white,
                          child: SizedBox(
                            height: imageHeight * 1.2,
                            width: imageHeight,
                            child: CachedImage.profileBoardImage(
                              userImage.imageUrl,
                            ),
                          ),
                        ),
                        */
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 8,
                            right: 8,
                            bottom: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                offset: const Offset(4, 4),
                                color: Colors.black.withOpacity(0.5),
                              )
                            ],
                          ),
                          child: SizedBox(
                            height: imageHeight * 1.2,
                            width: imageHeight,
                            child: CachedImage.profileBoardImage(
                              userImage.imageUrl,
                            ),
                          ),
                        ),
                        if (userImage.isNew)
                          const Positioned(
                            bottom: 24,
                            right: 8,
                            child: GradientText(
                              text: "NEW",
                            ),
                          ),
                      ],
                    ),
                  );
                  /* return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    height: imageHeight,
                    width: imageHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: imageHeight - 4,
                          width: imageHeight - 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                spreadRadius: 4,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                        ),
                        Opacity(
                          opacity: 1, //0.3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: imageHeight,
                              width: imageHeight,
                              child: CachedImage.profileBoardImage(
                                imageUrl,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ); */
                },
              ),
            ),
          ],
        );
      },
      error: (e, s) => Text("error : $e, $s"),
      loading: () => const SizedBox(),
    );
  }
 */
  /* Widget _buildWishList(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
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
              if (me.wishList.isEmpty)
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
                children: me.wishList
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
          () {},
        ),
        const Gap(12),
      ],
    );
  }

  Widget _buildWantToDoList(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
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
              if (me.wantToDoList.isEmpty)
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
                children: me.wantToDoList
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
          () {},
        ),
        const Gap(12),
      ],
    );
  }

  Widget _buildActivities(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
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
                .getUsersPosts(me.userId),
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
                        CurrentStatusPostWidgets(context, ref, post, me)
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
      () {},
      isEditable: false,
    );
  }
 */
  Widget box(CanvasTheme canvasTheme, Widget child, Function onPressed,
      {bool isEditable = true}) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: !isEditable
                    ? () {
                        onPressed();
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
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
            ),
          ],
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Visibility(
            visible: isEditable,
            child: GestureDetector(
              onTap: () {
                onPressed();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.1),
                ),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: SvgPicture.asset(
                    "assets/images/icons/edit.svg",
                    // ignore: deprecated_member_use
                    color: canvasTheme.boxTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ImagesView extends ConsumerWidget {
  const ImagesView({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });
  final List<String> imageUrls;
  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width - 48;

    return PageView.builder(
      itemCount: imageUrls.length,
      controller: PageController(initialPage: initialIndex),
      itemBuilder: (context, index) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: width,
              height: width * 1.2,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 1.6,
                child: CachedImage.imageView(
                  imageUrls[index],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class VerticalScrollview extends StatelessWidget {
  final ScrollToPopOption scrollToPopOption;
  final DragToPopDirection? dragToPopDirection;
  final Widget child;
  const VerticalScrollview({
    super.key,
    this.scrollToPopOption = ScrollToPopOption.start,
    this.dragToPopDirection,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OverscrollPop(
      scrollToPopOption: scrollToPopOption,
      dragToPopDirection: dragToPopDirection,
      child: child,
    );
  }
}
