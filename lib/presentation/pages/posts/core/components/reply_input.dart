import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// リプライ入力コンポーネント
///
/// 複数の画面で再利用可能なリプライ入力フォーム
class ReplyInput extends HookConsumerWidget {
  const ReplyInput({
    super.key,
    this.placeholder = 'リプライを入力...',
    this.onSubmit,
  });

  final String placeholder;
  final Function(String)? onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final textController = useTextEditingController();
    final isSubmitting = useState(false);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 24;

    void handleSubmit() async {
      final text = textController.text.trim();
      if (text.isEmpty || isSubmitting.value) return;

      try {
        isSubmitting.value = true;
        await onSubmit?.call(text);
        textController.clear();
      } finally {
        isSubmitting.value = false;
      }
    }

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: ThemeColor.cardColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: placeholder,
                filled: true,
                fillColor: ThemeColor.stroke,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20),
                ),
                hintStyle: textStyle.w400(
                  fontSize: 13,
                  color: ThemeColor.subText,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              onSubmitted: (_) => handleSubmit(),
              enabled: !isSubmitting.value,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isSubmitting.value ? null : handleSubmit,
            icon: isSubmitting.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
