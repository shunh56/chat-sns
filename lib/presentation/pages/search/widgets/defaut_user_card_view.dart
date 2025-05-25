import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/search/sub_pages/user_card_stack_screen.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/providers/users/online_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class DefaultUserCardView extends ConsumerWidget {
  const DefaultUserCardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ヘッダー部分
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "気になる友達を見つけよう",
                style: textStyle.w700(
                  fontSize: 20,
                  color: ThemeColor.white,
                ),
              ),
              const Gap(4),
              Text(
                "新しく始めた人やアクティブなユーザーと\n趣味や興味を共有して仲良くなろう",
                style: textStyle.w400(
                  fontSize: 14,
                  color: const Color(0xFFB0B0B0),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const Gap(16),

        // 新規ユーザーセクション
        _buildUserSection(
          context,
          ref,
          "最近始めたユーザー",
          ref.watch(newUsersNotifierProvider),
          "new_users",
          textStyle,
        ),

        const Gap(24),

        // アクティブユーザーセクション
        _buildUserSection(
          context,
          ref,
          "アクティブな友達",
          ref.watch(recentUsersNotifierProvider),
          "online_users",
          textStyle,
        ),
      ],
    );
  }

  Widget _buildUserSection(
      BuildContext context,
      WidgetRef ref,
      String title,
      AsyncValue<List<UserAccount>> asyncUsers,
      String userGroupId,
      ThemeTextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションヘッダー
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textStyle.w600(
                  fontSize: 16,
                  color: ThemeColor.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // すべて見るを押した時のカードスタック画面への遷移
                  asyncUsers.whenData((users) {
                    if (users.isNotEmpty) {
                      List<UserAccount> filteredUsers = List.from(users);
                      filteredUsers.removeWhere((user) => user.isMe);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserCardStackScreen(
                            users: filteredUsers,
                            userGroupId: userGroupId,
                            userGroupTitle: title,
                          ),
                        ),
                      );
                    }
                  });
                },
                child: Text(
                  "すべて見る",
                  style: textStyle.w600(
                    fontSize: 14,
                    color: ThemeColor.subText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),

        // ユーザーリスト
        SizedBox(
          height: 232, // ユーザー表示部分の高さ
          child: asyncUsers.when(
            data: (users) {
              // 自分を除外
              List<UserAccount> filteredUsers = List.from(users);
              filteredUsers.removeWhere((user) => user.isMe);

              // 最大10人まで表示
              final displayUsers = filteredUsers.take(10).toList();

              if (displayUsers.isEmpty) {
                return Center(
                  child: Text(
                    'ユーザーが見つかりませんでした',
                    style: textStyle.w400(
                      fontSize: 14,
                      color: ThemeColor.subText,
                    ),
                  ),
                );
              }

              return ListView.builder(
                addAutomaticKeepAlives: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: displayUsers.length,
                itemBuilder: (context, index) {
                  final user = displayUsers[index];
                  return _buildUserItem(context, ref, user, textStyle);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text(
                'エラーが発生しました',
                style: textStyle.w400(
                  fontSize: 14,
                  color: ThemeColor.error,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserItem(BuildContext context, WidgetRef ref, UserAccount user,
      ThemeTextStyle textStyle) {
    // ユーザーがフォロー済みかどうかを確認

    return GestureDetector(
      onTap: () {
        // ユーザープロフィール画面への遷移
        ref.read(navigationRouterProvider(context)).goToProfile(user);
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
        decoration: BoxDecoration(
          color: ThemeColor.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // プロフィール画像
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeColor.stroke,
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: user.imageUrl != null
                    ? CachedImage.userIcon(user.imageUrl, user.name, 0)
                    : Container(
                        color: ThemeColor.surface,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: ThemeColor.icon.withOpacity(0.6),
                          ),
                        ),
                      ),
              ),
            ),
            const Gap(8),

            // ユーザー名
            Text(
              user.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle.w600(
                fontSize: 14,
                color: ThemeColor.white,
              ),
            ),
            const Gap(2),

            // ユーザーネーム
            Text(
              '@${user.username}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle.w400(
                fontSize: 12,
                color: ThemeColor.subText,
              ),
            ),
            const Spacer(),
            // フォローボタン

            _buildFollowButton(user),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(UserAccount user) {
    if (user.isMe) return const SizedBox();
    return Consumer(
      builder: (context, ref, child) {
        final themeSize = ref.watch(themeSizeProvider(context));
        final textStyle = ThemeTextStyle(themeSize: themeSize);

        final notifier = ref.read(followingListNotifierProvider.notifier);
        final isFollowing = ref.watch(isFollowingProvider(user.userId));

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (!isFollowing) {
                notifier.followUser(user);
              } else {
                notifier.unfollowUser(user);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? Colors.transparent : Colors.blue,
              foregroundColor: isFollowing ? ThemeColor.white : Colors.white,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isFollowing
                      ? ThemeColor.white.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              minimumSize: const Size(0, 32),
            ),
            child: Text(
              isFollowing ? 'フォロー中' : 'フォロー',
              style: textStyle.w600(
                fontSize: 12,
                color: isFollowing ? ThemeColor.white : Colors.white,
              ),
            ),
          ),
        );
        return Material(
          color: isFollowing ? Colors.blue : ThemeColor.white,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 36,
              width: 96,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  !isFollowing ? 'フォロー' : 'フォロー中',
                  style: textStyle.w600(
                    fontSize: 12,
                    color:
                        isFollowing ? ThemeColor.white : ThemeColor.background,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
