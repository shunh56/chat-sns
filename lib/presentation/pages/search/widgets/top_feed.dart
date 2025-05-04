import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/profile/subpages/select_hashtag_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class SearchScreenTopFeed extends ConsumerWidget {
  const SearchScreenTopFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SelectHashtagScreen(),
            ),
          );
        },
        child: SvgPicture.asset(
          'assets/svg/hashtag_feed.svg',
          width: themeSize.screenWidth,
        ),
      ),
    );
  }
}
