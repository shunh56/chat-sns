import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/invite_code.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/button/basic.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/components/widgets/fade_transition_widget.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class InvitedFromScreen extends ConsumerWidget {
  const InvitedFromScreen(
      {super.key, required this.inviteCode, required this.user});
  final InviteCode inviteCode;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Scaffold(
      body: FadeTransitionWidget(
        child: Center(
          child: Column(
            children: [
              Gap(themeSize.screenHeight * 0.2),
             UserIcon(user: user,width: 120,navDisabled: true,),
              Gap(themeSize.verticalPaddingLarge),
              Text(
                "${user.name}さんに",
                style: textStyle.w600(
                  fontSize: 20,
                ),
              ),
              Text(
                "招待されました",
                style: textStyle.w600(
                  fontSize: 20,
                ),
              ),
              Gap(themeSize.verticalPaddingLarge),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding),
                child: BasicButton(
                  text: "招待を受ける",
                  ontap: () async {
                    ref
                        .read(myAccountNotifierProvider.notifier)
                        .useInviteCode(inviteCode);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
