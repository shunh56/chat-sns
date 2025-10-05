import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/sticky_tabbar.dart';
import 'package:app/presentation/providers/state/scroll_controller.dart';
import 'components/timeline_logo_header.dart';
import 'constants/timeline_constants.dart';
import 'feeds/following_feed.dart';
import 'feeds/public_feed.dart';

/// タイムラインページ
///
/// 投稿のタイムライン表示を行うメインページ
/// - パブリック投稿とフォロー投稿のタブ切り替え
/// - スクロール制御とヘッダー固定
class TimelinePage extends HookConsumerWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ref.watch(timelineScrollController);

    // スクロールトップ機能の監視
    ref.listen(scrollToTopProvider, (previous, next) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: DefaultTabController(
          length: TimelineConstants.tabCount,
          child: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                // ロゴヘッダー
                SliverList(
                  delegate: SliverChildListDelegate([
                    const TimelineLogoHeader(),
                  ]),
                ),
                // タブバー
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickyTabBarDelegete(
                    _buildTabBar(context, ref),
                  ),
                ),
              ];
            },
            // タブコンテンツ（スワイプ無効）
            body: const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                PublicPostsThread(),
                FollowingPostsThread(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// タブバーを構築
  TabBar _buildTabBar(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return TabBar(
      isScrollable: true,
      onTap: (val) {},
      padding: const EdgeInsets.symmetric(horizontal: 8 - 4),
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
          return states.contains(WidgetState.focused)
              ? null
              : Colors.transparent;
        },
      ),
      tabs: [
        Tab(
          child: Row(
            children: [
              const Icon(
                size: 18,
                Icons.public_rounded,
              ),
              const Gap(4),
              Text(
                TimelineConstants.tabTitles[TimelineTabIndex.public],
                style: textStyle.tabText(),
              ),
            ],
          ),
        ),
        Tab(
          child: Text(
            TimelineConstants.tabTitles[TimelineTabIndex.following],
            style: textStyle.tabText(),
          ),
        ),
      ],
    );
  }
}
