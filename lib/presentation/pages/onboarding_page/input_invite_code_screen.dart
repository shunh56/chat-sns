import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/invite_code.dart';
import 'package:app/presentation/components/button/basic.dart';
import 'package:app/presentation/pages/onboarding_page/invited_by_screen.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/invite_code_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final errorTextProvider = StateProvider.autoDispose((ref) => "");

class InputInviteCodeScreen extends ConsumerWidget {
  const InputInviteCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final errorText = ref.watch(errorTextProvider);
    final inputText = ref.watch(inputTextProvider);
    final currentCode =
        ref.watch(myAccountNotifierProvider).asData!.value.usedCode;
    return GestureDetector(
      onTap: () {
        primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: Column(
              children: [
                Gap(themeSize.screenHeight * 0.2),
                Text(
                  "招待コードを入力してください",
                  style: textStyle.w600(
                    fontSize: 20,
                  ),
                ),
                Gap(
                  themeSize.screenHeight * 0.05,
                ),
                TextFormField(
                    initialValue: "",
                    autofocus: true,
                    textAlign: TextAlign.center,
                    cursorColor: ThemeColor.text,
                    style: textStyle.w600(
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      ref.read(inputTextProvider.notifier).state = value;
                      ref.read(errorTextProvider.notifier).state = "";
                    }),
                SizedBox(
                  height: themeSize.screenHeight * 0.05,
                  child: (errorText.isNotEmpty)
                      ? Text(
                          errorText,
                          style: textStyle.w600(
                            color: Colors.red,
                          ),
                        )
                      : null,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: themeSize.horizontalPadding),
                  child: BasicButton(
                    text: "次へ",
                    ontap: inputText.isEmpty
                        ? null
                        : () async {
                            final code = await ref
                                .read(inviteCodeUsecaseProvider)
                                .getInviteCode(inputText);
                            final status = code.getStatus;
                            switch (status) {
                              case InviteCodeStatus.notFound:
                                ref.read(errorTextProvider.notifier).state =
                                    "そのコードは使用できません(NOT FOUND)";
                                return;
                              case InviteCodeStatus.overLimit:
                                ref.read(errorTextProvider.notifier).state =
                                    "そのコードは使用できません(定員)";
                                return;
                              case InviteCodeStatus.usedByMe:
                                ref.read(errorTextProvider.notifier).state =
                                    "そのコードは使用できません(使用済み)";
                                return;
                              case InviteCodeStatus.unknownError:
                                ref.read(errorTextProvider.notifier).state =
                                    "そのコードは使用できません(エラー)";
                                return;
                              case InviteCodeStatus.valid:
                                final user = (await ref
                                        .read(allUsersNotifierProvider.notifier)
                                        .getUserAccounts([code.userId]))
                                    .first;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InvitedFromScreen(
                                      inviteCode: code,
                                      user: user,
                                    ),
                                  ),
                                );
                                return;
                              default:
                                ref.read(errorTextProvider.notifier).state =
                                    "そのコードは使用できません(エラー)";
                                return;
                            }
                          },
                  ),
                ),
                const Expanded(child: SizedBox()),
                /*   currentCode != "WAITING"
                    ? Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: themeSize.horizontalPadding),
                        child: Material(
                          color: ThemeColor.stroke,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(myAccountNotifierProvider.notifier)
                                  .waitInLine();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "招待コードがない方はこちら",
                                  style: textStyle.w600(
                                    fontSize: 18,
                                    color: ThemeColor.subText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: themeSize.horizontalPadding),
                        child: Material(
                          color: ThemeColor.stroke,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "待機画面に戻る",
                                  style: textStyle.w600(
                                    fontSize: 18,
                                    color: ThemeColor.subText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ), */
                Gap(MediaQuery.of(context).viewPadding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
