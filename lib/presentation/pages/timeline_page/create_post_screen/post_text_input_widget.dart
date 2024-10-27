// Flutter imports:
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:

class PostTextInputWidget extends ConsumerWidget {
  const PostTextInputWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return TextField(
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: null,
      maxLength: 120,
      autofocus: true,
      cursorColor: ThemeColor.highlight,
      style: textStyle.w400(
        fontSize: 16,
      ),
      onChanged: (text) {
        ref.watch(inputTextProvider.notifier).state = text;
      },
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'^\n|\n{3,}'))
      ],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        hintText: "メッセージを入力...",
        hintStyle: textStyle.w400(
          fontSize: 14,
          color: ThemeColor.subText,
        ),
        counterStyle: textStyle.numText(
          color: ThemeColor.subText,
        ),
        border: InputBorder.none,
      ),
    );
  }
}
