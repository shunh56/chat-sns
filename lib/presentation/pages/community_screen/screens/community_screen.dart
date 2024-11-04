// lib/screens/community/community_screen.dart
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/core/sticky_tabbar.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/pages/community_screen/provider/states/community_membership_provider.dart';
import 'package:app/presentation/pages/community_screen/screens/community_management_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/tabs.dart';
import 'package:app/presentation/pages/timeline_page/timeline_page.dart';
import 'package:app/presentation/providers/provider/community.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key, required this.communityId});

  final String communityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMember = ref.watch(communityMembershipProvider(communityId));
    final communityAsyncValue = ref.watch(communityNotifierProvider);

    return communityAsyncValue.when(
      data: (community) => Stack(
        children: [
          Scaffold(
            body: DefaultTabController(
              length: 4,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    _buildSliverAppBar(context, ref, community),
                    if (!isMember)
                      SliverToBoxAdapter(
                        child: _buildJoinPrompt(context, ref),
                      ),
                    SliverToBoxAdapter(
                      child: _buildHeader(context, ref, community),
                    ),
                    _buildTabBar(context, ref),
                  ];
                },
                body: TabBarView(
                  children: [
                    PostsTab(community: community!),
                    TopicsTab(community: community),
                    RoomsTab(community: community),
                    InfoTab(community: community),
                  ],
                ),
              ),
            ),
          ),
          const HeartAnimationArea(),
        ],
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, WidgetRef ref, Community community) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final currentUser = ref.watch(authProvider).currentUser;
    final isMember = ref.watch(communityMembershipProvider(communityId));
    final isModerator =
        currentUser != null && community.moderators.contains(currentUser.uid);

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.5,
        title: Text(
          community.name,
          style: textStyle.appbarText(japanese: true),
        ),
        background: Stack(
          children: [
            // 背景画像
            Positioned.fill(
              child: CachedImage.postImage(community.thumbnailImageUrl),
            ),
            // グラデーションオーバーレイ
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ThemeColor.background.withOpacity(0.1),
                      ThemeColor.background.withOpacity(0.2),
                      ThemeColor.background.withOpacity(0.4),
                      ThemeColor.background,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isModerator)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSettingsButton(context, ref, community),
          ),
        if (isMember)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                _showLeaveDialog(context, ref);
              },
              child: const Icon(
                Icons.exit_to_app_rounded,
              ),
            ),
          )
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, Community community) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: themeSize.horizontalPadding,
        vertical: 12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${community.memberCount}人のメンバー',
            style: textStyle.w400(
              color: ThemeColor.subText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyTabBarDelegete(
        TabBar(
          isScrollable: true,
          onTap: (val) {},
          padding:
              EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding - 4),
          indicator: BoxDecoration(
            color: ThemeColor.button,
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
          labelColor: ThemeColor.background,
          unselectedLabelColor: Colors.white.withOpacity(0.3),
          dividerColor: ThemeColor.background,
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
                "投稿",
                style: textStyle.tabText(),
              ),
            ),
            Tab(
              child: Text(
                "トピック",
                style: textStyle.tabText(),
              ),
            ),
            Tab(
              child: Text(
                "ルーム",
                style: textStyle.tabText(),
              ),
            ),
            Tab(
              child: Text(
                "情報",
                style: textStyle.tabText(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(
      BuildContext context, WidgetRef ref, Community community) {
    return GestureDetector(
      onTap: () async {
        ref.read(editingCommunityProvider.notifier).init(community);
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CommunityManagementScreen(),
          ),
        );
      },
      child: const Icon(Icons.settings_outlined),
    );
  }

  Widget _buildJoinPrompt(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'コミュニティに参加して\n他のユーザーと交流しよう！',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          ElevatedButton(
            onPressed: () => showJoinDialog(context, ref, communityId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              '参加する',
              style: textStyle.w600(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLeaveDialog(BuildContext context, WidgetRef ref) async {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'コミュニティから退会',
          style: textStyle.w600(
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'このコミュニティから退会しますか？',
              style: textStyle.w600(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• 投稿やコメントは削除されません\n'
              '• 再度参加することができます\n'
              '• メンバー限定のコンテンツは見れなくなります',
              style: textStyle.w400(
                fontSize: 14,
                color: ThemeColor.subText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'キャンセル',
              style: textStyle.w600(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              '退会する',
              style: textStyle.w600(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(communityMembershipProvider(communityId).notifier)
            .leaveCommunity();
        // 成功メッセージの表示
        if (context.mounted) {
          showMessage('コミュニティから退会しました');

          // 前の画面に戻る
          Navigator.pop(context);
        }
      } catch (e) {
        // エラーメッセージの表示
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

Future<void> showJoinDialog(
    BuildContext context, WidgetRef ref, String communityId) async {
  final themeSize = ref.watch(themeSizeProvider(context));
  final textStyle = ThemeTextStyle(themeSize: themeSize);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        'コミュニティに参加',
        style: textStyle.w600(
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'コミュニティルールに同意して参加しますか？',
            style: textStyle.w600(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '• 個人情報の共有は禁止です\n'
            '• 誹謗中傷は禁止です\n'
            '• 著作権を侵害する投稿は禁止です',
            style: textStyle.w400(fontSize: 14, color: ThemeColor.subText),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'キャンセル',
            style: textStyle.w600(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text(
            '同意して参加',
            style: textStyle.w600(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await ref
        .read(communityMembershipProvider(communityId).notifier)
        .joinCommunity();
  }
}
