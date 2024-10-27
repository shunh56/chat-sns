// Flutter imports:
import 'dart:math';
import 'dart:ui';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/chat_info_screen.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/widgets/left_message.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/widgets/right_message.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/widgets/server_message.dart';
import 'package:app/presentation/pages/others/report_user_screen.dart';
import 'package:app/presentation/providers/notifier/push_notification_notifier.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/chats/message_list.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/usecase/direct_message_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//import 'package:nomiboo/presentation/providers/direct_messages/dm_notifier.dart';
final randInt = Random().nextInt(6);

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final controllerProvider =
    Provider.autoDispose((ref) => TextEditingController());

class ChattingScreen extends ConsumerWidget {
  const ChattingScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));

    final topPadding = MediaQuery.of(context).viewPadding.top;
    final user = ref.read(allUsersNotifierProvider).asData!.value[userId]!;
    return GestureDetector(
      onTap: () {
        primaryFocus?.unfocus();

        // ref.read(currentScreenProvider.notifier).state = null;
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        // ドラッグの速度が一定値を超えたら、かつドラッグの方向が左向きであれば

        if (details.primaryVelocity! > 0) {
          // ref.read(currentScreenProvider.notifier).state = 'chatPage';
          //Navigator.of(context).pop();
          //ref.read(dmControllerProvider).clear();
          //ref.read(isSendButtonActiveProvider.notifier).state = false;
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _buildMessages(context, ref),
                ),
                BottomTextField(
                  user: user,
                ),
                //TypingWidget(user: user),
              ],
            ),
            //shader
            Positioned(
              top: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    height: topPadding + themeSize.appbarHeight,
                    width: themeSize.screenWidth,
                    color: ThemeColor.background.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            //appbar
            Positioned(
              top: 0,
              width: themeSize.screenWidth,
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    titleSpacing: 0,
                    title: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(navigationRouterProvider(context))
                                .goToProfile(user);
                          },
                          child: CachedImage.userIcon(
                            user.imageUrl,
                            user.name,
                            18,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatInfoScreen(
                                    userId: user.userId,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: ThemeColor.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Gap(4),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12,
                                      color: ThemeColor.white,
                                    ),
                                  ],
                                ),
                                user.isOnline ||
                                        DateTime.now()
                                                .difference(
                                                    user.lastOpenedAt.toDate())
                                                .inMinutes <
                                            3
                                    ? const Text(
                                        "オンライン",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: ThemeColor.white,
                                        ),
                                      )
                                    : DateTime.now()
                                                .difference(
                                                    user.lastOpenedAt.toDate())
                                                .inDays <
                                            1
                                        ? Text(
                                            "${user.lastOpenedAt.xxAgo}にオンライン",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: ThemeColor.white,
                                            ),
                                          )
                                        : const SizedBox(),
                              ],
                            ),
                          ),
                        ),

                        /* GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.info_outlined,
                            color: ThemeColor.white,
                            size: 24,
                          ),
                        ), */
                        Gap(themeSize.horizontalPadding)
                      ],
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: Colors.white.withOpacity(0.1),
                    thickness: 0.4,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final topPadding = MediaQuery.of(context).viewPadding.top;
    final messageList = ref.watch(messageListNotifierProvider(userId));
    final user = ref.read(allUsersNotifierProvider).asData!.value[userId]!;

    return messageList.when(
      data: (data) {
        bool isShort = data.length < 20;
        return ListView.builder(
          reverse: true,
          itemCount: data.length + (isShort ? 1 : 0),
          padding: EdgeInsets.only(
            top: topPadding + themeSize.appbarHeight + 12,
            bottom: 12,
          ),
          itemBuilder: (context, index) {
            if (isShort && index == data.length) {
              List<String> messages = [
                "お待たせしました！${user.name}とのチャットの舞台が開幕です。さぁ、メッセージの交換を始めましょう！",
                "おっす！ここからが${user.name}とのチャットのスタート地点。面白い会話をガンガン繰り広げよう！",
                "${user.name}とのチャットの魔法が始まるよ！この先にはどんな会話が待っているのか、楽しみだね。",
                "${user.name}とのチャットの時間がやってきました。さあ、楽しいおしゃべりを始めましょう！",
                "新しい物語の始まりだ！ここからチャットの冒険がスタートします。さぁ、話を続けよう！",
                "${user.name}とのチャットの世界へようこそ！ここからが本格的な会話の始まりだ。楽しんでね！"
              ];
              return Container(
                margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(navigationRouterProvider(context))
                            .goToProfile(user);
                      },
                      child: CachedImage.userIcon(
                        user.imageUrl,
                        user.name,
                        48,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: ThemeColor.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      messages[randInt],
                      style: const TextStyle(
                        color: ThemeColor.icon,
                      ),
                    )
                  ],
                ),
              );
            }
            final message = data[index];

            if (message.senderId != ref.watch(authProvider).currentUser!.uid) {
              if (message is CurrentStatusMessage) {
                return LeftCurrentStatusMessage(
                  message: message,
                  user: user,
                );
              }
              return LeftMessage(message: message, user: user);
            } else {
              if (message.senderId ==
                  ref.watch(authProvider).currentUser!.uid) {
                if (message is CurrentStatusMessage) {
                  return RightCurrentStatusMessage(
                      message: message, user: user);
                }
                return RightMessage(message: message, user: user);
              } else {
                return CenterMessage(message: message);
              }
            }
          },
        );
      },
      error: (e, s) {
        return const Text("error");
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

final messageSendingProvider = StateProvider<bool>((ref) => false);

final scrollControllerProvider = Provider<ScrollController>((ref) {
  return ScrollController();
});

class BottomTextField extends ConsumerWidget {
  final UserAccount user;
  const BottomTextField({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final controller = ref.watch(controllerProvider);
    final friendIds =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];
    final requestIds =
        ref.watch(friendRequestIdListNotifierProvider).asData?.value ?? [];
    final requestedIds =
        ref.watch(friendRequestedIdListNotifierProvider).asData?.value ?? [];
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 24;

    if (user.accountStatus == AccountStatus.deleted) {
      return Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.only(
          top: 12,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        decoration: BoxDecoration(
          color: ThemeColor.accent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "メッセージができません。",
              style: TextStyle(
                color: ThemeColor.text,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Gap(12),
            Text(
              "このユーザーはアカウントを削除したため、現在このユーザーとチャットをすることはできません。",
              style: TextStyle(
                color: ThemeColor.text.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const Gap(16),
            Material(
              color: ThemeColor.stroke,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ref
                      .read(dmOverviewListNotifierProvider.notifier)
                      .leaveChat(user);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Center(
                    child: Text(
                      "閉じる",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
    if (friendIds.map((item) => item.userId).contains(user.userId)) {
      return Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.only(
          top: 12,
          left: 16,
          right: 16,
          bottom: bottomPadding,
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 6,
          style: textStyle.w600(
            fontSize: 14,
          ),
          onChanged: (value) {
            ref.read(inputTextProvider.notifier).state = value;
          },
          decoration: InputDecoration(
            hintText: "メッセージを入力",
            filled: true,
            isDense: true,
            fillColor: ThemeColor.stroke,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            hintStyle: textStyle.w400(
              fontSize: 14,
              color: ThemeColor.subText,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            suffixIcon: ref.watch(inputTextProvider).isNotEmpty
                ? GestureDetector(
                    onTap: () async {
                      final text = ref.read(inputTextProvider);
                      ref.read(dmUsecaseProvider).sendMessage(text, user);
                      ref
                          .read(pushNotificationNotifierProvider)
                          .sendDm(user, text);
                      controller.clear();
                      ref.read(inputTextProvider.notifier).state = "";
                    },
                    child: const Icon(
                      Icons.send,
                      color: ThemeColor.highlight,
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      );
    }
    if (requestedIds.contains(user.userId)) {
      return Container(
          width: MediaQuery.sizeOf(context).width,
          padding: EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
            bottom: bottomPadding,
          ),
          decoration: BoxDecoration(
            color: ThemeColor.highlight.withOpacity(0.3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "フレンドリクエストを許可しますか？",
                style: TextStyle(
                  color: ThemeColor.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Gap(12),
              Text(
                "フレンドリクエストを許可すると、チャット一覧に追加され、ユーザーとチャットを行うことができます。",
                style: TextStyle(
                  color: ThemeColor.text.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportUserScreen(user),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ThemeColor.error.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: const Center(
                          child: Text(
                            "報告",
                            style: TextStyle(
                              color: ThemeColor.beige,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(dmOverviewListNotifierProvider.notifier)
                            .leaveChat(user);
                        ref
                            .read(
                                friendRequestedIdListNotifierProvider.notifier)
                            .deleteRequested(user);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ThemeColor.error.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: const Center(
                          child: Text(
                            "削除",
                            style: TextStyle(
                              color: ThemeColor.beige,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(
                                friendRequestedIdListNotifierProvider.notifier)
                            .admitFriendRequested(user);
                        ref
                            .read(dmOverviewListNotifierProvider.notifier)
                            .joinChat(user);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: const Center(
                          child: Text(
                            "許可",
                            style: TextStyle(
                              color: ThemeColor.beige,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ));
    }
    if (requestIds.contains(user.userId)) {
      return Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.only(
          top: 12,
          left: 16,
          right: 16,
          bottom: bottomPadding,
        ),
        decoration: BoxDecoration(
          color: ThemeColor.highlight.withOpacity(0.3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "フレンドリクエストを送信しました。",
              style: TextStyle(
                color: ThemeColor.text,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Gap(12),
            Text(
              "ユーザーがフレンドリクエストを許可すると、チャット一覧に追加され、ユーザーとチャットを行うことができます。",
              style: TextStyle(
                color: ThemeColor.text.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const Gap(16),
            GestureDetector(
              onTap: () {
                ref
                    .read(dmOverviewListNotifierProvider.notifier)
                    .leaveChat(user);
                ref
                    .read(friendRequestIdListNotifierProvider.notifier)
                    .cancelFriendRequest(user.userId);
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeColor.highlight,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: const Center(
                  child: Text(
                    "フレンドリクエストを取り消す",
                    style: TextStyle(
                      color: ThemeColor.beige,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.highlight.withOpacity(0.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "メッセージができません。",
            style: TextStyle(
              color: ThemeColor.text,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Gap(12),
          Text(
            "このユーザーとはフレンドではないため、現在このユーザーとチャットをすることはできません。",
            style: TextStyle(
              color: ThemeColor.text.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const Gap(16),
          GestureDetector(
            onTap: () {
              ref.read(dmOverviewListNotifierProvider.notifier).leaveChat(user);
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: ThemeColor.highlight,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Center(
                child: Text(
                  "閉じる",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
