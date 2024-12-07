import 'dart:math';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/profile_bottomsheet.dart';
import 'package:app/presentation/components/core/sticky_tabbar.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/profile_page/edit_canvas_theme_screem.dart';
import 'package:app/presentation/pages/profile_page/edit_current_status_screen.dart';
import 'package:app/presentation/pages/profile_page/edit_top_friends.dart';
import 'package:app/presentation/pages/sub_pages/post_images_screen.dart';
import 'package:app/presentation/pages/sub_pages/user_profile_page/user_posts_list.dart';
import 'package:app/presentation/phase_01/friends_screen.dart';
import 'package:app/presentation/providers/provider/images/images.dart';
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
  const ProfileScreen({super.key, this.canPop = false});
  final bool canPop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(myAccountNotifierProvider);

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final thumbnailHeight = themeSize.screenWidth * 0.35;
    const height = 112.0;
    //return ProfileScreens();
    return asyncValue.when(
      data: (me) {
        final canvasTheme = me.canvasTheme;
        return Scaffold(
          backgroundColor: canvasTheme.bgColor,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー部分（グラデーション背景）
                SizedBox(
                  height: thumbnailHeight + 56,
                  child: Stack(
                    children: [
                      Container(
                        height: thumbnailHeight,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blue, Colors.purple],
                          ),
                        ),
                      ),
                      Positioned(
                        child: SafeArea(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'BLANK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(canvasThemeProvider.notifier)
                                            .state = canvasTheme;
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
                                        ProfileBottomSheet(context)
                                            .openBottomSheet(me);
                                      },
                                      child: Icon(
                                        Icons.settings_outlined,
                                        color: canvasTheme.profileTextColor,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // プロフィール画像
                              UserIconCanvasIcon(user: me),

                              if (me.links.isShown)
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      if (me.links.instagram.isShown &&
                                          me.links.instagram.path != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 12),
                                          child: GestureDetector(
                                            onTap: () async {
                                              launchUrl(
                                                Uri.parse(
                                                  me.links.instagram.url!,
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Image.asset(
                                                me.links.instagram.assetString,
                                                color: canvasTheme
                                                    .profileLinksColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (me.links.x.isShown &&
                                          me.links.x.path != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 12),
                                          child: GestureDetector(
                                            onTap: () {
                                              launchUrl(
                                                Uri.parse(me.links.x.url!),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                            child: SizedBox(
                                              height: 21,
                                              width: 21,
                                              child: Image.asset(
                                                me.links.x.assetString,
                                                color: canvasTheme
                                                    .profileLinksColor,
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
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                //プロフィール
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ユーザー名
                      Text(
                        me.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${me.username}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 12),
                      // 自己紹介
                      Text(
                        me.aboutMe,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 12),
                      // メタ情報
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: Colors.white.withOpacity(0.7), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'New York',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.work_outline,
                              color: Colors.white.withOpacity(0.7), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Engineer',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.calendar_today,
                              color: Colors.white.withOpacity(0.7), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '2024年11月11日',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // 興味タグ
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['UIデザイン', '写真', '旅行', 'テクノロジー']
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const Gap(24),

                /*  // 共通の友達
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '共通の友達',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 40,
                        child: Stack(
                          children: List.generate(
                              4,
                              (index) => Positioned(
                                    left: index * 24.0,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(me.imageUrl!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(24), */

                _buildCurrentStatus(context, ref, canvasTheme, me),
                _buildTopFriends(context, ref, canvasTheme, me),
                _buildFriends(context, ref, canvasTheme, me),
                // 投稿セクション
                const Gap(24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Text(
                    '投稿',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                UserPostsList(userId: me.userId),

                /*  const SizedBox(height: 24),
                // 参加中のコミュニティ
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: const Text(
                    '参加中のコミュニティ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Gap(8),
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    margin:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(me.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  'UIデザイナーズ',
                                  'Tech Creators',
                                  'Photography Club'
                                ][index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${[1240, 3500, 890][index]}メンバー',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
 */
                const Gap(120),
              ],
            ),
          ),
        );

        /*   return Scaffold(
          backgroundColor: canvasTheme.bgColor,
          body: Stack(
            children: [
              DefaultTabController(
                length: 3,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      expandedHeight: height,
                      pinned: true,
                      stretch: true,
                      backgroundColor: canvasTheme.bgColor,
                      flexibleSpace: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          final top = constraints.biggest.height;
                          final expandedHeight = height + statusBarHeight;
                          // 展開率を計算（1.0が完全展開、0.0が完全収縮）
                          final expandRatio =
                              ((top - kToolbarHeight - statusBarHeight) /
                                      (expandedHeight -
                                          kToolbarHeight -
                                          statusBarHeight))
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
                                            UserIconCanvasIcon(user: me),
                                            const Expanded(
                                              child: SizedBox(),
                                            ),
                                            SizedBox(
                                              height: kToolbarHeight,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      ref
                                                          .read(
                                                              canvasThemeProvider
                                                                  .notifier)
                                                          .state = canvasTheme;
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
                                                      color: canvasTheme
                                                          .profileTextColor,
                                                    ),
                                                  ),
                                                  const Gap(12),
                                                  GestureDetector(
                                                    onTap: () {
                                                      ProfileBottomSheet(
                                                              context)
                                                          .openBottomSheet(me);
                                                    },
                                                    child: Icon(
                                                      Icons.settings_outlined,
                                                      color: canvasTheme
                                                          .profileTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
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
                                                  user: me,
                                                  width: 40,
                                                  navDisabled: true,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  me.name,
                                                  style: textStyle.w600(
                                                    fontSize: 16,
                                                    color: canvasTheme
                                                        .profileTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  ref
                                                      .read(canvasThemeProvider
                                                          .notifier)
                                                      .state = canvasTheme;
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
                                                  color: canvasTheme
                                                      .profileTextColor,
                                                ),
                                              ),
                                              const Gap(12),
                                              GestureDetector(
                                                onTap: () {
                                                  ProfileBottomSheet(context)
                                                      .openBottomSheet(me);
                                                },
                                                child: Icon(
                                                  Icons.settings_outlined,
                                                  color: canvasTheme
                                                      .profileTextColor,
                                                ),
                                              ),
                                            ],
                                          )
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
                      child: Column(
                        children: [
                          /* Padding(
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
                                      GestureDetector(
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
                                      ),
                                      const Gap(12),
                                      GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(canvasThemeProvider.notifier)
                                              .state = canvasTheme;
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
                                          ProfileBottomSheet(context)
                                              .openBottomSheet(me);
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
                          ), */
                          Container(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            color: canvasTheme.bgColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            me.name,
                                            style: textStyle.w600(
                                              fontSize: 24,
                                              color:
                                                  canvasTheme.profileTextColor,
                                            ),
                                          ),
                                          Text(
                                            "${me.createdAt.toDateStr}〜",
                                            style: textStyle.w600(
                                              fontSize: 14,
                                              color: canvasTheme
                                                  .profileSecondaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(12),
                                Text(
                                  me.aboutMe,
                                  style: textStyle.w600(
                                    fontSize: 14,
                                    color: canvasTheme.profileAboutMeColor,
                                  ),
                                ),
                                if (me.links.isShown)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Row(
                                      children: [
                                        if (me.links.instagram.isShown &&
                                            me.links.instagram.path != null)
                                          GestureDetector(
                                            onTap: () async {
                                              launchUrl(
                                                Uri.parse(
                                                  me.links.instagram.url!,
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                              //showMessage("${me.links.instagram.url}");
                                            },
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Image.asset(
                                                me.links.instagram.assetString,
                                                color: canvasTheme
                                                    .profileLinksColor,
                                              ),
                                            ),
                                          ),
                                        if (me.links.x.isShown &&
                                            me.links.x.path != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 12),
                                            child: GestureDetector(
                                              onTap: () {
                                                launchUrl(
                                                  Uri.parse(me.links.x.url!),
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              },
                                              child: SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: Image.asset(
                                                  me.links.x.assetString,
                                                  color: canvasTheme
                                                      .profileLinksColor,
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
                    ),

                    //tabbar
                    _buildTabBar(context, ref, me.canvasTheme),
                    SliverFillRemaining(
                      child: TabBarView(
                        children: [
                          CustomScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    const Gap(12),
                                    _buildCurrentStatus(
                                        context, ref, canvasTheme, me),
                                    _buildTopFriends(
                                        context, ref, canvasTheme, me),
                                    _buildFriends(
                                        context, ref, canvasTheme, me),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // 投稿タブ

                          UserPostsThread(
                              userId: ref.read(authProvider).currentUser!.uid),
                          // アルバムタブ
                          _buildImages(context, ref, me),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if (canPop)
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
      */
      },
      error: (e, s) => const Scaffold(),
      loading: () => const Scaffold(),
    );
  }

  Widget _buildTabBar(
      BuildContext context, WidgetRef ref, CanvasTheme canvasTheme) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyTabBarDelegete(
        bgColor: canvasTheme.bgColor,
        TabBar(
          isScrollable: true,
          onTap: (val) {},
          padding:
              EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding - 4),
          indicator: BoxDecoration(
            color: canvasTheme.boxBgColor,
            borderRadius: BorderRadius.circular(100),
          ),
          tabAlignment: TabAlignment.start,
          indicatorPadding: const EdgeInsets.only(
            left: 4,
            right: 4,
            top: 5,
            bottom: 7,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 24),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: canvasTheme.boxTextColor,
          unselectedLabelColor: canvasTheme.boxTextColor,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              // Use the default focused overlay color
              return states.contains(WidgetState.focused)
                  ? null
                  : Colors.transparent;
            },
          ),
          tabs: [
            Tab(
              child: Text(
                "情報",
                style: textStyle.tabText(),
              ),
            ),
            Tab(
              child: Text(
                "投稿",
                style: textStyle.tabText(),
              ),
            ),
            /* Tab(
              child: Text(
                "ルーム",
                style: textStyle.tabText(),
              ),
            ), */
            Tab(
              child: Text(
                "アルバム",
                style: textStyle.tabText(),
              ),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
    //final map = ref.read(allUsersNotifierProvider).asData!.value;
    //final users = me.topFriends.map((userId) => map[userId]!).toList();
    final imageWidth = (themeSize.screenWidth -
                2 * themeSize.horizontalPadding -
                canvasTheme.boxWidth * 2 -
                32) /
            5 -
        8;

    return FutureBuilder(
        future: ref
            .read(allUsersNotifierProvider.notifier)
            .getUserAccounts(me.topFriends),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }
          final users = snapshot.data!;
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
                                          .read(
                                              navigationRouterProvider(context))
                                          .goToProfile(user);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                                      width: imageWidth,
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              color: ThemeColor.accent,
                                              height: imageWidth,
                                              width: imageWidth,
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
                                                        height: imageWidth,
                                                        width: imageWidth,
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
                                              color: canvasTheme
                                                  .boxSecondaryTextColor,
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
        });
  }

  Widget _buildFriends(BuildContext context, WidgetRef ref,
      CanvasTheme canvasTheme, UserAccount me) {
    final themeSize = ref.watch(themeSizeProvider(context));

    const displayCount = 5;
    const imageRadius = 24.0;
    const stroke = 4.0;
    final asyncValue = ref.watch(friendIdListNotifierProvider);
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
                    friendInfos.sort((a, b) =>
                        b.engagementCount.compareTo(a.engagementCount));
                    final friendIds = friendInfos.map((item) => item.userId);

                    final userIds = friendIds
                        .where((userId) => !me.topFriends.contains(userId))
                        .toList();

                    final map =
                        ref.read(allUsersNotifierProvider).asData!.value;

                    final users = userIds
                        .where(((userId) => map[userId] != null))
                        .map((userId) => map[userId]!)
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

  Widget _buildImages(BuildContext context, WidgetRef ref, UserAccount me) {
    final asyncValue = ref.watch(imagesPostsNotiferProvider(me.userId));
    final themeSize = ref.watch(themeSizeProvider(context));

    final imageHeight = (themeSize.screenWidth / 3 - 8) * 4 / 3;

    return asyncValue.when(
      data: (posts) {
        if (posts.isEmpty) return const SizedBox();
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
        final mediaUrls = posts.expand((item) => item.mediaUrls).toList();
        return GridView.builder(
          itemCount: mediaUrls.length,
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            top: 12,
            bottom: 120,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                // UserImageBottomSheet(context).showImageMenu(userImage);
              },
              onTap: () {
                Navigator.push(
                  context,
                  PageTransitionMethods.fadeIn(
                    VerticalScrollview(
                      scrollToPopOption: ScrollToPopOption.both,
                      dragToPopDirection: DragToPopDirection.toBottom,
                      child: PostImageHero(
                        imageUrls:
                            posts.expand((item) => item.mediaUrls).toList(),
                        aspectRatios:
                            posts.expand((item) => item.aspectRatios).toList(),
                        initialIndex: index,
                      ),
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: imageHeight,
                width: imageHeight,
                child: CachedImage.profileBoardImage(
                  mediaUrls[index],
                ),
              ),
            );
            /*v */
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
        );
      },
      error: (e, s) => Text("error : $e, $s"),
      loading: () => const SizedBox(),
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.tabBar, this.backgroundColor);

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
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
