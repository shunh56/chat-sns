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
    final tagColor = _parseColor(tag.color);

    return Scaffold(
      backgroundColor: ThemeColor.background,
      body: CustomScrollView(
        slivers: [
          // タグヘッダー
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: ThemeColor.background,
            iconTheme: const IconThemeData(color: ThemeColor.text),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tagColor.withOpacity(0.2),
                      tagColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: tagColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            tag.icon,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tag.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: tagColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${tag.userCount}人',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: tagColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (!tag.isSystemTag)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'タグを編集',
                  onPressed: () {
                    // TODO: タグ編集画面へ
                  },
                ),
            ],
          ),

          // 設定セクション
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeColor.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeColor.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ThemeColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          size: 18,
                          color: ThemeColor.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'タグ設定',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingToggle(
                    icon: Icons.visibility_outlined,
                    label: 'タイムラインに表示',
                    subtitle: 'このタグのユーザーの投稿をタイムラインで優先表示',
                    value: tag.showInTimeline,
                    color: tagColor,
                    onChanged: (value) async {
                      await usecase.toggleTimelineVisibility(tag.tagId, value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _SettingToggle(
                    icon: Icons.notifications_outlined,
                    label: '新しい投稿を通知',
                    subtitle: 'このタグのユーザーが投稿したときに通知',
                    value: tag.enableNotifications,
                    color: tagColor,
                    onChanged: (value) async {
                      await usecase.toggleNotifications(tag.tagId, value);
                    },
                  ),
                ],
              ),
            ),
          ),

          // タグ付けされたユーザー一覧
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'タグ付けされたユーザー',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.text,
                    ),
                  ),
                ],
              ),
            ),
          ),

          StreamBuilder<List<TaggedUser>>(
            stream: usecase.watchTaggedUsersByTag(tag.tagId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final taggedUsers = snapshot.data!;

              if (taggedUsers.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: tagColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                tag.icon,
                                style: const TextStyle(fontSize: 60),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '「${tag.name}」タグが付いた\nユーザーはまだいません',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeColor.text,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'プロフィール画面からユーザーに\nタグを付けることができます',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeColor.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _TaggedUserTile(
                      taggedUser: taggedUsers[index],
                      tagColor: tagColor,
                      onTap: () => _navigateToUserProfile(
                        context,
                        ref,
                        taggedUsers[index],
                      ),
                    ),
                    childCount: taggedUsers.length,
                  ),
                ),
              );
            },
          ),
        ],
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
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: value ? color.withOpacity(0.08) : ThemeColor.accent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value ? color.withOpacity(0.3) : ThemeColor.stroke,
              width: value ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: value
                      ? color.withOpacity(0.2)
                      : ThemeColor.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: value ? color : ThemeColor.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            value ? ThemeColor.text : ThemeColor.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColor.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? color : ThemeColor.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: value ? color : ThemeColor.stroke,
                    width: 2,
                  ),
                ),
                child: value
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// タグ付けされたユーザータイル
class _TaggedUserTile extends HookConsumerWidget {
  const _TaggedUserTile({
    required this.taggedUser,
    required this.tagColor,
    required this.onTap,
  });

  final TaggedUser taggedUser;
  final Color tagColor;
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

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: ThemeColor.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColor.stroke),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // ユーザーアイコン
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: tagColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: UserIcon(user: user, r: 52),
                    ),
                    const SizedBox(width: 16),
                    // ユーザー情報
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user.username}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ThemeColor.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (taggedUser.memo != null &&
                              taggedUser.memo!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: tagColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: tagColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.note_outlined,
                                    size: 14,
                                    color: tagColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      taggedUser.memo!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: tagColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (taggedUser.tags.length > 1) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              children: [
                                const Icon(
                                  Icons.label,
                                  size: 12,
                                  color: ThemeColor.textSecondary,
                                ),
                                Text(
                                  '他${taggedUser.tags.length - 1}個のタグ',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: ThemeColor.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: ThemeColor.textSecondary.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
