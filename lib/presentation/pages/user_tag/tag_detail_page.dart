import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/tag/tagged_user.dart';
import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/user_tag_usecase.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/pages/user/user_profile_page/user_profile_page.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// タグ詳細画面 (タグ付けされたユーザー一覧)
class TagDetailPage extends HookConsumerWidget {
  const TagDetailPage({super.key, required this.tag});

  final UserTag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.watch(userTagUsecaseProvider);

    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tag.icon),
            const SizedBox(width: 8),
            Text(tag.name),
          ],
        ),
        backgroundColor: ThemeColor.background,
        elevation: 0,
        actions: [
          if (!tag.isSystemTag)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: タグ編集画面へ
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 設定セクション
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '設定',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.subText,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SettingToggle(
                        label: 'タイムラインに表示',
                        value: tag.showInTimeline,
                        onChanged: (value) async {
                          await usecase.toggleTimelineVisibility(
                              tag.tagId, value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SettingToggle(
                        label: '新しい投稿を通知',
                        value: tag.enableNotifications,
                        onChanged: (value) async {
                          await usecase.toggleNotifications(tag.tagId, value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // タグ付けされたユーザー一覧
          Expanded(
            child: Container(
              color: Colors.white,
              child: StreamBuilder<List<TaggedUser>>(
                stream: usecase.watchTaggedUsersByTag(tag.tagId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final taggedUsers = snapshot.data!;

                  if (taggedUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tag.icon,
                            style: const TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '「${tag.name}」タグがついた\nユーザーはまだいません',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ThemeColor.subText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'タグ付けされたユーザー (${taggedUsers.length}人)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ThemeColor.subText,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: taggedUsers.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final taggedUser = taggedUsers[index];
                            return _TaggedUserTile(
                              taggedUser: taggedUser,
                              onTap: () =>
                                  _navigateToUserProfile(context, ref, taggedUser),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUserProfile(
      BuildContext context, WidgetRef ref, TaggedUser taggedUser) async {
    // ユーザー情報を取得
    final user = await ref
        .read(allUsersNotifierProvider.notifier)
        .getUserByUserId(taggedUser.targetId);

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(user: user),
        ),
      );
    }
  }
}

/// 設定トグル
class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? Colors.blue : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: value ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: value ? Colors.blue : ThemeColor.subText,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// タグ付けされたユーザータイル
class _TaggedUserTile extends HookConsumerWidget {
  const _TaggedUserTile({
    required this.taggedUser,
    required this.onTap,
  });

  final TaggedUser taggedUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<UserAccount>(
      future: ref
          .read(allUsersNotifierProvider.notifier)
          .getUserByUserId(taggedUser.targetId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return ListTile(
          onTap: onTap,
          leading: UserIcon(user: user),
          title: Text(
            user.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('@${user.username}'),
              if (taggedUser.memo != null && taggedUser.memo!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.note, size: 14, color: ThemeColor.subText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          taggedUser.memo!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeColor.subText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
