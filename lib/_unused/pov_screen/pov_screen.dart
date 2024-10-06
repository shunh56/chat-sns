/*import 'dart:math';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/phase_01/pov_screen/create_pov_screen.dart';
import 'package:app/presentation/phase_01/pov_screen/grid_screen.dart';
import 'package:app/presentation/phase_01/pov_screen/swipe_feed.dart';
import 'package:app/presentation/providers/provider/pov/friend_povs_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class PovScreen extends ConsumerWidget {
  const PovScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final asyncValue = ref.watch(friendsPovsNotifierProvider);
    final gridIcon = asyncValue.maybeWhen(
      data: (povs) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PovsGridScreen(povs: povs),
              ),
            );
          },
          child: const Icon(
            Icons.dashboard_outlined,
            color: Colors.white,
          ),
        );
      },
      orElse: () => const Icon(
        Icons.dashboard_outlined,
      ),
    );
    final widget = asyncValue.when(
      data: (povs) {
        if (povs.isEmpty) {
          return const Center(
            child: Text(
              "NO POVS",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
        }
        return Stack(
          children: [
            Center(
              child: SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 72),
                      child: Transform.rotate(
                        angle: pi / 24,
                        child: Container(
                          width: 240,
                          height: 300,
                          decoration: BoxDecoration(
                            color: ThemeColor.background,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: ThemeColor.beige,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 72),
                      child: Transform.rotate(
                        angle: -pi / 24,
                        child: Container(
                          width: 240,
                          height: 300,
                          decoration: BoxDecoration(
                            color: ThemeColor.background,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: ThemeColor.beige,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 240,
                      height: 300,
                      decoration: BoxDecoration(
                        color: ThemeColor.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: ThemeColor.beige,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "No More Povs!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SwipePage(
              list: povs,
            ),
          ],
        );
      },
      error: (e, s) => Center(
        child: Text(
          "Error :$e , $s",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      loading: () => const SizedBox(),
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: kToolbarHeight,
              padding: EdgeInsets.only(
                left: themeSize.horizontalPadding,
                right: themeSize.horizontalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "POVs",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(friendsPovsNotifierProvider.notifier)
                              .refresh();
                        },
                        child: const Icon(
                          Icons.sync_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(12),
                      gridIcon,
                      const Gap(12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreatePovScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: widget,
            ),
          ],
        ),
      ),
    );
  }
}
 */