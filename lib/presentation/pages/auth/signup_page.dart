import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/pages/auth/signin_page.dart';
import 'package:app/presentation/providers/shared/auth/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final signupProcessProvider = StateProvider.autoDispose((ref) => false);

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

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
                    "登録",
                    style: textStyle.w600(fontSize: 24),
                  ),
                  const Gap(24),
                  Column(
                    children: [
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
                            ref.read(emailInputTextProvider.notifier).state =
                                text;
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

                      //password
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: ThemeColor.stroke,
                        ),
                        child: TextFormField(
                          cursorColor: ThemeColor.text,
                          onChanged: (text) {
                            ref.read(passwordInputTextProvider.notifier).state =
                                text;
                          },
                          obscureText: !ref.watch(passwordVisibleProvider),
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
                              vertical: 12,
                              horizontal: 16,
                            ),
                            hintStyle: textStyle.w400(
                              color: ThemeColor.subText,
                              fontSize: 14,
                            ),
                            hintText: "password",
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: GestureDetector(
                                onTap: () {
                                  ref
                                          .read(passwordVisibleProvider.notifier)
                                          .state =
                                      !ref.read(passwordVisibleProvider);
                                },
                                child: Icon(
                                  ref.watch(passwordVisibleProvider)
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: ThemeColor.subText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                        child: ref.watch(errorTextProvider).length > 8 &&
                                ref.watch(errorTextProvider).substring(0, 8) ==
                                    "password"
                            ? Text(
                                "パスワードが短すぎます",
                                style: textStyle.w600(color: ThemeColor.error),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 56,
                  ),
                  Material(
                    color: ThemeColor.highlight,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () async {
                        primaryFocus?.unfocus();

                        final status =
                            await ref.watch(authNotifierProvider).signUp();
                        ref.read(errorTextProvider.notifier).state = status;
                        ref.read(signupProcessProvider.notifier).state = false;
                        if (status == "success") {
                          Navigator.popUntil(context, (route) => route.isFirst);
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
                          "登録する",
                          style: TextStyle(
                            color: ThemeColor.background,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "既にアカウントをお持ちの方は ",
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: ThemeColor.highlight,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                              settings: const RouteSettings(name: "sign_in"),
                            ),
                          );
                        },
                        child: const Text(
                          "こちら",
                          style: TextStyle(
                            color: ThemeColor.highlight,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: ThemeColor.subText,
                            decorationThickness: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: ref.watch(signupProcessProvider) ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: Visibility(
                visible: ref.watch(signupProcessProvider),
                child: ShaderWidget(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "サインアップ中",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(12),
                        CircularProgressIndicator(
                          strokeWidth: 1.2,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
