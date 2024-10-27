import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/text_styles.dart';
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
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(dmOverviewListNotifierProvider);
    final myId = ref.watch(authProvider).currentUser!.uid;
    final listView = asyncValue.when(
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: 72),
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
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
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
                    builder: (_) => ChattingScreen(userId: user.userId),
                  ),
                );
              },
              splashColor: ThemeColor.accent,
              highlightColor: ThemeColor.stroke,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    UserIcon(user: user, width: 54),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyle.w600(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                "・${overview.lastMessage.createdAt.xxAgo}",
                                style: textStyle.w600(
                                  color: ThemeColor.subText,
                                ),
                              ),
                            ],
                          ),
                          Gap(2),
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
                    Gap(24),
                    if (unseenCheck)
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.blue,
                      ),
                  ],
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
        toolbarHeight: themeSize.appbarHeight,
        centerTitle: false,
        title: Text(
          "チャット",
          style: textStyle.appbarText(japanese: true),
        ),
        actions: [
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
              style: textStyle.w400(color: ThemeColor.subText),
            ),
          ),
          Gap(themeSize.verticalSpaceSmall),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                friendsListView(context, ref),
                Gap(themeSize.verticalPaddingSmall),
                listView,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget friendsListView(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(friendIdListNotifierProvider);
    return asyncValue.when(
      data: (friendInfos) {
        final friendIds = friendInfos.map((item) => item.userId).toList();
        List<UserAccount> users = ref
            .read(allUsersNotifierProvider)
            .asData!
            .value
            .values
            .where((user) => friendIds.contains(user.userId))
            .toList();
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
                    ref
                        .read(navigationRouterProvider(context))
                        .goToProfile(user);
                  },
                  onLongPress: () {
                    ref.read(navigationRouterProvider(context)).goToChat(user);
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
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }
}
