import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';

/// 投稿テキスト入力コンポーネント
///
/// 機能:
/// - マルチライン対応のテキスト入力
/// - 文字数制限とフォーマット制御
/// - リアルタイム状態更新
class PostTextInput extends ConsumerWidget {
  const PostTextInput({
    super.key,
    this.controller,
    this.onChanged,
    this.maxLines,
    this.hintText = '今どんな気分？',
    this.maxLength = 400,
  });

  final TextEditingController? controller;
  final Function(String)? onChanged;
  final int? maxLines;
  final String hintText;
  final int maxLength;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: false,
      cursorColor: ThemeColor.highlight,
      style: textStyle.w500(fontSize: 14),
      onChanged: onChanged ??
          (text) {
            ref.read(inputTextProvider.notifier).state = text;
          },
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'^\n|\n{3,}'))
      ],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        hintText: hintText,
        hintStyle: textStyle.w500(
          fontSize: 14,
          color: ThemeColor.subText,
        ),
        counterText: "",
        border: InputBorder.none,
      ),
    );
  }
}
