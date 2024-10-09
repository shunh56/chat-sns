import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/user_bottomsheet.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/pages/others/report_user_screen.dart';
import 'package:app/presentation/pages/timeline_page/voice_chat_screen.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/muted_list.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/voice_chat_usecase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:gap/gap.dart';

class ChatInfoScreen extends ConsumerWidget {
  const ChatInfoScreen({super.key, required this.userId});
  final String userId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final user = ref.watch(allUsersNotifierProvider).asData!.value[userId]!;
    final queue = ref
        .watch(friendIdListNotifierProvider)
        .asData!
        .value
        .where((item) => item.userId == user.userId);
    final mutes = ref.watch(mutesListNotifierProvider).asData?.value ?? [];
    final isMuted = mutes.contains(user.userId);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            isMuted
                ? GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(mutesListNotifierProvider.notifier)
                          .unMuteUser(user);
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0),
                      child: const Icon(
                        Icons.notifications_off_rounded,
                        size: 20,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(mutesListNotifierProvider.notifier)
                          .muteUser(user);
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0),
                      child: const Icon(
                        Icons.notifications_rounded,
                        size: 20,
                      ),
                    ),
                  ),
            const Gap(12),
            if (queue.isNotEmpty)
              FocusedMenuHolder(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                menuWidth: 120,
                blurSize: 0,
                animateMenuItems: false,
                openWithTap: true,
                menuBoxDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                menuItems: <FocusedMenuItem>[
                  FocusedMenuItem(
                    backgroundColor: ThemeColor.background,
                    title: const Text(
                      "フレンド解除",
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(friendIdListNotifierProvider.notifier)
                          .deleteFriend(user);
                      ref
                          .read(dmOverviewListNotifierProvider.notifier)
                          .leaveChat(user);
                      int count = 0;
                      Navigator.popUntil(context, (route) {
                        count += 1;
                        return count == 3;
                      });
                    },
                  ),
                  FocusedMenuItem(
                    backgroundColor: ThemeColor.background,
                    title: const Text(
                      "報告",
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportUserScreen(user),
                        ),
                      );
                    },
                  ),
                  FocusedMenuItem(
                    backgroundColor: ThemeColor.background,
                    title: const Text(
                      "ブロック",
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();

                      UserBottomModelSheet(context).blockUserBottomSheet(
                        user,
                        count: 3,
                      );
                    },
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                  ),
                ),
              ),
            Gap(themeSize.horizontalPadding)
          ],
        ),
        body: queue.isEmpty
            ? Center(
                child: Column(
                  children: [
                    Gap(themeSize.verticalPaddingLarge),
                    UserIcon.circleIcon(user, radius: 36),
                    const Gap(12),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(12),
                    const Text(
                      "このユーザーとはフレンドではありません。",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  _buildTopSection(context, ref, user),
                  Expanded(
                    child: Column(
                      children: [
                        const Gap(12),
                        TabBar(
                          isScrollable: true,
                          // dividerColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              horizontal: themeSize.horizontalPadding - 4),
                          indicator: BoxDecoration(
                            color: ThemeColor.button,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          tabAlignment: TabAlignment.start,
                          indicatorPadding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: ThemeColor.background,
                          unselectedLabelColor: Colors.white.withOpacity(0.3),
                          dividerColor: ThemeColor.background,
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              // Use the default focused overlay color
                              return states.contains(WidgetState.focused)
                                  ? null
                                  : Colors.transparent;
                            },
                          ),
                          tabs: const [
                            Tab(child: Text("写真")),
                            Tab(child: Text("ボイスチャット")),
                            Tab(child: Text("リンク")),
                            Tab(child: Text("メッセージ")),
                          ],
                        ),
                        const Expanded(
                          child: TabBarView(
                            children: [
                              Center(
                                child: Text("写真"),
                              ),
                              Center(
                                child: Text("ボイスチャット"),
                              ),
                              Center(
                                child: Text("リンク"),
                              ),
                              Center(
                                child: Text("メッセージ"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  _buildTopSection(BuildContext context, WidgetRef ref, UserAccount user) {
    final queue = ref
        .watch(friendIdListNotifierProvider)
        .asData!
        .value
        .where((item) => item.userId == user.userId);

    final friendInfo = queue.first;
    final mutes = ref.watch(mutesListNotifierProvider).asData?.value ?? [];
    final isMuted = mutes.contains(user.userId);
    return Column(
      children: [
        UserIcon.circleIcon(user, radius: 36),
        const Gap(12),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "${friendInfo.createdAt.toDateStr} - ",
          style: const TextStyle(
            fontSize: 12,
            color: ThemeColor.beige,
            fontWeight: FontWeight.w600,
          ),
        ),
        // const Gap(24),
        if (false)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      //TODO 通話を2人だけにするか、公開にするかどうか
                      /* HapticFeedback.lightImpact();
                    final functions = FirebaseFunctions.instanceFor(
                        region: "asia-northeast1");
                    final HttpsCallable callable = functions
                        .httpsCallable('pushNotification-sendPushNotification');
                    final fcmToken = user.fcmToken;
                    if (fcmToken == null) {
                      showMessage("NO FCM TOKEN");
                      return;
                    }
                    final me =
                        ref.read(myAccountNotifierProvider).asData!.value;
                    try {
                      final result = await callable.call({
                        'token': fcmToken,
                        'title': 'appName',
                        'body': 'sending notification',
                        'metaData': "data",
                      });
                      showMessage("push notification response : ${result.data}");
                      DebugPrint("response : ${result.data}");
                    } catch (e) {
                      showMessage("push notification error : $e");
                      DebugPrint("error : $e");
                    } */
                      HapticFeedback.lightImpact();
                      final fcmCallable = FirebaseFunctions.instanceFor(
                              region: "asia-northeast1")
                          .httpsCallable('pushNotification-sendCall');

                      final voipCallable = FirebaseFunctions.instanceFor(
                              region: "asia-northeast1")
                          .httpsCallable('voip-send');

                      final me =
                          ref.read(myAccountNotifierProvider).asData!.value;
                      final voipToken = user.voipToken;
                      final fcmToken = user.fcmToken;
                      if (voipToken == null || voipToken.isEmpty) {
                        if (fcmToken != null) {
                          try {
                            DebugPrint("sending fcm notification");
                            final result = await fcmCallable.call({
                              'token': fcmToken,
                              'userId': me.userId,
                              'name': me.name,
                              'imageUrl': me.imageUrl,
                              'dateTime': DateTime.now().toString(),
                            });
                            DebugPrint("response : ${result.data}");
                          } catch (e) {
                            DebugPrint("error : $e");
                          }
                        }
                      } else {
                        try {
                          final vc = await ref
                              .read(voiceChatUsecaseProvider)
                              .createVoiceChat("VOICE CALL");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VoiceChatScreen(id: vc.id),
                            ),
                          );
                          DebugPrint("sending voip notification");
                          final result = await voipCallable.call({
                            'tokens': [voipToken],
                            'name': me.name,
                            'id': vc.id,
                          });
                          showMessage("voip response : ${result.data}");
                          DebugPrint("response : ${result.data}");
                        } catch (e) {
                          showMessage("push notification error : $e");
                          DebugPrint("error : $e");
                        }
                      }
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.phone,
                      ),
                    ),
                  ),
                  const Gap(4),
                  const Text(
                    "通話",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeColor.beige,
                    ),
                  )
                ],
              ),
              const Gap(32),
              isMuted
                  ? Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(mutesListNotifierProvider.notifier)
                                .unMuteUser(user);
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(
                              Icons.notifications_off_rounded,
                            ),
                          ),
                        ),
                        const Gap(4),
                        const Text(
                          "ミュート",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ThemeColor.beige,
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(mutesListNotifierProvider.notifier)
                                .muteUser(user);
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(
                              Icons.notifications_rounded,
                            ),
                          ),
                        ),
                        const Gap(4),
                        const Text(
                          "ミュート",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ThemeColor.beige,
                          ),
                        )
                      ],
                    ),
            ],
          ),
      ],
    );
  }
}
