import 'package:app/core/analytics/screen_name.dart';
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/presentation/pages/user/user_profile_page/user_ff_screen.dart';
import 'package:app/presentation/providers/footprint/footprint_manager_provider.dart';
import 'package:app/presentation/providers/footprint/visited_provider.dart';
import 'package:app/presentation/providers/footprint/visitors_provider.dart';
import 'package:app/presentation/providers/shared/app/session_provider.dart';
import 'package:app/presentation/providers/users/user_by_user_id_provider.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class FootprintScreen extends HookConsumerWidget {
  const FootprintScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final tabController = useTabController(initialLength: 2);
    final visitorsState = ref.watch(visitorsProvider);
    final visitedState = ref.watch(visitedProvider);

    // 足あとを表示時に既読にする
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(sessionStateProvider.notifier)
            .trackScreenView(ScreenName.footprintPage.value);
        ref.read(footprintManagerProvider).markAllFootprintsSeen();
      });
      return null;
    }, const []);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "足あと",
            style: textStyle.w600(fontSize: 16),
          ),
          centerTitle: true,
          backgroundColor: ThemeColor.background,
        ),
        body: Column(
          children: [
            Container(
              color: ThemeColor.background,
              child: TabBar(
                controller: tabController,
                labelColor: ThemeColor.text,
                unselectedLabelColor: ThemeColor.subText,
                indicatorColor: ThemeColor.highlight,
                dividerColor: Colors.transparent,
                indicatorWeight: 0,
                indicator: GradientTabIndicator(
                  colors: const [
                    ThemeColor.highlight,
                    Colors.cyan,
                  ],
                  weight: 2,
                  width: themeSize.screenWidth / 2.4,
                  radius: 8,
                ),
                tabs: [
                  Tab(
                    child: SizedBox(
                      width: themeSize.screenWidth / 2.4,
                      child: Center(
                        child: Text(
                          "訪問者",
                          style: textStyle.w600(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: SizedBox(
                      width: themeSize.screenWidth / 2.4,
                      child: Center(
                        child: Text(
                          "つけた足あと",
                          style: textStyle.w600(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(4),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  // 訪問された
                  visitorsState.when(
                    data: (visitors) {
                      if (visitors.isEmpty) {
                        return const EmptyFootprintState(
                          message: 'まだ誰も訪問していません',
                          icon: Icons.person_off,
                        );
                      }

                      return RefreshIndicator(
                        color: ThemeColor.text,
                        backgroundColor: ThemeColor.stroke,
                        onRefresh: () async {
                          ref.invalidate(visitorsProvider);
                        },
                        child: FootprintGridView(
                          footprints: visitors,
                          onDelete: (footprint) {
                            ref
                                .read(footprintManagerProvider)
                                .removeFootprint(footprint.visitorId);
                          },
                        ),
                      );
                    },
                    loading: () => const FootprintLoadingState(),
                    error: (error, stack) => FootprintErrorState(error: error),
                  ),

                  // 訪問した
                  visitedState.when(
                    data: (visited) {
                      if (visited.isEmpty) {
                        return const EmptyFootprintState(
                          message: 'まだ誰も訪問していません',
                          icon: Icons.travel_explore,
                          isVisitedTile: true,
                        );
                      }

                      return RefreshIndicator(
                        color: ThemeColor.text,
                        backgroundColor: ThemeColor.stroke,
                        onRefresh: () async {
                          ref.invalidate(visitedProvider);
                        },
                        child: FootprintGridView(
                          footprints: visited,
                          isVisitedTile: true,
                          onDelete: (footprint) {
                            ref
                                .read(footprintManagerProvider)
                                .removeFootprint(footprint.visitedUserId);
                          },
                        ),
                      );
                    },
                    loading: () => const FootprintLoadingState(),
                    error: (error, stack) => FootprintErrorState(error: error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FootprintGridView extends StatelessWidget {
  final List<Footprint> footprints;
  final Function(Footprint) onDelete;
  final bool isVisitedTile;

  const FootprintGridView({
    super.key,
    required this.footprints,
    required this.onDelete,
    this.isVisitedTile = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: footprints.length,
      itemBuilder: (context, index) {
        final footprint = footprints[index];
        return FootprintListTile(
          footprint: footprint,
          onDelete: () => onDelete(footprint),
          isVisitedTile: isVisitedTile,
        );
      },
    );
  }
}

/// 足あとリストタイル
class FootprintListTile extends ConsumerWidget {
  final Footprint footprint;
  final VoidCallback onDelete;
  final bool isVisitedTile;

  const FootprintListTile({
    super.key,
    required this.footprint,
    required this.onDelete,
    this.isVisitedTile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    // 訪問者タブの場合はvisitorId、つけた足あとタブの場合はvisitedUserIdを使用
    final targetUserId =
        isVisitedTile ? footprint.visitedUserId : footprint.visitorId;
    final userAsyncValue = ref.watch(userByUserIdProvider(targetUserId));

    return userAsyncValue.when(
      data: (user) {
        return InkWell(
          onTap: () {
            ref.read(navigationRouterProvider(context)).goToProfile(user);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: themeSize.horizontalPadding,
              vertical: 12,
            ),
            child: Row(
              children: [
                // ユーザーアイコン
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: user.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(user.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: user.imageUrl == null
                        ? Colors.grey.withOpacity(0.3)
                        : null,
                  ),
                  child: user.imageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 28,
                          color: Colors.white.withOpacity(0.7),
                        )
                      : null,
                ),
                const Gap(12),

                // ユーザー情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: textStyle.w600(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      Text(
                        footprint.visitedAt.xxAgo,
                        style: textStyle.w400(
                          fontSize: 13,
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),
                ),

                // 削除ボタン（つけた足あとタブのみ）
                if (isVisitedTile)
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 20,
                    color: Colors.white.withOpacity(0.5),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.symmetric(
          horizontal: themeSize.horizontalPadding,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Gap(6),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => const SizedBox(),
    );
  }
}

/// ローディング状態
class FootprintLoadingState extends StatelessWidget {
  const FootprintLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 空状態
class EmptyFootprintState extends ConsumerWidget {
  final String message;
  final IconData icon;
  final bool isVisitedTile;

  const EmptyFootprintState({
    super.key,
    required this.message,
    required this.icon,
    this.isVisitedTile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const Gap(16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColor.subText,
            ),
          ),
        ],
      ),
    );
  }
}

/// エラー状態
class FootprintErrorState extends StatelessWidget {
  final Object error;

  const FootprintErrorState({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const Gap(16),
          const Text(
            'エラーが発生しました',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColor.subText,
            ),
          ),
        ],
      ),
    );
  }
}
