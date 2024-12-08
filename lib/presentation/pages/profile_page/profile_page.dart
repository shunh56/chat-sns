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
import 'package:app/presentation/pages/sub_pages/user_profile_page/user_posts_list.dart';
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
final jobStateProvider = StateProvider((ref) => "");
final locationStateProvider = StateProvider<String>((ref) => '');
final tagsStateProvider = StateProvider<List<String>>((ref) => []);
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

    return asyncValue.when(
      data: (me) {
        final canvasTheme = me.canvasTheme;
        return Scaffold(
          backgroundColor: canvasTheme.bgColor,
          body: Stack(
            children: [
              SingleChildScrollView(
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
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  canvasTheme.bgColor,
                                  canvasTheme.boxBgColor,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            child: SafeArea(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                                              padding: const EdgeInsets.only(
                                                  right: 12),
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
                                                    me.links.instagram
                                                        .assetString,
                                                    color: canvasTheme
                                                        .profileLinksColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (me.links.x.isShown &&
                                              me.links.x.path != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                              if (me.location.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      me.location,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              if (me.job.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.work_outline,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      me.job,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              Icon(Icons.calendar_today,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "${me.createdAt.toDateStr}〜",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          // 興味タグ
                          if (me.tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: me.tags
                                  .map(
                                    (tag) => Container(
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
                                    ),
                                  )
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
