import 'package:flutter/material.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../popup_content.dart';

class HashtagPopup extends PopupContent {
  final String imageUrl;
  final String buttonText;
  final Future<void> Function(BuildContext context) onPressed;

  const HashtagPopup({
    super.key,
    required super.id,
    required this.imageUrl,
    required this.buttonText,
    required this.onPressed,
    super.dismissible,
    super.displayDuration = const Duration(days: 7),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final w = MediaQuery.of(context).size.width * 0.8;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            width: w,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: w,
                  height: w,
                  //constraints: const BoxConstraints(maxHeight: 400),
                  child: SvgPicture.asset(
                    imageUrl,
                    fit: BoxFit.contain,
                    width: w,
                    // SVGのビューポートに合わせるため
                    allowDrawingOutsideViewBox: false,
                    // SVGのアスペクト比を維持
                    alignment: Alignment.center,
                  ),
                ),
                // ボタン
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onPressed(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: textStyle.w600(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: const BorderSide(
              color: ThemeColor.text,
              width: 0.8,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '閉じる',
            style: textStyle.w600(),
          ),
        ),
      ],
    );
  }

  @override
  Future<bool> shouldDisplay() async {
    // ここでFirestoreなどを使って表示条件をチェックできます
    // 例: このキャンペーンを既に見たことがあるかなど
    return true;
  }
}
