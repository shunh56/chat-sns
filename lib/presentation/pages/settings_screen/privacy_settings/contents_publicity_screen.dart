import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/presentation/providers/shared/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ContentRangeScreen extends ConsumerWidget {
  const ContentRangeScreen({super.key});

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
            "コンテンツの公開範囲",
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
                "投稿の公開範囲を決定します。",
                style: textStyle.w600(
                  color: ThemeColor.subText,
                ),
              ),
              const Gap(8),
              Row(
                children: [
                  Radio(
                    activeColor: Colors.greenAccent,
                    value: PublicityRange.onlyFriends,
                    groupValue: privacy.contentRange,
                    onChanged: (val) {
                      privacyNotifier.state = privacy.copyWith(
                        contentRange: val,
                      );
                    },
                  ),
                  Text(
                    "フレンドのみ",
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
                    value: PublicityRange.friendOfFriend,
                    groupValue: privacy.contentRange,
                    onChanged: (val) {
                      privacyNotifier.state = privacy.copyWith(
                        contentRange: val,
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
            ],
          ),
        ),
      ),
    );
  }
}
