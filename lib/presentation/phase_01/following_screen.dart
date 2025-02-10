import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/phase_01/room_screen.dart';
import 'package:app/presentation/providers/following_rooms.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class FollowingScreen extends ConsumerWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(followingUsersProvider);
    final me = ref.watch(myAccountNotifierProvider).asData!.value;

    return SafeArea(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomScreen(
                    roomId: me.userId,
                    scrollController: ScrollController(),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ThemeColor.accent,
              ),
              child: const Center(
                child: Text(
                  "GO TO MY ROOM",
                ),
              ),
            ),
          ),
          Expanded(
            child: asyncValue.when(
              data: (users) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return InkWell(
                      onLongPress: () async {
                        final closed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: Row(
                              children: [
                                UserIcon(user: user),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  style: textStyle.w600(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ],
                            actionsPadding:
                                const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                            builder: (_) => RoomScreen(
                              roomId: user.userId,
                              scrollController: ScrollController(),
                            ),
                          ),
                        );
                      },
                      splashColor: ThemeColor.accent,
                      highlightColor: ThemeColor.stroke,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            UserIcon(
                              user: user,
                              width: 60,
                              isCircle: true,
                            ),
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
                                        "・${Timestamp.now().xxAgo}",
                                        style: textStyle.w600(
                                          color: ThemeColor.subText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(2),
                                  Text(
                                    "hello?",
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
                            const Gap(24),
                            if (true)
                              const CircleAvatar(
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
              loading: () => const SizedBox(),
              error: (e, s) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
