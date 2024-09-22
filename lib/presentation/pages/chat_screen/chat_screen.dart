import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final asyncValue = ref.watch(dmOverviewListNotifierProvider);
    final myId = ref.watch(authProvider).currentUser!.uid;
    final listView = asyncValue.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text("no chats"));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final overview = list[index];
            final user = ref
                .read(allUsersNotifierProvider)
                .asData!
                .value[overview.userId]!;
            final q =
                overview.userInfoList.where((item) => item.userId == myId);
            bool unseenCheck = false;
            if (q.isNotEmpty) {
              final myInfo = q.first;
              if (myInfo.lastOpenedAt.compareTo(overview.updatedAt) < 0) {
                unseenCheck = true;
              }
            } else {
              unseenCheck = true;
            }
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChattingScreen(user: user),
                  ),
                );
              },
              splashColor: ThemeColor.highlight,
              highlightColor: ThemeColor.beige.withOpacity(0.3),
              child: Container(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(navigationRouterProvider(context))
                              .goToProfile(user);
                        },
                        child: UserIcon.tileIcon(user, width: 40),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user.username,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: ThemeColor.text,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "・${overview.lastMessage.createdAt.xxAgo}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: ThemeColor.beige,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      overview.lastMessage.text,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: ThemeColor.text,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (unseenCheck)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.cyan,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "チャット",
          style: TextStyle(
            color: ThemeColor.headline,
          ),
        ),
        actions: [
          /* const Icon(
            Icons.more_horiz_rounded,
            color: ThemeColor.icon,
          ), */
          Gap(themeSize.horizontalPadding),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
            child: Text(
              "フレンドとのチャットはここからできるよ！",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Gap(themeSize.verticalSpaceSmall),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                friendsListView(ref),
                Gap(themeSize.verticalPaddingMedium),
                listView,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget friendsListView(WidgetRef ref) {
    final asyncValue = ref.watch(friendIdListNotifierProvider);
    return asyncValue.when(
      data: (friendInfos) {
        if (friendInfos.isEmpty) {
          return const SizedBox();
        }
        final friendIds = friendInfos.map((item) => item.userId).toList();
        List<UserAccount> users = ref
            .watch(allUsersNotifierProvider)
            .asData!
            .value
            .values
            .where((user) => friendIds.contains(user.userId))
            .toList();

        users.sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));
        return SizedBox(
          height: 68,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: friendIds.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(navigationRouterProvider(context)).goToProfile(user);
                },
                onLongPress: () {
                  HapticFeedback.lightImpact();
                  ref.read(navigationRouterProvider(context)).goToChat(user);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        child: CachedImage.userIcon(
                          user.imageUrl,
                          user.username,
                          30,
                        ),
                      ),
                      user.isOnline ||
                              DateTime.now()
                                      .difference(user.lastOpenedAt.toDate())
                                      .inMinutes <
                                  3
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
                          : DateTime.now()
                                      .difference(user.lastOpenedAt.toDate())
                                      .inDays <
                                  1
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
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
                ),
              );
            },
          ),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }
}
