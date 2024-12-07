import 'dart:math';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/user_bottomsheet.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/components/widgets/fade_transition_widget.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/others/report_user_screen.dart';
import 'package:app/presentation/pages/sub_pages/user_profile_page/blocked_profile_screen.dart';
import 'package:app/presentation/pages/sub_pages/user_profile_page/user_posts_list.dart';
import 'package:app/presentation/pages/sub_pages/user_profile_page/users_friends_screen.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
import 'package:app/presentation/providers/provider/images/images.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

final scrollControllerProvider = Provider((ref) => ScrollController());

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({
    super.key,
    required this.user,
  });
  final UserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final canvasTheme = user.canvasTheme;
    final blocks = ref.watch(blocksListNotifierProvider).asData?.value ?? [];
    final blockeds =
        ref.watch(blockedsListNotifierProvider).asData?.value ?? [];
    if (blocks.contains(user.userId)) {
      return BlockedProfileScreen(user: user, state: "block");
    }
    if (blockeds.contains(user.userId)) {
      return BlockedProfileScreen(user: user, state: "blocked");
    }

    final statusBarHeight = MediaQuery.of(context).padding.top;
    const height = 112.0;

    /* final scrollController = ref.watch(scrollControllerProvider);
    scrollController.addListener(() {
      DebugPrint(
          "${scrollController.position.userScrollDirection} , ${scrollController.position.pixels}");
      if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          scrollController.position.pixels <= -80) {
        if (!popped) {
          popped = true;
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    }); */
    return Scaffold(
      backgroundColor: canvasTheme.bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: height,
                pinned: true,
                stretch: true,
                backgroundColor: canvasTheme.bgColor,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final top = constraints.biggest.height;
                    final expandedHeight = height + statusBarHeight;
                    // 展開率を計算（1.0が完全展開、0.0が完全収縮）
                    final expandRatio = ((top -
                                kToolbarHeight -
                                statusBarHeight) /
                            (expandedHeight - kToolbarHeight - statusBarHeight))
                        .clamp(0.0, 1.0);

                    // 展開率に基づいてアニメーションを制御
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // 展開時のレイアウト
                        Opacity(
                          opacity: expandRatio,
                          child: SafeArea(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: themeSize.horizontalPadding,
                              ),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      UserIconCanvasIcon(user: user),
                                      const Expanded(
                                        child: SizedBox(),
                                      ),
                                      _buildTopActions(context, ref, user),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 収縮時のレイアウト
                        Opacity(
                          opacity: 1 - expandRatio,
                          child: SafeArea(
                            child: SizedBox(
                              height: kToolbarHeight,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: themeSize.horizontalPadding,
                                  right: themeSize.horizontalPadding,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          UserIcon(
                                            user: user,
                                            width: 40,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            user.name,
                                            style: textStyle.w600(
                                              fontSize: 16,
                                              color:
                                                  canvasTheme.profileTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildTopActions(context, ref, user),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  color: canvasTheme.bgColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: textStyle.w600(
                                    fontSize: 24,
                                    color: canvasTheme.profileTextColor,
                                  ),
                                ),
                                Text(
                                  "${user.createdAt.toDateStr}〜",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                    color:
                                        canvasTheme.profileSecondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Text(
                        user.aboutMe,
                        style: textStyle.w600(
                          fontSize: 14,
                          color: canvasTheme.profileAboutMeColor,
                        ),
                      ),
                      if (user.links.isShown)
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Row(
                            children: [
                              if (user.links.instagram.isShown &&
                                  user.links.instagram.path != null)
                                GestureDetector(
                                  onTap: () async {
                                    launchUrl(
                                      Uri.parse(
                                        user.links.instagram.url!,
                                      ),
                                      mode: LaunchMode.externalApplication,
                                    );
                                    //showMessage("${me.links.instagram.url}");
                                  },
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset(
                                      user.links.instagram.assetString,
                                      color: canvasTheme.profileLinksColor,
                                    ),
                                  ),
                                ),
                              if (user.links.x.isShown &&
                                  user.links.x.path != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      launchUrl(
                                        Uri.parse(user.links.x.url!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: Image.asset(
                                        user.links.x.assetString,
                                        color: canvasTheme.profileLinksColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      _buildRequestBanner(context, ref, user),
                    ],
                  ),
                ),
              ),
              //tabbar
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        _buildCurrentStatus(context, ref, canvasTheme, user),
                        _buildTopFriends(context, ref, canvasTheme, user),
                        _buildFriends(context, ref, canvasTheme, user),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            "投稿",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: canvasTheme.profileTextColor,
                            ),
                          ),
                        ),
                        UserPostsList(userId: user.userId),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            "アルバム",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: canvasTheme.profileTextColor,
                            ),
                          ),
                        ),
                        _buildImages(context, ref, user),
                      ],
                    ),

                    // アルバムセクション

                    const SizedBox(height: 120),
                    //_buildImages(context, ref, user),
                  ],
                ),
              ),
              //_buildTabBar(context, ref, canvasTheme),
            ],
          ),
          Positioned(
            bottom: 32, // 下からの距離
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: ThemeColor.surface,
                    border: Border.all(
                      color: ThemeColor.stroke.withOpacity(0.8),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ThemeColor.surface,
                        ThemeColor.surface.withOpacity(0.9),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: ThemeColor.text,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    /*  return Scaffold(
      backgroundColor: canvasTheme.bgColor,
      body: NotificationListener<ScrollNotification>(
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
                  UserIconCanvasIcon(user: user),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(navigationRouterProvider(context))
                                .goToChat(user);
                          },
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: SvgPicture.asset(
                              "assets/images/icons/chat.svg",
                              // ignore: deprecated_member_use
                              color: canvasTheme.profileTextColor,
                            ),
                          ),
                        ),
                        const Gap(12),
                        /*GestureDetector(
                      onTap: () {
                        
                      },
                      child: Icon(
                        shareIcon,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(12), */
                        FocusedMenuHolder(
                          onPressed: () {},
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
                                UserBottomModelSheet(context)
                                    .quitFriendBottomSheet(user);
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: ThemeColor.background,
                              title: const Text(
                                "報告",
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReportUserScreen(user),
                                  ),
                                );
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: ThemeColor.background,
                              title: const Text(
                                "ブロック",
                              ),
                              onPressed: () {
                                UserBottomModelSheet(context)
                                    .blockUserBottomSheet(user);
                              },
                            ),
                          ],
                          child: Icon(
                            Icons.more_horiz,
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
                          user.name,
                          style: textStyle.w600(
                            fontSize: 24,
                            color: canvasTheme.profileTextColor,
                          ),
                        ),
                        Text(
                          "${user.createdAt.toDateStr}〜",
                          style: textStyle.w600(
                            fontSize: 14,
                            color: canvasTheme.profileSecondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (user.links.isShown)
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
                        if (user.links.instagram.isShown &&
                            user.links.instagram.path != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: GestureDetector(
                              onTap: () async {
                                launchUrl(
                                  Uri.parse(
                                    user.links.instagram.url!,
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                                //showMessage("${me.links.instagram.url}");
                              },
                              child: SizedBox(
                                height: 26,
                                width: 26,
                                child: Image.asset(
                                  user.links.instagram.assetString,
                                  color: canvasTheme.profileLinksColor,
                                ),
                              ),
                            ),
                          ),
                        if (user.links.x.isShown && user.links.x.path != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri.parse(user.links.x.url!),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: Image.asset(
                                  user.links.x.assetString,
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
                user.aboutMe,
                style: textStyle.w600(
                  fontSize: 14,
                  color: canvasTheme.profileAboutMeColor,
                ),
              ),
            ),
            const Gap(24),
            //_buildImages(context, ref, user),
            _buildCurrentStatus(context, ref, canvasTheme, user),
            _buildTopFriends(context, ref, canvasTheme, user),
            _buildFriends(context, ref, canvasTheme, user),
          ],
        ),
      ),
    );
  
   */
  }

  Widget _buildRequestBanner(
      BuildContext context, WidgetRef ref, UserAccount user) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final friendInfos =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];
    final friendIds = friendInfos.map((item) => item.userId);

    final isFriend =
        friendInfos.map((item) => item.userId).contains(user.userId);
    if (isFriend) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: ref
                .read(friendIdListNotifierProvider.notifier)
                .getFriends(user.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              final users = snapshot.data!;
              users.removeWhere((e) => !friendIds.contains(e.userId));
              final shorten = users.length > 2;

              return Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 24,
                      child: Row(
                        children: [
                          Wrap(
                            children: (shorten ? users.sublist(0, 2) : users)
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
                                                fadeInDuration: const Duration(
                                                    milliseconds: 120),
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
                                                errorWidget:
                                                    (context, url, error) =>
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
                            "共通の友達${users.length}人",
                            style: textStyle.w600(
                              fontSize: 12,
                              color: user.canvasTheme.profileSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(12),
                  UserRequestButton(
                    user: user,
                    hasNoMutualFriends: users.isEmpty,
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopActions(
      BuildContext context, WidgetRef ref, UserAccount user) {
    final canvasTheme = user.canvasTheme;
    final friendInfos =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];
    final isFriend =
        friendInfos.map((item) => item.userId).contains(user.userId);

    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          if (isFriend)
            GestureDetector(
              onTap: () {
                ref.read(navigationRouterProvider(context)).goToChat(user);
              },
              child: SizedBox(
                height: 22,
                width: 22,
                child: SvgPicture.asset(
                  "assets/images/icons/chat.svg",
                  // ignore: deprecated_member_use
                  color: canvasTheme.profileTextColor,
                ),
              ),
            ),
          const Gap(12),
          FocusedMenuHolder(
            onPressed: () {},
            menuWidth: 120,
            blurSize: 0,
            animateMenuItems: false,
            openWithTap: true,
            menuBoxDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
            ),
            menuItems: <FocusedMenuItem>[
              if (isFriend)
                FocusedMenuItem(
                  backgroundColor: ThemeColor.background,
                  title: const Text(
                    "フレンド解除",
                  ),
                  onPressed: () {
                    UserBottomModelSheet(context).quitFriendBottomSheet(user);
                  },
                ),
              FocusedMenuItem(
                backgroundColor: ThemeColor.background,
                title: const Text(
                  "報告",
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportUserScreen(user),
                    ),
                  );
                },
              ),
              FocusedMenuItem(
                backgroundColor: ThemeColor.background,
                title: const Text(
                  "ブロック",
                ),
                onPressed: () {
                  UserBottomModelSheet(context).blockUserBottomSheet(user);
                },
              ),
            ],
            child: Icon(
              Icons.more_horiz,
              color: canvasTheme.profileTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount user) {
    final themeSize = ref.watch(themeSizeProvider(context));
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
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
    final imageWidth =
        (themeSize.screenWidth - 2 * 8 - canvasTheme.boxWidth * 2 - 32) / 5 - 8;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                            child: UserIcon(
                              user: users[i],
                              width: imageRadius * 2,
                              isCircle: true,
                            ),
                          ),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
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

  Widget _buildImages(BuildContext context, WidgetRef ref, UserAccount user) {
    final asyncValue = ref.watch(imagesPostsNotiferProvider(user.userId));

    return asyncValue.when(
      data: (posts) {
        final mediaUrls = posts.expand((item) => item.mediaUrls).toList();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mediaUrls.length,
          padding: const EdgeInsets.only(
            top: 4,
            left: 8,
            right: 8,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            //final post = posts[index];
            return CachedImage.profileBoardImage(
              mediaUrls[index],
            );
            /*  return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransitionMethods.fadeIn(
                    VerticalScrollview(
                      scrollToPopOption: ScrollToPopOption.both,
                      dragToPopDirection: DragToPopDirection.toBottom,
                      child: ImagesView(
                        imageUrls:
                            imageUrls.map((item) => item.imageUrl).toList(),
                        initialIndex: index,
                      ),
                    ),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
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
          
           */
          },
        );
      },
      error: (e, s) => Text("error : $e, $s"),
      loading: () => const SizedBox(),
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
            onPressed: () {},
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportUserScreen(user),
                    ),
                  );
                },
              ),
              FocusedMenuItem(
                backgroundColor: ThemeColor.background,
                title: const Text(
                  "ブロック",
                ),
                onPressed: () {
                  UserBottomModelSheet(context).blockUserBottomSheet(user);
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
              FutureBuilder(
                  future: ref
                      .read(friendIdListNotifierProvider.notifier)
                      .getFriends(user.userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }
                    final users = snapshot.data!;
                    users.removeWhere((e) => !friendIds.contains(e.userId));
                    final shorten = users.length > 2;

                    return FadeTransitionWidget(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 24,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Wrap(
                                  children: (shorten
                                          ? users.sublist(0, 2)
                                          : users)
                                      .map(
                                        (user) => Container(
                                          margin: const EdgeInsets.all(2),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: Container(
                                              color: ThemeColor.stroke,
                                              height: 20,
                                              width: 20,
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
                                                        height: 20,
                                                        width: 20,
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
                                  "共通の友達${users.length}人",
                                  style: textStyle.w600(
                                    fontSize: 12,
                                    color: user
                                        .canvasTheme.profileSecondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(24),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: themeSize.horizontalPaddingLarge,
                            ),
                            child: UserRequestButton(
                              user: user,
                              hasNoMutualFriends: users.isEmpty,
                            ),
                          )
                        ],
                      ),
                    );
                  }),
              Gap(themeSize.screenHeight * 0.3),
            ],
          ),
        ),
      ),
    );
  }
}
