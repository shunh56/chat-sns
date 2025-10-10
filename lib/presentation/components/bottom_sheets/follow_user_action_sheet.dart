import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/user_tag_usecase.dart';
import 'package:app/presentation/pages/chat_request/send_chat_request_helper.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/follow/followers_list_notifier.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// フォロー/フォロワー画面のユーザーアクションボトムシート
class FollowUserActionSheet {
  static void show(
    BuildContext context,
    WidgetRef ref,
    UserAccount user,
  ) {
    final isFollowing = ref.read(isFollowingProvider(user.userId));
    final isFollower = ref.read(isFollowerProvider(user.userId));

    showModalBottomSheet(
      backgroundColor: ThemeColor.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // iOS風のハンドル
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: ThemeColor.stroke,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(24),

                  // ユーザー情報ヘッダー
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: (user.imageUrl?.isNotEmpty ?? false)
                            ? NetworkImage(user.imageUrl!)
                            : null,
                        backgroundColor: ThemeColor.accent,
                        child: (user.imageUrl?.isEmpty ?? true)
                            ? const Icon(Icons.person, color: ThemeColor.text)
                            : null,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ThemeColor.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "@${user.username}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: ThemeColor.subText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),

                  // アクション一覧（常に4つ表示）
                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColor.accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildActionList(
                        context, ref, user, isFollowing, isFollower),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// アクション一覧を構築（常に4つのアクションを表示）
  static Widget _buildActionList(
    BuildContext context,
    WidgetRef ref,
    UserAccount user,
    bool isFollowing,
    bool isFollower,
  ) {
    return Column(
      children: [
        // 1. リレーション関連のアクション（条件によって変化）
        if (isFollowing)
          // フォロー中の場合: フォロー解除
          _ActionButton(
            icon: Icons.person_remove_outlined,
            label: 'フォローを解除する',
            color: Colors.red,
            onTap: () async {
              // ボトムシートを閉じる
              Navigator.of(context).pop();

              // アニメーション完了を待つ
              await Future.delayed(const Duration(milliseconds: 300));

              // contextが有効か確認してから確認ダイアログを表示
              if (context.mounted) {
                _showUnfollowConfirmDialog(context, ref, user);
              }
            },
          )
        else
          // 未フォローの場合: フォロー/フォローバック
          _ActionButton(
            icon: isFollower ? Icons.people : Icons.person_add,
            label: isFollower ? 'フォローバック' : 'フォロー',
            color: isFollower ? Colors.green : ThemeColor.primary,
            onTap: () {
              // フォロー処理は即座に実行できるのでそのまま
              Navigator.of(context).pop();
              ref.read(followingListNotifierProvider.notifier).followUser(user);
            },
          ),
        const Divider(height: 1, color: ThemeColor.stroke),

        // 2. チャットへ（コミュニケーション）
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: 'チャットへ',
          onTap: () async {
            // ボトムシートを閉じる
            Navigator.of(context).pop();

            // ボトムシートが完全に閉じるまで待つ
            await Future.delayed(const Duration(milliseconds: 300));

            // contextが有効か確認してからチャットリクエストヘルパーを呼ぶ
            if (context.mounted) {
              await SendChatRequestHelper.startChatOrRequest(
                context: context,
                ref: ref,
                targetUserId: user.userId,
              );
            }
          },
        ),
        const Divider(height: 1, color: ThemeColor.stroke),

        // 3. プロフィールへ（詳細情報）
        _ActionButton(
          icon: Icons.person_outline,
          label: 'プロフィールへ',
          onTap: () async {
            // ボトムシートを閉じる
            Navigator.of(context).pop();

            // アニメーション完了を待つ
            await Future.delayed(const Duration(milliseconds: 300));

            // contextが有効か確認してからナビゲート
            if (context.mounted) {
              ref.read(navigationRouterProvider(context)).goToProfile(user);
            }
          },
        ),
        const Divider(height: 1, color: ThemeColor.stroke),

        // 4. タグをつける（整理）
        _ActionButton(
          icon: Icons.label_outline,
          label: 'タグをつける',
          onTap: () async {
            // ボトムシートを閉じる
            Navigator.of(context).pop();

            // アニメーション完了を待つ
            await Future.delayed(const Duration(milliseconds: 300));

            // contextが有効か確認してからタグ選択シートを表示
            if (context.mounted) {
              _showTagSelectionSheet(context, ref, user.userId);
            }
          },
        ),
      ],
    );
  }

  /// フォロー解除確認ダイアログ
  static void _showUnfollowConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    UserAccount user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'フォローを解除',
          style: TextStyle(
            color: ThemeColor.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${user.name}さんのフォローを解除しますか？',
          style: const TextStyle(color: ThemeColor.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: ThemeColor.subText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(followingListNotifierProvider.notifier)
                  .unfollowUser(user);
            },
            child: const Text(
              '解除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// タグ選択シートを表示
  static void _showTagSelectionSheet(
    BuildContext context,
    WidgetRef ref,
    String targetUserId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TagSelectionSheet(targetUserId: targetUserId),
    );
  }
}

/// タグ選択シート (tag_button.dartから移植)
class _TagSelectionSheet extends ConsumerWidget {
  const _TagSelectionSheet({required this.targetUserId});

  final String targetUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const Gap(16),
                const Text('ログインが必要です',
                    style: TextStyle(color: ThemeColor.text)),
                const Gap(16),
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

                  return FutureBuilder<List<String>>(
                    future: usecase!.getUserTags(targetUserId),
                    builder: (context, selectedSnapshot) {
                      final selectedTags = selectedSnapshot.data ?? [];

                      return ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: allTags.length,
                        separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: ThemeColor.textSecondary.withOpacity(0.1)),
                        itemBuilder: (context, index) {
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

/// アクションボタンウィジェット
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? ThemeColor.text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: buttonColor,
                size: 24,
              ),
              const Gap(16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: buttonColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ThemeColor.stroke,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
