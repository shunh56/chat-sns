import 'dart:async';

import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

Widget iosBottomSheet(Widget child) {
  return Container(
    padding: const EdgeInsets.only(
      top: 12,
      bottom: 72,
      left: 12,
      right: 12,
    ),
    width: double.infinity,
    child: Column(
      children: [
        Container(
          height: 4,
          width: 36,
          padding: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child,
      ],
    ),
  );
}

final pageControllerProvider =
    Provider.autoDispose((ref) => PageController(initialPage: 0));
final pageIndexProvider = StateProvider.autoDispose((ref) => 0);

class SubsctiptionBottomSheet {
  final BuildContext context;
  SubsctiptionBottomSheet(this.context);
  Timer? timer;

  openBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            // final themeSize = ref.watch(themeSizeProvider(context));
            final pageController = ref.watch(pageControllerProvider);
            final pageIndex = ref.watch(pageIndexProvider);
            final pageIndexNotifier = ref.watch(pageIndexProvider.notifier);

            change() async {
              timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
                if (context.mounted) {
                  final index = (pageIndex + 1 < 4) ? (pageIndex + 1) : 0;

                  pageIndexNotifier.state = index;

                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeIn,
                  );
                } else {
                  return;
                }
              });
            }

            change();
            return DefaultTabController(
              length: 2,
              child: Container(
                padding: EdgeInsets.only(
                  top: 12,
                  bottom: MediaQuery.of(context).viewPadding.bottom,
                  left: 12,
                  right: 12,
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: ThemeColor.accent,
                          ),
                          height: 36,
                          width: 72,
                          child: TabBar(
                            isScrollable: true,
                            onTap: (val) {
                              HapticFeedback.lightImpact();
                            },
                            indicator: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ThemeColor.button,
                            ),
                            tabAlignment: TabAlignment.start,
                            indicatorPadding: const EdgeInsets.all(4),
                            labelPadding: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: ThemeColor.background,
                            unselectedLabelColor: Colors.white.withOpacity(0.3),
                            dividerColor: ThemeColor.background,
                            splashFactory: NoSplash.splashFactory,
                            dividerHeight: 0,
                            tabs: const [
                              SizedBox(
                                width: 36,
                                child: Tab(
                                  child: Icon(
                                    Icons.star,
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 36,
                                child: Tab(
                                  child: Icon(
                                    Icons.card_giftcard_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                        const Text(
                          "サブスクリプション",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close,
                              color: ThemeColor.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.cyan,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: PageView(
                                      controller:
                                          ref.watch(pageControllerProvider),
                                      children: const [
                                        Center(
                                          child: Text(
                                            "1",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            "2",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            "3",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            "4",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 8,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List<Widget>.generate(4,
                                            (int index) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: (index == pageIndex)
                                                ? const CircleAvatar(
                                                    radius: 4,
                                                    backgroundColor:
                                                        Colors.white,
                                                  )
                                                : CircleAvatar(
                                                    radius: 4,
                                                    backgroundColor: Colors
                                                        .black
                                                        .withOpacity(0.2),
                                                  ),
                                          );
                                        }).toList(),
                                      ))
                                ],
                              ),
                              const Gap(8),
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: ThemeColor.accent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "1ヶ月",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "¥980/月",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: ThemeColor.accent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "3ヶ月",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "¥880/月",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: ThemeColor.accent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "6ヶ月",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "¥600/月",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Text(
                                "サブスクライブすると、AppNameの売買規約に同意したとみなされます。",
                                style: TextStyle(
                                  color: ThemeColor.beige,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const Center(
                            child: Text("2"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
