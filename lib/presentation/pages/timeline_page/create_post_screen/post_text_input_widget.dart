// Flutter imports:
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
    return TextField(
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 20,
      maxLength: 400,
      autofocus: true,
      cursorColor: ThemeColor.highlight,
      style: const TextStyle(
        fontSize: 14,
        color: ThemeColor.text,
        fontWeight: FontWeight.w600,
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
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.3),
          fontWeight: FontWeight.w600,
        ),
        
        counterText: '',
        border: InputBorder.none,
      ),
    );
  }
}
