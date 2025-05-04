import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  const Gap(8),
                  const Icon(
                    Icons.search,
                    color: ThemeColor.white,
                    size: 20,
                  ),
                  const Gap(2),
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.black.withOpacity(0.3),
                      cursorHeight: 16,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: ThemeColor.white,
                        ),
                        hintText: "検索",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          const Icon(
            Icons.leaderboard_outlined,
            color: ThemeColor.icon,
          ),
        ],
      ),
    );
  }
}
