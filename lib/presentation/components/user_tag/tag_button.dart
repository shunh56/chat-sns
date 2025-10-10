import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:app/domain/usecases/user_tag_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロフィール画面のタグボタン
class UserTagButton extends HookConsumerWidget {
  const UserTagButton({
    super.key,
    required this.targetUserId,
    this.size = 40,
  });

  final String targetUserId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 認証状態を確認
    UserTagUsecase? usecase;
    try {
      usecase = ref.watch(userTagUsecaseProvider);
    } catch (e) {
      // ログインしていない場合は非表示
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<String>>(
      future: usecase!.getUserTags(targetUserId),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? [];
        final hasAnyTag = tags.isNotEmpty;

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => _showTagSelectionSheet(context, ref, targetUserId),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasAnyTag
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.label_outline,
                size: 20,
                color: hasAnyTag ? Colors.blue[300] : Colors.white,
              ),
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
    final isInitializing = useState(false);

    // 認証状態を確認
    UserTagUsecase? usecase;
    try {
      usecase = ref.watch(userTagUsecaseProvider);
    } catch (e) {
      // ログインしていない場合はエラー表示
      return Container(
        decoration: const BoxDecoration(
          color: ThemeColor.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('ログインが必要です',
                    style: TextStyle(color: ThemeColor.text)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.primary,
                  ),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: ThemeColor.background,
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
                      color: ThemeColor.text,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: ThemeColor.text),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1, color: ThemeColor.textSecondary.withOpacity(0.2)),
            // タグリスト
            Flexible(
              child: StreamBuilder<List<UserTag>>(
                stream: usecase!.watchMyTags(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allTags = snapshot.data!;

                  // 既存ユーザー対応: タグが空の場合は自動初期化
                  if (allTags.isEmpty && !isInitializing.value) {
                    isInitializing.value = true;
                    Future.microtask(() async {
                      try {
                        await usecase!.initializeSystemTags();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('システムタグを初期化しました'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('初期化失敗: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        isInitializing.value = false;
                      }
                    });
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('システムタグを初期化しています...'),
                          ],
                        ),
                      ),
                    );
                  }

                  return FutureBuilder<List<String>>(
                    future: usecase!.getUserTags(targetUserId),
                    builder: (context, selectedSnapshot) {
                      final selectedTags = selectedSnapshot.data ?? [];

                      return ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: allTags.length + 1,
                        separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: ThemeColor.textSecondary.withOpacity(0.1)),
                        itemBuilder: (context, index) {
                          if (index == allTags.length) {
                            // 新規作成ボタン
                            return ListTile(
                              leading: const Icon(Icons.add_circle_outline,
                                  color: ThemeColor.primary),
                              title: const Text(
                                '新しいタグを作成',
                                style: TextStyle(
                                  color: ThemeColor.primary,
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
                                color: ThemeColor.text,
                              ),
                            ),
                            subtitle: tag.isSystemTag
                                ? null
                                : Text('${tag.userCount}人',
                                    style: const TextStyle(
                                        color: ThemeColor.textSecondary)),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: ThemeColor.primary)
                                : Icon(Icons.circle_outlined,
                                    color: ThemeColor.textSecondary
                                        .withOpacity(0.5)),
                            onTap: () async {
                              await usecase!.toggleTag(targetUserId, tag.tagId);
                              // StreamBuilderが自動的に再描画する
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

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF'), radix: 16));
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
    // 認証状態を確認
    UserTagUsecase? usecase;
    try {
      usecase = ref.watch(userTagUsecaseProvider);
    } catch (e) {
      // ログインしていない場合は非表示
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<String>>(
      future: usecase!.getUserTags(targetUserId),
      builder: (context, snapshot) {
        final tagIds = snapshot.data ?? [];
        if (tagIds.isEmpty) return const SizedBox.shrink();

        return StreamBuilder<List<UserTag>>(
          stream: usecase!.watchMyTags(),
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
      return Color(int.parse(colorString.replaceFirst('#', '0xFF'), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
