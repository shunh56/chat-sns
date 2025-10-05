import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/utils/theme.dart';

/// タイムラインページのロゴヘッダーコンポーネント
class TimelineLogoHeader extends ConsumerWidget {
  const TimelineLogoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));

    return Container(
      height: kToolbarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: themeSize.horizontalPadding,
      ),
      child: Center(
        child: SizedBox(
          height: 72,
          width: 72,
          child: SvgPicture.asset(
            'assets/images/icons/bg_transparent.svg',
          ),
        ),
      ),
    );
  }
}
