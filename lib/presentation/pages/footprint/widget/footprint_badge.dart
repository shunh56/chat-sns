import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/footprint/unread_count_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FootprintBadge extends ConsumerWidget {
  final Widget child;

  const FootprintBadge({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final unreadCountState = ref.watch(unreadFootprintCountProvider);

    return unreadCountState.when(
      data: (count) {
        return Badge(
          isLabelVisible: count > 0,
          label: Text(
            '$count',
            style: textStyle.numText(
              color: Colors.white,
            ),
          ),
          child: child,
        );
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}
