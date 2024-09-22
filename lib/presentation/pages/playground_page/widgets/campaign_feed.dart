import 'dart:async';

import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CampaignFeed extends HookConsumerWidget {
  const CampaignFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double feedHeight = 180;
    final themeSize = ref.watch(themeSizeProvider(context));
    final pageController = usePageController(initialPage: 0);
    final currentPage = useState(0);

    final items = [
      'キャンペーン 1',
      'キャンペーン 2',
      'キャンペーン 3',
      'キャンペーン 4',
      'キャンペーン 5',
    ];

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (currentPage.value < items.length - 1) {
          currentPage.value++;
        } else {
          currentPage.value = 0;
        }
        pageController.animateToPage(
          currentPage.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, []);

    return SizedBox(
      height: feedHeight,
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        onPageChanged: (value) => currentPage.value = value,
        itemBuilder: (context, index) {
          return Container(
            height: feedHeight,
            margin:
                EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ThemeColor.beige,
            ),
            child: Center(
              child: Text(
                items[index],
                style: const TextStyle(
                  fontSize: 18,
                  color: ThemeColor.highlight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
