import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/activities/activities_screen.dart';
import 'package:app/presentation/providers/activities_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アクティビティ通知アイコン
///
/// 未読の通知がある場合はバッジを表示する
class ActivityNotificationIcon extends ConsumerWidget {
  const ActivityNotificationIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(activitiesListNotifierProvider);

    final iconWidget = Container(
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
              size: 24,
            ),
          ),
        ),
      ),
    );

    return asyncValue.when(
      data: (data) {
        final unreadCount = data.where((item) => !item.isSeen).length;
        if (unreadCount == 0) {
          return iconWidget;
        }
        return Badge(
          isLabelVisible: true,
          label: Text(
            '$unreadCount',
            style: textStyle.numText(
              color: Colors.white,
            ),
          ),
          child: iconWidget,
        );
      },
      loading: () => iconWidget,
      error: (_, __) => iconWidget,
    );
  }
}
