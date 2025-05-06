import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/presentation/pages/settings/notification_settings/direct_messages_screen.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostNotificationScreen extends ConsumerWidget {
  const PostNotificationScreen({super.key});

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
            "投稿",
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
                explanation: "この設定をオンにすると、フレンドの投稿時に通知を受け取ります。",
                value: notificationData.post,
                onChanged: (val) {
                  notificationDataNotifier.state = notificationData.copyWith(
                    post: val,
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
