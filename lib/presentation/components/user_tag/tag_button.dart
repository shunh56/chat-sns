import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:app/domain/usecases/user_tag_usecase.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロフィール画面のタグボタン
class UserTagButton extends HookConsumerWidget {
  const UserTagButton({
    super.key,
    required this.targetUserId,
    this.size = 32,
  });

  final String targetUserId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.watch(userTagUsecaseProvider);

    return FutureBuilder<List<String>>(
      future: usecase.getUserTags(targetUserId),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? [];
        final hasAnyTag = tags.isNotEmpty;

        return GestureDetector(
          onTap: () => _showTagSelectionSheet(context, ref, targetUserId),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: hasAnyTag
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.label_outline,
              size: size * 0.6,
              color: hasAnyTag ? Colors.blue : Colors.grey,
            ),
          ),
        );
      },
    );
  }

  void _showTagSelectionSheet(
      BuildContext context, WidgetRef ref, String targetUserId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TagSelectionSheet(targetUserId: targetUserId),
    );
  }
}

/// タグ選択シート
class _TagSelectionSheet extends HookConsumerWidget {
  const _TagSelectionSheet({required this.targetUserId});

  final String targetUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.watch(userTagUsecaseProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドル
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'タグを選択',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // タグリスト
            Flexible(
              child: StreamBuilder<List<UserTag>>(
                stream: usecase.watchMyTags(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allTags = snapshot.data!;

                  return FutureBuilder<List<String>>(
                    future: usecase.getUserTags(targetUserId),
                    builder: (context, selectedSnapshot) {
                      final selectedTags = selectedSnapshot.data ?? [];

                      return ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: allTags.length + 1,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (index == allTags.length) {
                            // 新規作成ボタン
                            return ListTile(
                              leading: const Icon(Icons.add_circle_outline,
                                  color: Colors.blue),
                              title: const Text(
                                '新しいタグを作成',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                // TODO: タグ作成画面へ
                                Navigator.pop(context);
                              },
                            );
                          }

                          final tag = allTags[index];
                          final isSelected = selectedTags.contains(tag.tagId);

                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _parseColor(tag.color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  tag.icon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            title: Text(
                              tag.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: tag.isSystemTag
                                ? null
                                : Text('${tag.userCount}人'),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.blue)
                                : const Icon(Icons.circle_outlined,
                                    color: Colors.grey),
                            onTap: () async {
                              await usecase.toggleTag(targetUserId, tag.tagId);
                              // 再描画のため一度閉じて開き直す
                              if (context.mounted) {
                                Navigator.pop(context);
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                if (context.mounted) {
                                  _showTagSelectionSheet(
                                      context, ref, targetUserId);
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagSelectionSheet(
      BuildContext context, WidgetRef ref, String targetUserId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TagSelectionSheet(targetUserId: targetUserId),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(
          int.parse(colorString.replaceFirst('#', '0xFF'), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}

/// タグアイコン表示 (プロフィール画面で使用)
class UserTagIcons extends HookConsumerWidget {
  const UserTagIcons({
    super.key,
    required this.targetUserId,
  });

  final String targetUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.watch(userTagUsecaseProvider);

    return FutureBuilder<List<String>>(
      future: usecase.getUserTags(targetUserId),
      builder: (context, snapshot) {
        final tagIds = snapshot.data ?? [];
        if (tagIds.isEmpty) return const SizedBox.shrink();

        return StreamBuilder<List<UserTag>>(
          stream: usecase.watchMyTags(),
          builder: (context, tagSnapshot) {
            if (!tagSnapshot.hasData) return const SizedBox.shrink();

            final allTags = tagSnapshot.data!;
            final userTags = allTags
                .where((tag) => tagIds.contains(tag.tagId))
                .toList()
              ..sort((a, b) => b.priority.compareTo(a.priority));

            return Wrap(
              spacing: 4,
              children: userTags.take(3).map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _parseColor(tag.color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(
          int.parse(colorString.replaceFirst('#', '0xFF'), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
