import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/auth/signin_page.dart';
import 'package:app/presentation/providers/notifier/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          primaryFocus?.unfocus();
        },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: themeSize.screenHeight * 0.25,
                left: themeSize.horizontalPadding,
                right: themeSize.horizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "パスワードをリセット",
                    style: textStyle.w600(fontSize: 24),
                  ),
                  const Gap(24),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: ThemeColor.stroke,
                    ),
                    child: TextFormField(
                      cursorColor: ThemeColor.text,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (text) {
                        ref.read(emailInputTextProvider.notifier).state = text;
                      },
                      style: textStyle.w600(
                        color: ThemeColor.text,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        hintStyle: textStyle.w400(
                          color: ThemeColor.subText,
                          fontSize: 14,
                        ),
                        hintText: "email",
                      ),
                    ),
                  ),
                  //email
                  SizedBox(
                    height: 48,
                    child: ref.watch(errorTextProvider).length > 5 &&
                            ref.watch(errorTextProvider).substring(0, 5) ==
                                "email"
                        ? Text(
                            "不正なメールアドレスです。",
                            style: textStyle.w600(color: ThemeColor.error),
                          )
                        : const SizedBox(),
                  ),

                  Material(
                    color: ThemeColor.highlight,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () async {
                        primaryFocus?.unfocus();
                        final status = await ref
                            .watch(authNotifierProvider)
                            .resetPassword();
                        ref.read(errorTextProvider.notifier).state = status;
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "メールを送信",
                          style: TextStyle(
                            color: ThemeColor.background,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(24),

                  Material(
                    color: ThemeColor.stroke,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () async {
                        primaryFocus?.unfocus();

                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                        );

                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(
                            emailUri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          throw 'Could not launch $emailUri';
                        }
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "メールアプリを開く",
                          style: TextStyle(
                            color: ThemeColor.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
