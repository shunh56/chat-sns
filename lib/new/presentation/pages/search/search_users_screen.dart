import 'dart:math';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/community.dart';
import 'package:app/new/presentation/pages/search/widgets/defaut_user_card_view.dart';
import 'package:app/new/presentation/pages/search/widgets/hashtag_user_card_view.dart';
import 'package:app/new/presentation/pages/search/widgets/top_feed.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/search_screen/community_detail_screen.dart';
import 'package:app/presentation/pages/search_screen/search_params_screen.dart';
import 'package:app/presentation/pages/search_screen/user_card_stack_screen.dart';
import 'package:app/presentation/pages/search_screen/widgets/popular_hashtag_section.dart';
import 'package:app/presentation/pages/search_screen/widgets/tiles.dart';

import 'package:app/presentation/providers/new/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/online_users.dart';
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
      appBar: _buildAppBar(context, ref),
      body: RefreshIndicator(
        backgroundColor: ThemeColor.accent,
        onRefresh: () async {
          ref.read(newUsersNotifierProvider.notifier).refresh();
          ref.read(recentUsersNotifierProvider.notifier).refresh();
        },
        child: ListView(
          children: const [
            Gap(12),
            SearchScreenTopFeed(),
            Gap(16),
            DefaultUserCardView(),
            Gap(32),
            HashtagUserCardView(),
            Gap(40),
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
    title: Row(
      children: [
        Text(
          "探す",
          style: textStyle.w700(
            fontSize: 28,
            color: ThemeColor.white,
          ),
        ),
        const Spacer(),
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
                child: SvgPicture.asset(
                  "assets/svg/footprint.svg",
                ),
              ),
            ),
          ),
        ),
        const Gap(12),
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
                child: SvgPicture.asset(
                  "assets/svg/inbox.svg",
                ),
              ),
            ),
          ),
        ),
        Gap(12),
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
