import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/footprint.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/user/user_profile_page/user_ff_screen.dart';
import 'package:app/presentation/providers/footprint/footprint_manager_provider.dart';
import 'package:app/presentation/providers/footprint/visited_provider.dart';
import 'package:app/presentation/providers/footprint/visitors_provider.dart';
import 'package:app/presentation/providers/users/user_by_userId_provider.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class FootprintScreen extends HookConsumerWidget {
  const FootprintScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final tabController = useTabController(initialLength: 2);
    final visitorsState = ref.watch(visitorsProvider);
    final visitedState = ref.watch(visitedControllerProvider);

    // 足あとを表示時に既読にする
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                          ref.read(visitorsProvider.notifier).refresh();
                        },
                        child: FootprintListView(
                          footprints: visitors,
                          onDelete: (footprint) {
                            ref
                                .read(footprintManagerProvider)
                                .removeFootprint(footprint.userId);
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
                          ref
                              .read(visitedControllerProvider.notifier)
                              .refresh();
                        },
                        child: FootprintListView(
                          footprints: visited,
                          isVisitedTile: true,
                          onDelete: (footprint) {
                            ref
                                .read(footprintManagerProvider)
                                .removeFootprint(footprint.userId);
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
    /*   return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            // backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '足あと',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20,
                      bottom: 80,
                      child: Icon(
                        Icons.follow_the_signs_rounded,
                        size: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              PopupMenuButton<FootprintPrivacy>(
                icon: const Icon(Icons.settings),
                tooltip: 'プライバシー設定',
                onSelected: (privacy) {
                  // ref.read(footprintManagerProvider).updatePrivacySetting(privacy);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: FootprintPrivacy.everyone,
                    child: Row(
                      children: [
                        Icon(Icons.public, size: 20),
                        SizedBox(width: 12),
                        Text('全員に表示'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: FootprintPrivacy.friendsOnly,
                    child: Row(
                      children: [
                        Icon(Icons.people, size: 20),
                        SizedBox(width: 12),
                        Text('友達のみに表示'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: FootprintPrivacy.disabled,
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, size: 20),
                        SizedBox(width: 12),
                        Text('無効にする'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: tabController,
              indicatorColor: Theme.of(context).colorScheme.onPrimary,
              tabs: const [
                Tab(
                  icon: Icon(Icons.login),
                  text: "訪問された",
                ),
                Tab(
                  icon: Icon(Icons.logout),
                  text: "訪問した",
                ),
              ],
            ),
          ),
          SliverFillRemaining(
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

                    return FootprintListView(
                      footprints: visitors,
                      onDelete: (footprint) {
                        ref
                            .read(footprintManagerProvider)
                            .removeFootprint(footprint.userId);
                      },
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
                      );
                    }

                    return FootprintListView(
                      footprints: visited,
                      onDelete: (footprint) {
                        ref
                            .read(footprintManagerProvider)
                            .removeFootprint(footprint.userId);
                      },
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
    );
  */
  }
}

class FootprintListView extends StatelessWidget {
  final List<Footprint> footprints;
  final Function(Footprint) onDelete;
  final bool isVisitedTile;

  const FootprintListView({
    Key? key,
    required this.footprints,
    required this.onDelete,
    this.isVisitedTile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: footprints.length,
      itemBuilder: (context, index) {
        final footprint = footprints[index];

        // 日付グループ化のためのヘッダーを表示
        final bool showHeader = index == 0 ||
            !_isSameDay(
                footprints[index].updatedAt, footprints[index - 1].updatedAt);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _buildDateHeader(context, footprint.updatedAt),
            AnimatedFootprintCard(
              footprint: footprint,
              onDelete: () => onDelete(footprint),
              delay: Duration(milliseconds: index * 50),
              isVisitedTile: isVisitedTile,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, Timestamp timestamp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          timestamp.toDateStr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(Timestamp ts1, Timestamp ts2) {
    final date1 = ts1.toDate();
    final date2 = ts2.toDate();
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class AnimatedFootprintCard extends HookConsumerWidget {
  final Footprint footprint;
  final VoidCallback onDelete;
  final Duration delay;
  final bool isVisitedTile;

  const AnimatedFootprintCard({
    Key? key,
    required this.footprint,
    required this.onDelete,
    this.delay = Duration.zero,
    this.isVisitedTile = false,
  }) : super(key: key);

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

    final slideAnimation = useAnimation(
      Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero)
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

    final userAsyncValue = ref.watch(userByUserIdProvider(footprint.userId));

    return Opacity(
      opacity: fadeAnimation,
      child: Transform.translate(
        offset: slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Card(
            elevation: 2,
            color: ThemeColor.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: userAsyncValue.when(
                data: (user) {
                  //final visitTime = footprint.updatedAt.toDate();
                  //final timeString = DateFormat('HH:mm').format(visitTime);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        ref
                            .read(navigationRouterProvider(context))
                            .goToProfile(user);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            CachedImage.userIcon(user.imageUrl, user.name, 30),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /*Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${footprint.count}回目',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Gap(8), */
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isVisitedTile)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: onDelete,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.grey.withOpacity(0.1),
                                  foregroundColor: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  title: LinearProgressIndicator(),
                  subtitle: SizedBox(height: 20),
                ),
                error: (error, stack) => ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red.withOpacity(0.2),
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                  title: const Text('ユーザーを読み込めませんでした'),
                  subtitle: Text(
                    error.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyFootprintState extends ConsumerWidget {
  final String message;
  final IconData icon;
  final bool isVisitedTile;

  const EmptyFootprintState({
    Key? key,
    required this.message,
    required this.icon,
    this.isVisitedTile = false,
  }) : super(key: key);

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
                    ref.read(visitedControllerProvider.notifier).loadVisited();
                  }
                : () {
                    ref.read(visitorsProvider.notifier).refresh();
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

class FootprintLoadingState extends StatelessWidget {
  const FootprintLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: 240,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
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

class FootprintErrorState extends StatelessWidget {
  final Object error;

  const FootprintErrorState({
    Key? key,
    required this.error,
  }) : super(key: key);

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
