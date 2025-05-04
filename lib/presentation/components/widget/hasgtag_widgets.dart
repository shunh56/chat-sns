import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/data/datasource/local/hashtags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class HashtagChip extends ConsumerWidget {
  const HashtagChip({super.key, required this.tagId});
  final String tagId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final tagName = getTextFromId(tagId)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.accent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagName,
            style: textStyle.w600(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const Gap(4),
        ],
      ),
    );
  }
}
