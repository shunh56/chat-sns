import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/new/presentation/pages/onboarding/model.dart';
import 'package:app/new/presentation/pages/onboarding/onboarding_state.dart';
import 'package:app/new/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class OnboardingFlowScreen extends HookConsumerWidget {
  const OnboardingFlowScreen({super.key});

  static final List<OnboardingPage> pages = [
    const OnboardingPage(
      title: 'フレンドを見つけよう',
      description: '興味のあるユーザーを見つけて、つながりを広げましょう',
      imagePath: 'assets/images/friends.png',
    ),
    const OnboardingPage(
      title: '今の気分をシェア',
      description: '「いまボード」であなたの気持ちや活動を共有しましょう',
      imagePath: 'assets/images/share.png',
    ),
    const OnboardingPage(
      title: 'コミュニティに参加',
      description: '共通の興味を持つ人々と交流を深めましょう',
      imagePath: 'assets/images/community.png',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final onboardingState = ref.watch(onboardingStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                ref.read(onboardingStateProvider.notifier).changePage(index);
              },
              itemCount: pages.length,
              itemBuilder: (context, index) => OnboardingPageView(
                page: pages[index],
              ),
            ),
            _buildNavigationButtons(
              context,
              ref,
              pageController,
              onboardingState.currentPage,
            ),
            _buildPageIndicator(
              context,
              onboardingState.currentPage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, WidgetRef ref,
      PageController pageController, int currentPage) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentPage > 0)
            TextButton(
              onPressed: () {
                pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                '戻る',
                style: textStyle.w600(
                  fontSize: 14,
                  color: ThemeColor.subText,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: () async {
              if (currentPage < pages.length - 1) {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                await ref
                    .read(onboardingStateProvider.notifier)
                    .completeOnboarding();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const Phase01MainPage(),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage < pages.length - 1
                  ? ThemeColor.stroke
                  : Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              currentPage < pages.length - 1 ? '次へ' : '始める',
              style: textStyle.w600(
                fontSize: 14,
                color: ThemeColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context, int currentPage) {
    return Positioned(
      bottom: 130,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pages.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: currentPage == index ? 24 : 8,
            decoration: BoxDecoration(
              color:
                  currentPage == index ? ThemeColor.white : ThemeColor.subText,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

// lib/features/onboarding/widgets/onboarding_page_view.dart
class OnboardingPageView extends ConsumerWidget {
  const OnboardingPageView({super.key, required this.page});
  final OnboardingPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(240 * 2 / 9),
            child: Image.asset(
              page.imagePath,
              height: 240,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: textStyle.w600(
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          Text(
            page.description,
            style: textStyle.w600(
              fontSize: 14,
              color: ThemeColor.subText,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(60),
        ],
      ),
    );
  }
}
