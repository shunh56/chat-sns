import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
// import 'package:app/presentation/UNUSED/user_listview_testing_screen.dart'; // Archived
import 'package:app/presentation/pages/search/widgets/defaut_user_card_view.dart';
import 'package:app/presentation/pages/search/widgets/hashtag_user_card_view.dart';
import 'package:app/presentation/pages/search/widgets/top_feed.dart';
import 'package:app/presentation/providers/shared/users/my_user_account_notifier.dart';

import 'package:app/presentation/providers/users/online_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class SearchUsersScreen extends ConsumerWidget {
  const SearchUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    final showHashtagFeed = me.tags.isEmpty;
    //return SearchUsersScreenV2();
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: ThemeColor.accent,
        onRefresh: () async {
          ref.read(newUsersNotifierProvider.notifier).refresh();
          ref.read(recentUsersNotifierProvider.notifier).refresh();
        },
        child: ListView(
          addAutomaticKeepAlives: true,
          children: [
            _buildAppBar(context, ref),
            const Gap(8),
            if (showHashtagFeed)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: SearchScreenTopFeed(),
              ),
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
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        GestureDetector(
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SizedBox(), // NewScreen() archived
              ),
            );
          },
          child: Text(
            appName,
            style: textStyle.w600(
              fontSize: 28,
              color: ThemeColor.white,
            ),
          ),
        ),
        const Spacer(),
      ],
    ),
  );
}
