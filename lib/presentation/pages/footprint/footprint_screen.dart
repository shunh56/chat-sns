import 'package:app/core/analytics/screen_name.dart';
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/user/user_profile_page/user_ff_screen.dart';
import 'package:app/presentation/providers/footprint/footprint_manager_provider.dart';
import 'package:app/presentation/providers/footprint/visited_provider.dart';
import 'package:app/presentation/providers/footprint/visitors_provider.dart';
import 'package:app/presentation/providers/shared/app/session_provider.dart';
import 'package:app/presentation/providers/users/user_by_user_id_provider.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    // 日付ごとにフットプリントをグループ化
    final Map<String, List<Footprint>> groupedFootprints = {};

    for (final footprint in footprints) {
      final dateKey = _getDateKey(footprint.visitedAt);
      if (!groupedFootprints.containsKey(dateKey)) {
        groupedFootprints[dateKey] = [];
      }
      groupedFootprints[dateKey]!.add(footprint);
    }

    // 日付キーを降順にソート
    final sortedDates = groupedFootprints.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return CustomScrollView(
      slivers: [
        for (final dateKey in sortedDates) ...[
          // 日付ヘッダー
          SliverToBoxAdapter(
            child: _buildDateHeader(
                context, groupedFootprints[dateKey]![0].visitedAt),
          ),
          // グリッドビュー (2列)
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8, // カードのアスペクト比を調整
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final footprint = groupedFootprints[dateKey]![index];
                  return AnimatedFootprintGridCard(
                    footprint: footprint,
                    onDelete: () => onDelete(footprint),
                    delay: Duration(milliseconds: index * 50),
                    isVisitedTile: isVisitedTile,
                  );
                },
                childCount: groupedFootprints[dateKey]!.length,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getDateKey(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDateHeader(BuildContext context, Timestamp timestamp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      child: Text(
        timestamp.toDateStr,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class AnimatedFootprintGridCard extends HookConsumerWidget {
  final Footprint footprint;
  final VoidCallback onDelete;
  final Duration delay;
  final bool isVisitedTile;

  const AnimatedFootprintGridCard({
    super.key,
    required this.footprint,
    required this.onDelete,
    this.delay = Duration.zero,
    this.isVisitedTile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      )),
    );

    // グリッド用に横からではなく下からのスライドインに変更
    final slideAnimation = useAnimation(
      Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      )),
    );

    useEffect(() {
      Future.delayed(delay, () {
        animationController.forward();
      });
      return null;
    }, []);

    final userAsyncValue = ref.watch(userByUserIdProvider(footprint.visitorId));

    return Opacity(
      opacity: fadeAnimation,
      child: Transform.translate(
        offset: slideAnimation,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          color: ThemeColor.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: userAsyncValue.when(
            data: (user) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    ref
                        .read(navigationRouterProvider(context))
                        .goToProfile(user);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: user.imageUrl != null
                            ? CachedImage.usersCard(user.imageUrl!)
                            : const SizedBox(),
                      ),
                      const Gap(8),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 0,
                          bottom: 8,
                          left: 8,
                          right: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVisitedTile)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: onDelete,
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.1),
                                    foregroundColor:
                                        Colors.white.withOpacity(0.5),
                                  ),
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
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, stack) => Center(
              child: Icon(Icons.error,
                  color: Colors.red.withOpacity(0.7), size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

// 既存のサポートクラスの修正版 (必要な部分のみ)
class FootprintLoadingState extends StatelessWidget {
  const FootprintLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

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
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("更新する"),
            onPressed: isVisitedTile
                ? () {
                    ref.invalidate(visitedProvider);
                  }
                : () {
                    ref.invalidate(visitorsProvider);
                  },
            style: ElevatedButton.styleFrom(
              foregroundColor: ThemeColor.subText,
              backgroundColor: ThemeColor.accent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class FootprintErrorState extends StatelessWidget {
  final Object error;

  const FootprintErrorState({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
              onPressed: () {
                // リトライロジック
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
