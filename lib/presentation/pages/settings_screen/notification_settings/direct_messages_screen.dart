import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectMessageNotificationScreen extends ConsumerWidget {
  const DirectMessageNotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final notificationData = ref.watch(notificationDataProvider);
    final notificationDataNotifier =
        ref.read(notificationDataProvider.notifier);
    return PopScope(
      onPopInvoked: (didPop) {
        ref
            .read(myAccountNotifierProvider.notifier)
            .updateNotificationData(notificationData);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "ダイレクトメッセージ",
            style: textStyle.w600(fontSize: 16),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: themeSize.horizontalPadding,
            vertical: 12,
          ),
          child: Column(
            children: [
              SettingTile(
                title: "通知をオン",
                explanation: "この設定をオンにすると、ダイレクトメッセージに対する通知を受信します。",
                value: notificationData.directMessage,
                onChanged: (val) {
                  notificationDataNotifier.state = notificationData.copyWith(
                    directMessage: val,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingTile extends ConsumerWidget {
  const SettingTile({
    super.key,
    required this.title,
    required this.explanation,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String explanation;
  final bool value;
  final Function onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: textStyle.w800(
                  fontSize: 16,
                ),
              ),
            ),
            Switch(
              value: value,
              trackOutlineColor: WidgetStateColor.transparent,
              /* WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.isNotEmpty) return Colors.red;
                  if (states.isEmpty) return Colors.blue;
                  return Colors.transparent; // default color
                },
              ), */
              inactiveTrackColor: ThemeColor.stroke,
              inactiveThumbColor: Colors.white,
              activeColor: Colors.white,
              activeTrackColor: Colors.greenAccent,
              onChanged: (val) {
                onChanged(val);
              },
            ),
          ],
        ),
        Text(
          explanation,
          style: textStyle.w400(
            color: ThemeColor.subText,
          ),
        )
      ],
    );
  }
}
