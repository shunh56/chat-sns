import 'package:app/core/debugParams/tester_accounts.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/pages/auth/signup_page.dart';
import 'package:app/presentation/providers/notifier/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final emailInputTextProvider = StateProvider((ref) => "");
final passwordInputTextProvider = StateProvider((ref) => "");
final errorTextProvider = StateProvider.autoDispose((ref) => "");
final passwordVisibleProvider = StateProvider.autoDispose((ref) => false);
final loginProcessProvider = StateProvider.autoDispose((ref) => false);

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                top: MediaQuery.of(context).viewPadding.top + 40 + 120,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ログイン",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: ThemeColor.headline,
                        ),
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
                          cursorColor: ThemeColor.highlight,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (text) {
                            ref.read(emailInputTextProvider.notifier).state =
                                text;
                          },
                          style: const TextStyle(
                            color: ThemeColor.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            hintStyle: TextStyle(
                              color: ThemeColor.highlight,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            hintText: "email",
                          ),
                        ),
                      ),
                      //email
                      ref.watch(errorTextProvider).length > 5 &&
                              ref.watch(errorTextProvider).substring(0, 5) ==
                                  "email"
                          ? Text(
                              "不正なメールアドレスです。",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(color: ThemeColor.error),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 30,
                      ),
                      //password
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: ThemeColor.stroke,
                        ),
                        child: TextFormField(
                          cursorColor: ThemeColor.highlight,
                          onChanged: (text) {
                            ref.read(passwordInputTextProvider.notifier).state =
                                text;
                          },
                          obscureText: !ref.watch(passwordVisibleProvider),
                          style: const TextStyle(
                            color: ThemeColor.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                            hintStyle: const TextStyle(
                              color: ThemeColor.highlight,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            hintText: "password",
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: GestureDetector(
                                onTap: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable

                                  ref
                                          .read(passwordVisibleProvider.notifier)
                                          .state =
                                      !ref.read(passwordVisibleProvider);
                                },
                                child: Icon(
                                  // Based on passwordVisible state choose the icon
                                  ref.watch(passwordVisibleProvider)
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: ThemeColor.icon,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ref.watch(errorTextProvider).length > 8 &&
                              ref.watch(errorTextProvider).substring(0, 8) ==
                                  "password"
                          ? Text(
                              "パスワードが短すぎます",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(color: ThemeColor.error),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "パスワードを忘れた方は",
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: ThemeColor.highlight,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPassword(),
                              settings:
                                  const RouteSettings(name: "forgot_password"),
                            ),
                          ); */
                        },
                        child: const Text(
                          "こちら",
                          style: TextStyle(
                            color: ThemeColor.highlight,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: ThemeColor.text,
                            decorationThickness: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Material(
                    color: ThemeColor.highlight,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () async {
                        primaryFocus?.unfocus();

                        final status =
                            await ref.watch(authNotifierProvider).signIn();
                        ref.read(errorTextProvider.notifier).state = status;
                        ref.read(loginProcessProvider.notifier).state = false;
                        if (status == "success") {
                          // ignore: use_build_context_synchronously
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
                          "ログイン",
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
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "新規のユーザーは",
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: ThemeColor.highlight,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                              settings: const RouteSettings(name: "sign_up"),
                            ),
                          );
                        },
                        child: const Text(
                          "登録画面へ",
                          style: TextStyle(
                            color: ThemeColor.highlight,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: ThemeColor.text,
                            decorationThickness: 1,
                            fontFamily: "Noto Sans JP",
                          ),
                        ),
                      ),
                    ],
                  ),
                  true
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: testerAccount.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () async {
                                  ref
                                      .read(emailInputTextProvider.notifier)
                                      .state = testerAccount[index];
                                  ref
                                      .read(passwordInputTextProvider.notifier)
                                      .state = "seiko56173";

                                  final status = await ref
                                      .read(authNotifierProvider)
                                      .signIn();
                                  ref.read(errorTextProvider.notifier).state =
                                      status;
                                  ref
                                      .read(loginProcessProvider.notifier)
                                      .state = false;
                                  if (status == "success") {
                                    Navigator.popUntil(
                                        // ignore: use_build_context_synchronously
                                        context,
                                        (route) => route.isFirst);
                                  }
                                },
                                title: Text(
                                  "Login as ${testerAccount[index]}",
                                  style: const TextStyle(
                                    color: ThemeColor.headline,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: ref.watch(loginProcessProvider) ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: Visibility(
                visible: ref.watch(loginProcessProvider),
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
                          "ログイン中",
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
