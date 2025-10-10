import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';

/// ハッシュタグ表示・管理コンポーネント
///
/// 機能:
/// - 選択されたハッシュタグの表示
/// - ハッシュタグの削除
/// - レスポンシブなチップレイアウト
class HashtagDisplay extends ConsumerWidget {
  const HashtagDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hashtags = ref.watch(hashtagsProvider);

    if (hashtags.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                hashtags.map((tag) => _buildHashtagChip(ref, tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHashtagChip(WidgetRef ref, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ThemeColor.highlight.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$tag',
            style: const TextStyle(
              color: ThemeColor.highlight,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
          const Gap(4),
          GestureDetector(
            onTap: () => _removeHashtag(ref, tag),
            child: const Icon(
              Icons.close,
              size: 14,
              color: ThemeColor.highlight,
            ),
          ),
        ],
      ),
    );
  }

  void _removeHashtag(WidgetRef ref, String tag) {
    final currentTags = ref.read(hashtagsProvider);
    final updatedTags = List<String>.from(currentTags);
    updatedTags.remove(tag);
    ref.read(hashtagsProvider.notifier).state = updatedTags;
  }
}
