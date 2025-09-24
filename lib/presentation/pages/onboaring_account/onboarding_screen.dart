import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/onboarding_providers.dart';
import 'package:app/presentation/pages/onboaring_account/account_confiirmation_screen.dart';
import 'package:app/presentation/pages/onboaring_account/image_input_screen.dart';
import 'package:app/presentation/pages/onboaring_account/name_input_screen.dart';
import 'package:app/presentation/pages/onboaring_account/username_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Progress indicator
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding,
                    vertical: 16,
                  ),
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThemeColor.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final pageIndex = ref.watch(pageIndexProvider);
                      return AnimatedAlign(
                        alignment: Alignment.centerLeft,
                        duration: const Duration(milliseconds: 300),
                        child: FractionallySizedBox(
                          widthFactor: (pageIndex + 1) / ONBOARDING_LENGTH,
                          child: Container(
                            decoration: BoxDecoration(
                              color: ThemeColor.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: ref.watch(pageControllerProvider),
                    children: const [
                      InputNameScreen(),
                      InputUsernameScreen(),
                      InputImageUrlScreen(),
                      AccountConfirmScreen(),
                    ],
                    onPageChanged: (value) =>
                        ref.read(pageIndexProvider.notifier).state = value,
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (ref.watch(creatingProcessProvider))
            Container(
              color: ThemeColor.background.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ThemeColor.primary),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "アカウント作成中...",
                      style: TextStyle(
                        color: ThemeColor.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
