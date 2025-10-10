import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/tag/tagged_user.dart';
import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/user_tag_usecase.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// タグ一覧編集画面
class TagManagementPage extends HookConsumerWidget {
  const TagManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 認証状態を確認
    UserTagUsecase? usecase;
    try {
      usecase = ref.watch(userTagUsecaseProvider);
    } catch (e) {
      return Scaffold(
        backgroundColor: ThemeColor.background,
        appBar: AppBar(
          title: const Text('タグ管理'),
          backgroundColor: ThemeColor.background,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('ログインが必要です', style: TextStyle(color: ThemeColor.text)),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<UserTag>>(
      stream: usecase!.watchMyTags(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: ThemeColor.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final tags = snapshot.data!;

        if (tags.isEmpty) {
          return Scaffold(
            backgroundColor: ThemeColor.background,
            appBar: AppBar(
              title: const Text('タグ管理'),
              backgroundColor: ThemeColor.background,
              elevation: 0,
            ),
            body: const Center(
              child: Text(
                'タグがありません',
                style: TextStyle(color: ThemeColor.textSecondary),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: tags.length,
          child: Scaffold(
            backgroundColor: ThemeColor.background,
            appBar: AppBar(
              title: const Text('タグ管理'),
              backgroundColor: ThemeColor.background,
              elevation: 0,
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: ThemeColor.primary,
                labelColor: ThemeColor.text,
                unselectedLabelColor: ThemeColor.textSecondary,
                tabs: tags
                    .map((tag) => Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(tag.icon,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(tag.name),
                              const SizedBox(width: 4),
                              Text(
                                '(${tag.userCount})',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            body: TabBarView(
              children: tags
                  .map((tag) => _TagUserListView(
                        tag: tag,
                        usecase: usecase!,
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

/// タグごとのユーザー一覧ビュー
class _TagUserListView extends HookConsumerWidget {
  const _TagUserListView({
    required this.tag,
    required this.usecase,
  });

  final UserTag tag;
  final UserTagUsecase usecase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersNotifier = ref.watch(allUsersNotifierProvider.notifier);

    if (kDebugMode) {
      print('[TagManagement] Building _TagUserListView for tag: ${tag.name}');
    }

    return StreamBuilder<List<TaggedUser>>(
      stream: usecase.watchTaggedUsersByTag(tag.tagId),
      builder: (context, snapshot) {
        if (kDebugMode) {
          print(
              '[TagManagement] StreamBuilder state: hasData=${snapshot.hasData}, hasError=${snapshot.hasError}, connectionState=${snapshot.connectionState}');
        }

        if (snapshot.hasError) {
          if (kDebugMode) {
            print('[TagManagement] StreamBuilder error: ${snapshot.error}');
          }
          return Center(
            child: Text(
              'エラー: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData) {
          if (kDebugMode) {
            print('[TagManagement] Waiting for StreamBuilder data...');
          }
          return const Center(child: CircularProgressIndicator());
        }

        final taggedUsers = snapshot.data!;
        if (kDebugMode) {
          print('[TagManagement] Got ${taggedUsers.length} tagged users');
        }

        if (taggedUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tag.icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  '「${tag.name}」タグが付いたユーザーはいません',
                  style: const TextStyle(
                    color: ThemeColor.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // ユーザーIDリストを一括取得
        final userIds = taggedUsers.map((tu) => tu.targetId).toList();
        if (kDebugMode) {
          print('[TagManagement] Fetching users: $userIds');
        }

        return FutureBuilder<List<UserAccount>>(
          future: allUsersNotifier.getUserAccounts(userIds),
          builder: (context, usersSnapshot) {
            if (kDebugMode) {
              print(
                  '[TagManagement] FutureBuilder state: hasData=${usersSnapshot.hasData}, hasError=${usersSnapshot.hasError}, connectionState=${usersSnapshot.connectionState}');
            }

            if (usersSnapshot.hasError) {
              if (kDebugMode) {
                print(
                    '[TagManagement] FutureBuilder error: ${usersSnapshot.error}');
              }
              return Center(
                child: Text(
                  'ユーザー取得エラー: ${usersSnapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!usersSnapshot.hasData) {
              if (kDebugMode) {
                print('[TagManagement] Waiting for user data...');
              }
              return const Center(child: CircularProgressIndicator());
            }

            final users = usersSnapshot.data!;
            if (kDebugMode) {
              print('[TagManagement] Got ${users.length} users');
            }

            // userIdでマップを作成
            final userMap = {for (var user in users) user.userId: user};

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: taggedUsers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final taggedUser = taggedUsers[index];
                final user = userMap[taggedUser.targetId];

                if (user == null) {
                  return const SizedBox.shrink();
                }

                return _UserTagCard(
                  user: user,
                  taggedUser: taggedUser,
                  usecase: usecase,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// ユーザータグカード
class _UserTagCard extends HookConsumerWidget {
  const _UserTagCard({
    required this.user,
    required this.taggedUser,
    required this.usecase,
  });

  final UserAccount user;
  final TaggedUser taggedUser;
  final UserTagUsecase usecase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(false);

    return Card(
      color: ThemeColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // ユーザー情報ヘッダー
          InkWell(
            onTap: () => isExpanded.value = !isExpanded.value,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // アバター
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: user.imageUrl != null
                        ? NetworkImage(user.imageUrl!)
                        : null,
                    backgroundColor: ThemeColor.accent,
                    child: user.imageUrl == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0] : '?',
                            style: const TextStyle(
                              color: ThemeColor.text,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // ユーザー情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: ThemeColor.text,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(
                            color: ThemeColor.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // タグ数
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeColor.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${taggedUser.tags.length}個のタグ',
                      style: const TextStyle(
                        color: ThemeColor.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded.value ? Icons.expand_less : Icons.expand_more,
                    color: ThemeColor.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // 展開部分: タグ編集
          if (isExpanded.value)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: ThemeColor.stroke),
                  const SizedBox(height: 12),
                  const Text(
                    'タグ',
                    style: TextStyle(
                      color: ThemeColor.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TagChipList(
                    targetUserId: user.userId,
                    usecase: usecase,
                  ),
                  if (taggedUser.memo != null &&
                      taggedUser.memo!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'メモ',
                      style: TextStyle(
                        color: ThemeColor.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeColor.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        taggedUser.memo!,
                        style: const TextStyle(
                          color: ThemeColor.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// タグチップリスト
class _TagChipList extends HookConsumerWidget {
  const _TagChipList({
    required this.targetUserId,
    required this.usecase,
  });

  final String targetUserId;
  final UserTagUsecase usecase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<UserTag>>(
      stream: usecase.watchMyTags(),
      builder: (context, tagsSnapshot) {
        if (!tagsSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final allTags = tagsSnapshot.data!;

        return FutureBuilder<List<String>>(
          future: usecase.getUserTags(targetUserId),
          builder: (context, selectedSnapshot) {
            if (!selectedSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final selectedTags = selectedSnapshot.data!;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTags.map((tag) {
                final isSelected = selectedTags.contains(tag.tagId);

                return InkWell(
                  onTap: () async {
                    await usecase.toggleTag(targetUserId, tag.tagId);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _parseColor(tag.color).withOpacity(0.2)
                          : ThemeColor.accent,
                      border: Border.all(
                        color: isSelected
                            ? _parseColor(tag.color)
                            : ThemeColor.stroke,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag.icon,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tag.name,
                          style: TextStyle(
                            color: isSelected
                                ? ThemeColor.text
                                : ThemeColor.textSecondary,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: _parseColor(tag.color),
                          ),
                        ],
                      ],
                    ),
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
