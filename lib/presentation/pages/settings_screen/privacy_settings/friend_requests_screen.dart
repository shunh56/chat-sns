import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class RequestRangeScreen extends ConsumerWidget {
  const RequestRangeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final privacy = ref.watch(privacyProvider);
    final privacyNotifier = ref.read(privacyProvider.notifier);
    return PopScope(
      onPopInvoked: (didPop) {
        ref.read(myAccountNotifierProvider.notifier).updatePrivacy(privacy);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "フレンド申請",
            style: textStyle.w600(fontSize: 16),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: themeSize.horizontalPadding,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "あなたにフレンド申請を送れるユーザー",
                style: textStyle.w600(
                  color: ThemeColor.subText,
                ),
              ),
              Gap(8),
              Row(
                children: [
                  Radio(
                    activeColor: Colors.greenAccent,
                    value: PublicityRange.friendOfFriend,
                    groupValue: privacy.requestRange,
                    onChanged: (val) {
                      privacyNotifier.state = privacy.copyWith(
                        requestRange: val,
                      );
                    },
                  ),
                  Text(
                    "フレンドのフレンド",
                    style: textStyle.w600(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Radio(
                    activeColor: Colors.greenAccent,
                    value: PublicityRange.public,
                    groupValue: privacy.requestRange,
                    onChanged: (val) {
                      privacyNotifier.state = privacy.copyWith(
                        requestRange: val,
                      );
                    },
                  ),
                  Text(
                    "全員",
                    style: textStyle.w600(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
