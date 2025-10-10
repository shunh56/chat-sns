import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';

/// ハッシュタグ追加ダイアログ
///
/// 機能:
/// - ハッシュタグの入力と追加
/// - 重複チェック
/// - 入力検証とフォーマット
class HashtagDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.tag, color: ThemeColor.highlight, size: 20),
            Gap(8),
            Text('ハッシュタグを追加', style: TextStyle(color: ThemeColor.text)),
          ],
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: ThemeColor.text),
          decoration: InputDecoration(
            prefixText: '#',
            prefixStyle: const TextStyle(
              color: ThemeColor.highlight,
              fontWeight: FontWeight.bold,
            ),
            hintText: 'タグを入力（スペースなし）',
            hintStyle: const TextStyle(color: ThemeColor.subText),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ThemeColor.divider.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ThemeColor.highlight),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: ThemeColor.subText),
            ),
          ),
          ElevatedButton(
            onPressed: () => _addHashtag(context, ref, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.highlight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '追加',
              style: TextStyle(color: ThemeColor.white),
            ),
          ),
        ],
      ),
    );
  }

  static void _addHashtag(
    BuildContext context,
    WidgetRef ref,
    String inputText,
  ) {
    final tag = inputText.trim().replaceAll(' ', '');
    if (tag.isNotEmpty) {
      final currentTags = ref.read(hashtagsProvider);
      if (!currentTags.contains(tag)) {
        ref.read(hashtagsProvider.notifier).state = [...currentTags, tag];
      }
    }
    Navigator.pop(context);
  }
}
