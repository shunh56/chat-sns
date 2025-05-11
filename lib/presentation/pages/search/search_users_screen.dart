import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/presentation/pages/activities/activities_screen.dart';
import 'package:app/presentation/pages/footprint/footprint_screen.dart';
import 'package:app/presentation/pages/footprint/widget/footprint_badge.dart';
import 'package:app/presentation/pages/search/widgets/defaut_user_card_view.dart';
import 'package:app/presentation/pages/search/widgets/hashtag_user_card_view.dart';
import 'package:app/presentation/pages/search/widgets/top_feed.dart';
import 'package:app/presentation/pages/search/sub_pages/search_params_screen.dart';
import 'package:app/presentation/providers/activities_list_notifier.dart';

import 'package:app/presentation/providers/users/online_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class SearchUsersScreen extends ConsumerWidget {
  const SearchUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: ThemeColor.accent,
        onRefresh: () async {
          ref.read(newUsersNotifierProvider.notifier).refresh();
          ref.read(recentUsersNotifierProvider.notifier).refresh();
        },
        child: ListView(
          children: [
            _buildAppBar(context, ref),
            const Gap(12),
            const SearchScreenTopFeed(),
            const Gap(16),
            const DefaultUserCardView(),
            const Gap(32),
            const HashtagUserCardView(),
            const Gap(40),
          ],
        ),
      ),
    );
  }
}

_buildAppBar(BuildContext context, WidgetRef ref) {
  final themeSize = ref.watch(themeSizeProvider(context));
  final textStyle = ThemeTextStyle(themeSize: themeSize);
  return AppBar(
    backgroundColor: ThemeColor.background,
    elevation: 0,
    centerTitle: false,
    leading: null,
    automaticallyImplyLeading: false,
    toolbarHeight: kToolbarHeight,
    title: Row(
      children: [
        Text(
          appName,
          style: textStyle.w600(
            fontSize: 28,
            color: ThemeColor.white,
          ),
        ),
        const Spacer(),
        FootprintBadge(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FootprintScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    "assets/svg/footprint.svg",
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(12),
        const ActivityIcon(),
        const Gap(12),
        /* Container(
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchParamsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  "assets/svg/inbox.svg",
                ),
              ),
            ),
          ),
        ),
        const Gap(12), */
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchParamsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.search_rounded,
                  color: ThemeColor.white.withOpacity(0.8),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class ActivityIcon extends ConsumerWidget {
  const ActivityIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(activitiesListNotifierProvider);
    final widget = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ActivitiesScreen(),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.notifications_outlined,
              color: ThemeColor.icon,
            ),
          ),
        ),
      ),
    );

    return asyncValue.when(
      data: (data) {
        final count = data.where((item) => !item.isSeen).length;
        return Badge(
          isLabelVisible: count > 0,
          label: Text(
            '$count',
            style: textStyle.numText(
              color: Colors.white,
            ),
          ),
          child: widget,
        );
      },
      loading: () => widget,
      error: (_, __) => widget,
    );
  }
}
