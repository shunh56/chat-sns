import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/state/scroll_controller.dart';
import 'package:app/presentation/providers/posts/public_posts.dart';
import 'package:app/presentation/providers/posts/following_posts.dart';
import 'components/timeline_logo_header.dart';
import 'components/timeline_square_sections.dart';
import 'feeds/public_posts_content.dart';
import 'feeds/following_posts_content.dart';

/// タイムラインページ
///
/// 投稿のタイムライン表示を行うメインページ
/// - パブリック投稿とフォロー投稿のフィルター切り替え
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
        child: RefreshIndicator(
          backgroundColor: ThemeColor.accent,
          onRefresh: () async {
            final filter = ref.read(timelineFilterProvider);

            switch (filter) {
              case TimelineFilter.public:
                await ref.read(publicPostsNotiferProvider.notifier).refresh();
                break;
              case TimelineFilter.following:
                await ref
                    .read(followingPostsNotifierProvider.notifier)
                    .refresh();
                break;
            }
          },
          child: ListView(
            controller: scrollController,
            addAutomaticKeepAlives: true,
            children: [
              // ロゴヘッダー
              const TimelineLogoHeader(),
              // アクション通知セクション
              const TimelineActionNotificationSection(),
              // フィルターに基づいたコンテンツ
              Consumer(
                builder: (context, ref, child) {
                  final filter = ref.watch(timelineFilterProvider);

                  switch (filter) {
                    case TimelineFilter.public:
                      return const PublicPostsContent();
                    case TimelineFilter.following:
                      return const FollowingPostsContent();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
