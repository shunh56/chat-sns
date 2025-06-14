import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/data/datasource/local/hashtags.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/user_bottomsheet.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/pages/posts/post/components/style/post_style.dart';
import 'package:app/presentation/providers/footprint/footprint_manager_provider.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/pages/report/report_user_screen.dart';
import 'package:app/presentation/pages/user/user_profile_page/blocked_profile_screen.dart';
import 'package:app/presentation/pages/user/user_profile_page/user_ff_screen.dart';
import 'package:app/presentation/pages/user/user_profile_page/user_posts_list.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/users/blocks_list.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

final scrollControllerProvider = Provider((ref) => ScrollController());

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key, required this.user});
  final UserAccount user;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // ユーザー自身のプロフィールでない場合のみ足あとを残す
    if (!widget.user.isMe) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(footprintManagerProvider).visitUserProfile(widget.user);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final canvasTheme = CanvasTheme.defaultCanvasTheme();
    final user = widget.user;
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
    final thumbnailHeight = themeSize.screenWidth * 0.35;

    return Scaffold(
      backgroundColor: canvasTheme.bgColor,
      body: Stack(
        children: [
          SizedBox(
            height: themeSize.screenHeight,
          ),
          /*
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

                    /* const SizedBox(height: 24),
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
                    ), */

                    // アルバムセクション

                    const SizedBox(height: 120),
                    //_buildImages(context, ref, user),
                  ],
                ),
              ),
            ],
          ),
          */
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
                        decoration: PostCardStyling.getUserTopbarDecoration(
                          VibeColorManager.getVibeColor(user),
                        ),
                      ),
                      Positioned(
                        child: SafeArea(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(child: SizedBox()),
                                _buildTopActions(context, ref, user),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        width: themeSize.screenWidth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // プロフィール画像
                              UserIcon(
                                user: user,
                                iconType: IconType.profile,
                              ),

                              if (user.links.isShown)
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      if (user.links.instagram.isShown &&
                                          user.links.instagram.path != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 12),
                                          child: GestureDetector(
                                            onTap: () async {
                                              launchUrl(
                                                Uri.parse(
                                                  user.links.instagram.url!,
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Image.asset(
                                                user.links.instagram
                                                    .assetString,
                                                color: canvasTheme
                                                    .profileLinksColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (user.links.x.isShown &&
                                          user.links.x.path != null)
                                        GestureDetector(
                                          onTap: () {
                                            launchUrl(
                                              Uri.parse(user.links.x.url!),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          },
                                          child: SizedBox(
                                            height: 21,
                                            width: 21,
                                            child: Image.asset(
                                              user.links.x.assetString,
                                              color:
                                                  canvasTheme.profileLinksColor,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              const Expanded(child: SizedBox()),
                              _buildFollowButton(),

                              /*
                              const Gap(12),
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(navigationRouterProvider(context))
                                      .goToChat(user);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: SizedBox(
                                    height: 19,
                                    width: 19,
                                    child: SvgPicture.asset(
                                      "assets/images/icons/chat.svg",
                                      // ignore: deprecated_member_use
                                      color: canvasTheme.profileTextColor,
                                    ),
                                  ),
                                ),
                              ), */
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                //プロフィール
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ユーザー名
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            user.name,
                            style: textStyle.w600(
                              fontSize: 24,
                              color: ThemeColor.white,
                              height: 1.1,
                            ),
                          ),
                          const Gap(8),
                          if (!user.greenBadge)
                            Text(
                              user.badgeStatus,
                              style: textStyle.w600(
                                color: ThemeColor.subText,
                              ),
                            )
                        ],
                      ),

                      const Gap(4),
                      Text(
                        "@${user.username}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThemeColor.subText,
                        ),
                      ),
                      // 自己紹介
                      if (user.aboutMe.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            user.aboutMe,
                            style: textStyle.w500(
                              color: ThemeColor.white,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // メタ情報

                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (user.location.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: ThemeColor.subText,
                                    size: 16,
                                  ),
                                  const Gap(2),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: Text(
                                      user.location,
                                      style: textStyle.w400(
                                        color: ThemeColor.subText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (user.job.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.work_outline,
                                    color: ThemeColor.subText,
                                    size: 16,
                                  ),
                                  const Gap(2),
                                  Text(
                                    user.job,
                                    style: textStyle.w400(
                                      color: ThemeColor.subText,
                                    ),
                                  ),
                                ],
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: ThemeColor.subText,
                                  size: 14,
                                ),
                                const Gap(4),
                                Text(
                                  "${user.createdAt.toDateStr}〜",
                                  style: textStyle.w400(
                                    color: ThemeColor.subText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 興味タグ
                      if (user.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.tags
                                .map(
                                  (tagId) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      getTextFromId(tagId)!,
                                      style: textStyle.w500(
                                        color: ThemeColor.textSecondary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      //_buildRequestBanner(context, ref, user),
                    ],
                  ),
                ),

                const Gap(12),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: FollowStatsSection(
                    user: user,
                  ),
                ),
                const Gap(18),

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

                /*_buildCurrentStatus(context, ref, canvasTheme, user),
                _buildTopFriends(context, ref, canvasTheme, user),
                _buildFriends(context, ref, canvasTheme, user), */
                //const Gap(24),
                // 投稿セクション
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: const Text(
                    "投稿",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                UserPostsList(userId: user.userId),

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
          Positioned(
            bottom: 32, // 下からの距離
            left: 0,
            right: 0,
            child: ref.watch(isFollowingProvider(user.userId))
                ? Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(navigationRouterProvider(context))
                                .goToChat(user);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "メッセージを送る",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ThemeColor.stroke.withOpacity(0.8),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  ThemeColor.stroke,
                                  ThemeColor.background,
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
                      const Gap(12),
                    ],
                  )
                : Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ThemeColor.stroke.withOpacity(0.8),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ThemeColor.stroke,
                              ThemeColor.background,
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
  }

  Widget _buildFollowButton() {
    return Consumer(
      builder: (context, ref, child) {
        final themeSize = ref.watch(themeSizeProvider(context));
        final textStyle = ThemeTextStyle(themeSize: themeSize);
        final user = widget.user;
        final notifier = ref.read(followingListNotifierProvider.notifier);
        final isFollowing = ref.watch(isFollowingProvider(user.userId));
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
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
                width: 108,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    !isFollowing ? 'フォロー' : 'フォロー中',
                    style: textStyle.w600(
                      fontSize: 14,
                      color: isFollowing
                          ? ThemeColor.white
                          : ThemeColor.background,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopActions(
      BuildContext context, WidgetRef ref, UserAccount user) {
    final canvasTheme = CanvasTheme.defaultCanvasTheme();
    //final friendIds = ref.watch(friendIdsProvider);

    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          /*if (isFriend)
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
            ), */
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
              /* if (isFriend)
                FocusedMenuItem(
                  backgroundColor: ThemeColor.background,
                  title: const Text(
                    "フレンド解除",
                  ),
                  onPressed: () {
                    UserBottomModelSheet(context).quitFriendBottomSheet(user);
                  },
                ), */
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

/*  Widget _buildFriends(BuildContext context, WidgetRef ref,
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
                        .read(friendsUsecaseProvider)
                        .getFriendIds(user.userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      final userIds = snapshot.data!;
                      return FutureBuilder(
                        future: ref
                            .read(allUsersNotifierProvider.notifier)
                            .getUserAccounts(userIds),
                        builder: (context, snapshots) {
                          if (!snapshots.hasData) {
                            return const SizedBox();
                          }
                          final friends = snapshots.data!;
                          final users = friends
                              .where((item) =>
                                  !user.topFriends.contains(item.userId))
                              .toList();
                          if (users.isEmpty) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                          for (int i = 0;
                              i < min(displayCount, users.length);
                              i++) {
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
                      );
                    }),
              ],
            ),
          ),
          const Gap(12),
        ],
      ),
    );
  } */

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

class FollowStatsSection extends ConsumerWidget {
  const FollowStatsSection({super.key, required this.user});

  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserFFScreen(user: user),
                ),
              );
            },
            child: _buildStat(
              context: context,
              count: user.followerCount,
              label: 'フォロワー',
              textStyle: textStyle,
            ),
          ),
          const Gap(24),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserFFScreen(
                    user: user,
                    index: 1,
                  ),
                ),
              );
            },
            child: _buildStat(
              context: context,
              count: user.followingCount,
              label: 'フォロー中',
              textStyle: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required BuildContext context,
    required int count,
    required String label,
    required ThemeTextStyle textStyle,
  }) {
    final canvasTheme = CanvasTheme.defaultCanvasTheme();
    return Row(
      children: [
        Text(
          count.toString(),
          style:
              textStyle.w600(fontSize: 16, color: canvasTheme.profileTextColor),
        ),
        const Gap(4),
        Text(
          label,
          style: textStyle.w400(
            fontSize: 12,
            color: canvasTheme.profileTextColor,
          ),
        ),
      ],
    );
  }
}
