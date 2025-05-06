import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivateModeScreen extends ConsumerWidget {
  const PrivateModeScreen({super.key});

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
            "プライベートモード",
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
                title: "プライベートモードにする",
                explanation:
                    "全てのコンテンツがフレンドのみに表示されます。また、フレンドリクエストが届かなくなります。この設定をオンにすると、既存のフレンドのみと交流することができます。",
                value: privacy.privateMode,
                onChanged: (val) {
                  privacyNotifier.state = privacy.copyWith(
                    privateMode: val,
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
