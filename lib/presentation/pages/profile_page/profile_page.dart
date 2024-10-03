import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/profile_bottomsheet.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/profile_page/edit_bio_screen.dart';
import 'package:app/presentation/pages/profile_page/edit_canvas_theme_screem.dart';
import 'package:app/presentation/pages/profile_page/edit_current_status_screen.dart';
import 'package:app/presentation/pages/profile_page/edit_top_friends.dart';
import 'package:app/presentation/pages/profile_page/invite_code_screen.dart';
import 'package:app/presentation/pages/profile_page/qr_code_screen.dart';
import 'package:app/presentation/phase_01/friends_screen.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

final canvasThemeProvider =
    StateProvider((ref) => CanvasTheme.defaultCanvasTheme());
final bioStateProvider = StateProvider((ref) => Bio.defaultBio());
final aboutMeStateProvider = StateProvider((ref) => "");
final currentStatusStateProvider =
    StateProvider((ref) => CurrentStatus.defaultCurrentStatus());
final topFriendsProvider = StateProvider<List<String>>((ref) => []);

final notificationDataProvider =
    StateProvider((ref) => NotificationData.defaultSettings());
final privacyProvider = StateProvider((ref) => Privacy.defaultPrivacy());

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
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
                    notification.dragDetails!.primaryDelta! > 100 &&
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
              padding: EdgeInsets.only(
                  bottom: 120,
                  left: themeSize.horizontalPadding,
                  right: themeSize.horizontalPadding),
              children: [
                AppBar(
                  backgroundColor: canvasTheme.bgColor,
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
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              me.name,
                              style: TextStyle(
                                color: me.canvasTheme.profileTextColor,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            PageTransitionMethods.slideUp(const QrCodeScreen()),
                          );
                        },
                        child: Icon(
                          Icons.qr_code_rounded,
                          color: canvasTheme.profileTextColor,
                        ),
                      ),
                      const Gap(12),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InviteCodeScreen(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.confirmation_num_outlined,
                          color: canvasTheme.profileTextColor,
                        ),
                      ),
                      const Gap(12),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(canvasThemeProvider.notifier).state =
                              canvasTheme;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditCanvasThemeScreen(),
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
                          HapticFeedback.lightImpact();
                          ProfileBottomSheet(ref).openBottomSheet(context, me);
                        },
                        child: Icon(
                          Icons.settings_outlined,
                          color: canvasTheme.profileTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                _buildIconAndBio(context, ref, canvasTheme, me),
                _buildAboutMe(context, ref, canvasTheme, me),
                _buildCurrentStatus(context, ref, canvasTheme, me),
                _buildTopFriends(context, ref, canvasTheme, me),
                _buildFriends(context, ref, canvasTheme, me),
                // _buildWishList(context, ref, canvasTheme, me),
                // _buildWantToDoList(context, ref, canvasTheme, me),
                // _buildActivities(context, ref, canvasTheme, me),
              ],
            ),
          ),
        );
      },
      error: (e, s) => const Scaffold(),
      loading: () => const Scaffold(),
    );
  }

  navToEditIconBioAboutMe(BuildContext context, WidgetRef ref, UserAccount me) {
    ref.read(bioStateProvider.notifier).state = me.bio;
    ref.read(aboutMeStateProvider.notifier).state = me.aboutMe;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditBioScreen(),
      ),
    );
  }

  navToEditCurrentStatus(BuildContext context, WidgetRef ref, UserAccount me) {
    ref.read(currentStatusStateProvider.notifier).state = me.currentStatus;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditCurrentStatusScreen(),
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

  Widget _buildIconAndBio(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
    const imageHeight = 80.0;
    return Column(
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
    );
  }

  Widget _buildAboutMe(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
    return Column(
      children: [
        box(
          canvasTheme,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "自己紹介",
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
                  color: me.canvasTheme.boxSecondaryTextColor,
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
    );
  }

  Widget _buildCurrentStatus(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
    return Column(
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
              const Gap(4),
              Column(
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
                          color: canvasTheme.boxTextColor,
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
                      flex: 1,
                      child: Text(
                        "なに食べてる？",
                        style: TextStyle(
                          fontSize: 14,
                          color: canvasTheme.boxTextColor,
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
                      flex: 1,
                      child: Text(
                        "今の気分は？",
                        style: TextStyle(
                          fontSize: 14,
                          color: canvasTheme.boxTextColor,
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
                      flex: 1,
                      child: Text(
                        "どこにいる？",
                        style: TextStyle(
                          fontSize: 14,
                          color: canvasTheme.boxTextColor,
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
                              me.currentStatus.nowAt,
                              style: TextStyle(
                                fontSize: 16,
                                color: canvasTheme.boxSecondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "next: ${me.currentStatus.nextAt}",
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
              if (me.currentStatus.nowWith.isNotEmpty || true)
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
                            color: canvasTheme.boxTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: FutureBuilder(
                          future: ref
                              .read(allUsersNotifierProvider.notifier)
                              .getUserAccounts(me.currentStatus.nowWith),
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
                                                : Icon(
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
          () {
            navToEditCurrentStatus(context, ref, me);
          },
        ),
        const Gap(12),
      ],
    );
  }

  Widget _buildTopFriends(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final users = ref
        .watch(allUsersNotifierProvider)
        .asData!
        .value
        .values
        .where((user) => me.topFriends.contains(user.userId))
        .toList();
    final imageWidth = (themeSize.screenWidth -
                2 * themeSize.horizontalPadding -
                canvasTheme.boxWidth * 2 -
                32) /
            5 -
        8;
    return Column(
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
              Builder(
                builder: (
                  context,
                ) {
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
                                      color: canvasTheme.boxSecondaryTextColor,
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
    );
  }

  Widget _buildFriends(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
    //final themeSize = ref.watch(themeSizeProvider(context));

    const displayCount = 5;
    const imageRadius = 24.0;
    const stroke = 4.0;
    final asyncValue = ref.watch(friendIdListNotifierProvider);
    return Column(
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
                  final others = friendIds
                      .where((userId) => !me.topFriends.contains(userId))
                      .toList();

                  final userIds = others.length < 5 ? friendIds : others;
                  final users = ref
                      .watch(allUsersNotifierProvider)
                      .asData!
                      .value
                      .values
                      .where((user) => userIds.contains(user.userId))
                      .toList();
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        "No Friends",
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
                          child: UserIcon.circleIcon(
                            users[i],
                            radius: imageRadius,
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
            HapticFeedback.lightImpact();
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
    );
  }

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
                HapticFeedback.lightImpact();
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
