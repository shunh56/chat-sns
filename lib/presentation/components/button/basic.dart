import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasicButton extends ConsumerWidget {
  const BasicButton(
      {super.key,
      required this.text,
      required this.ontap,
      this.borderRadius = 12.0});
  final String text;
  final VoidCallback? ontap;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Material(
      color: ontap == null ? ThemeColor.stroke : Colors.blue,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: textStyle.w600(
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
