import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/message_overview.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/providers/chats/dm_flag_provider.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/pages/chat/sub_pages/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/pages/user/user_profile_page/user_ff_screen.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/chats/dm_overview_list.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/presentation/providers/users/blocks_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final tabWidth = themeSize.screenWidth / 4;
    // final dms = ref.watch(dmOverviewListNotifierProvider).asData?.value ?? [];
    //bool flag = false;
    /*for (var dm in dms) {
      final q = dm.userInfoList.where(
          (item) => item.userId == ref.read(authProvider).currentUser!.uid);
      if (q.isNotEmpty) {
        final myInfo = q.first;
        if (myInfo.lastOpenedAt.compareTo(dm.updatedAt) < 0) {
          flag = true;
        }
      } else {
        flag = true;
      }
    } */
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: themeSize.appbarHeight,
          centerTitle: false,
          title: Text(
            "ソーシャル",
            style: textStyle.appbarText(japanese: true),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: ThemeColor.background,
              child: TabBar(
                isScrollable: true,
                labelColor: ThemeColor.text,
                tabAlignment: TabAlignment.start,
                unselectedLabelColor: ThemeColor.subText,
                indicatorColor: ThemeColor.highlight,
                dividerColor: Colors.transparent,
                indicatorWeight: 0,
                indicator: GradientTabIndicator(
                  colors: const [
                    ThemeColor.highlight,
                    Colors.cyan,
                  ],
                  weight: 2,
                  width: tabWidth,
                  radius: 8,
                ),
                tabs: [
                  Tab(
                    child: SizedBox(
                      width: tabWidth,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "メッセージ",
                              style: textStyle.w600(fontSize: 14),
                            ),
                            if (ref.watch(dmFlagProvider))
                              const Padding(
                                padding: EdgeInsets.only(
                                  top: 2,
                                  left: 8,
                                ),
                                child: CircleAvatar(
                                  radius: 4, // サイズを小さくする
                                  backgroundColor: Colors.red,
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: SizedBox(
                      width: tabWidth,
                      child: Center(
                        child: Text(
                          "フォロー中",
                          style: textStyle.w600(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  ChatList(),
                  FollowingList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FollowingList extends ConsumerWidget {
  const FollowingList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    //TODO フォロー中のユーザーの並び順を変える
    final List<String> followingIds =
        ref.watch(followingListNotifierProvider).asData?.value ?? [];

    return followingIds.isEmpty
        ? _buildEmptyState(textStyle)
        : ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              top: themeSize.verticalPaddingSmall,
              bottom: 120,
            ),
            itemCount: followingIds.length,
            itemBuilder: (context, index) => UserWidget(
              userId: followingIds[index],
              builder: (user) {
                return UserTile(user: user);
              },
            ),
          );
  }

  Widget _buildEmptyState(ThemeTextStyle textStyle) {
    const message = 'フォローしているユーザーはいません';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 48,
            color: ThemeColor.text.withOpacity(0.5),
          ),
          const Gap(16),
          Text(
            message,
            style: textStyle.w400(
              fontSize: 14,
              color: ThemeColor.text.withOpacity(0.7),
            ),
          ),
          const Gap(120),
        ],
      ),
    );
  }
}

class UserTile extends ConsumerWidget {
  const UserTile({
    super.key,
    required this.user,
  });

  final UserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: ThemeColor.accent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ref.read(navigationRouterProvider(context)).goToProfile(user);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserIcon(
                  user: user,
                  r: 30,
                  enableDecoration: false,
                ),
                const Gap(18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ThemeColor.text,
                              height: 1,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            user.badgeStatus,
                            style: textStyle.w600(
                              color: user.greenBadge
                                  ? Colors.green
                                  : ThemeColor.subText,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatList extends ConsumerWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(dmOverviewListNotifierProvider);

    return asyncValue.when(
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 72),
            child: Center(
              child: Text(
                "トークがありません",
                style: textStyle.w400(
                  fontSize: 14,
                  color: ThemeColor.subText,
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return ChatTile(overview: list[index]);
          },
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }
}

class ChatTile extends ConsumerWidget {
  const ChatTile({super.key, required this.overview});
  final DMOverview overview;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final flag = ref.read(dmFlagHelperProvider).checkFlag(overview);

    return UserWidget(
        userId: overview.userId,
        builder: (user) {
          return InkWell(
            onLongPress: () async {
              final closed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: Row(
                    children: [
                      UserIcon(
                        user: user,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.name,
                              style: textStyle.w600(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'このチャットを閉じますか？',
                        style: textStyle.w600(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  size: 16,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '注意事項',
                                  style: textStyle.w600(
                                    fontSize: 14,
                                    //  color: Colors.red[400],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• チャットを閉じても履歴は消えません\n'
                              '• 再度チャットを開始するには新しく始める必要があります',
                              style: textStyle.w400(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'キャンセル',
                        style: textStyle.w600(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: Text(
                        'チャットを閉じる',
                        style:
                            textStyle.w600(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                  actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                ),
              );
              if (closed == true) {
                ref
                    .read(dmOverviewListNotifierProvider.notifier)
                    .leaveChat(user);
              }
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChattingScreen(userId: user.userId),
                ),
              );
            },
            splashColor: ThemeColor.accent,
            highlightColor: ThemeColor.stroke,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  UserIcon(
                    user: user,
                    r: 30,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle.w600(
                            fontSize: 17,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          overview.lastMessage.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle.w400(
                            fontSize: 15,
                            color: ThemeColor.subText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        overview.lastMessage.createdAt.xxAgo,
                        style: textStyle.w400(
                          fontSize: 11,
                          color: ThemeColor.subText,
                        ),
                      ),
                      const Gap(12),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor:
                              flag ? Colors.red : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}

/*class FollowingUsers extends ConsumerWidget {
  const FollowingUsers({
    super.key,
    required this.builder,
  });

  // UIを構築するためのコールバック関数
  final Widget Function(List<UserAccount> users) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockes = ref.watch(blocksListNotifierProvider).asData?.value ?? [];
    final blockeds =
        ref.watch(blockedsListNotifierProvider).asData?.value ?? [];
    final filters =
        blockes + blockeds + [ref.read(authProvider).currentUser!.uid];
    return ref.watch(followingListNotifierProvider).when(
          data: (users) {
            users.removeWhere((user) => filters.contains(user.userId));
            return builder(users);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text('エラーが発生しました: $error'),
          ),
        );
  }
}

class FollowingOnlineListView extends ConsumerWidget {
  const FollowingOnlineListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return FollowingUsers(
      builder: (users) {
        if (users.isEmpty) {
          return const SizedBox();
        }
        //4時間以内のユーザーのみ表示
        users.removeWhere((user) =>
            DateTime.now().difference(user.lastOpenedAt.toDate()).inHours > 4);
        // status => online => lastOpenedAt順
        users.sort((a, b) {
          if (a.currentStatus.updatedRecently &&
              !b.currentStatus.updatedRecently) {
            return -1;
          }
          if (!a.currentStatus.updatedRecently &&
              b.currentStatus.updatedRecently) {
            return 1;
          }
          if (a.greenBadge && !b.greenBadge) {
            return -1;
          }
          if (!a.greenBadge && b.greenBadge) {
            return 1;
          }
          return b.lastOpenedAt.compareTo(a.lastOpenedAt);
        });
        if (users.isEmpty) {
          return const SizedBox();
        }
        return Padding(
          padding: EdgeInsets.only(top: themeSize.verticalPaddingSmall),
          child: SizedBox(
            height: 92,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(navigationRouterProvider(context)).goToChat(user);
                  },
                  onLongPress: () {
                    ref
                        .read(navigationRouterProvider(context))
                        .goToProfile(user);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: ThemeColor.accent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ThemeColor.stroke,
                        width: 0.4,
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              child: CachedImage.userIcon(
                                user.imageUrl,
                                user.name,
                                30,
                              ),
                            ),
                            // online and 10mins
                            (user.greenBadge)
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: ThemeColor.background,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.green,
                                    ),
                                  )
                                //blue status
                                : DateTime.now()
                                            .difference(
                                                user.lastOpenedAt.toDate())
                                            .inHours <
                                        4
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                            width: 2,
                                            color: ThemeColor.background,
                                          ),
                                          color: ThemeColor.highlight,
                                        ),
                                        child: Text(
                                          user.lastOpenedAt.xxStatus,
                                          style: const TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                            color: ThemeColor.white,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                          ],
                        ),
                        if (user.currentStatus.updatedRecently)
                          Container(
                            constraints: const BoxConstraints(maxWidth: 180),
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: textStyle.w600(
                                    fontSize: 14,
                                    color: ThemeColor.text,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  user.currentStatus.bubbles.first,
                                  style: textStyle.w400(
                                    color: ThemeColor.subText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
 */