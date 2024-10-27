import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagSelector extends ConsumerWidget {
  const TagSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(myAccountNotifierProvider);
    return TabBar(
      isScrollable: true,
      onTap: (val) {
        
      },
      indicator: UnderlineTabIndicator(
        borderSide: const BorderSide(
          width: 3.2,
          // color: white,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      dividerColor: ThemeColor.background,
      labelColor: ThemeColor.headline,
      indicatorSize: TabBarIndicatorSize.label,
      unselectedLabelColor: ThemeColor.headline.withOpacity(0.3),
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          // Use the default focused overlay color
          return states.contains(WidgetState.focused)
              ? null
              : Colors.transparent;
        },
      ),
      tabs: const [
        Tab(
          child: SizedBox(
            width: 80,
            child: Center(
              child: Text(
                "投稿",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Tab(
          child: SizedBox(
            width: 80,
            child: Center(
              child: Text(
                "アルバム",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Tab(
          child: SizedBox(
            width: 80,
            child: Center(
              child: Text(
                "イベント",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Tab(
          child: SizedBox(
            width: 80,
            child: Center(
              child: Text(
                "アルバム",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Tab(
          child: SizedBox(
            width: 80,
            child: Center(
              child: Text(
                "イベント",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
