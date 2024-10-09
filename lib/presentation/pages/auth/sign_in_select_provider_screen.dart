import 'dart:io';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/auth/signin_page.dart';
import 'package:app/presentation/pages/auth/signup_page.dart';
import 'package:app/presentation/providers/notifier/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class SignInSelectProviderScreen extends ConsumerWidget {
  const SignInSelectProviderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    const borderRadius = 12.0;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          appName,
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Gap(themeSize.screenHeight * 0.15),
                Text(
                  "ログイン",
                  style: textStyle.w600(
                    fontSize: 20,
                  ),
                ),
                Gap(24),
                if (Platform.isIOS)
                  Padding(
                    padding: EdgeInsets.only(
                      left: themeSize.horizontalPadding,
                      right: themeSize.horizontalPadding,
                      bottom: 24,
                    ),
                    child: Material(
                      color: ThemeColor.white,
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: InkWell(
                        onTap: () async {
                          final status = await ref
                              .watch(authNotifierProvider)
                              .signInWithApple();
                          ref.read(loginProcessProvider.notifier).state = false;
                          if (status == "success") {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          }
                        },
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: Image.asset(
                                      'assets/images/icons/apple.png',
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  child: Text(
                                    "Appleでログイン",
                                    textAlign: TextAlign.center,
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      color: ThemeColor.background,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding,
                  ),
                  child: Material(
                    color: ThemeColor.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: InkWell(
                      onTap: () async {
                        final status = await ref
                            .watch(authNotifierProvider)
                            .signInWithGoogle();
                        ref.read(errorTextProvider.notifier).state = status;
                        ref.read(loginProcessProvider.notifier).state = false;
                        if (status == "success") {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      },
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: Image.asset(
                                    'assets/images/icons/google.png',
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: Text(
                                  "Googleでログイン",
                                  textAlign: TextAlign.center,
                                  style: textStyle.w600(
                                    fontSize: 14,
                                    color: ThemeColor.background,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: ThemeColor.subText,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("または"),
                    ),
                    Expanded(
                      child: Divider(
                        color: ThemeColor.subText,
                      ),
                    ),
                  ],
                ),
                Gap(24),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding,
                  ),
                  child: Material(
                    color: ThemeColor.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SignInPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: Icon(
                                    Icons.mail_outline,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: Text(
                                  "メールアドレスでログイン",
                                  textAlign: TextAlign.center,
                                  style: textStyle.w600(
                                    fontSize: 14,
                                    color: ThemeColor.background,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: SizedBox(),
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
    );
  }
}
