// Flutter imports:
import 'dart:math';
import 'dart:ui';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/widgets/left_message.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/widgets/right_message.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/widgets/server_message.dart';
import 'package:app/presentation/pages/timeline_page/voice_chat_screen.dart';
import 'package:app/presentation/providers/notifier/push_notification_notifier.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/chats/message_list.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/followers_list_notifier.dart';
import 'package:app/presentation/providers/provider/following_list_notifier.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:app/usecase/direct_message_usecase.dart';
import 'package:app/usecase/voip_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//import 'package:nomiboo/presentation/providers/direct_messages/dm_notifier.dart';

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final controllerProvider =
    Provider.autoDispose((ref) => TextEditingController());
final scrollConrtollerProvider =
    Provider.autoDispose((ref) => ScrollController());

class ChattingScreen extends HookConsumerWidget {
  const ChattingScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

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
                    color: ThemeColor.background.withOpacity(0.7),
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
                              /* Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatInfoScreen(
                                    userId: user.userId,
                                  ),
                                ),
                              ); */
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(4),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    color: ThemeColor.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                user.greenBadge
                                    ? Text(
                                        user.badgeStatus,
                                        style: textStyle.w400(
                                          fontSize: 11,
                                          color: Colors.green,
                                        ),
                                      )
                                    : Text(
                                        user.badgeStatus,
                                        style: textStyle.w400(
                                          fontSize: 11,
                                          color: ThemeColor.subText,
                                        ),
                                      )
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

                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            final followings = ref
                                    .watch(followingListNotifierProvider)
                                    .asData
                                    ?.value ??
                                [];
                            final followers = ref
                                    .watch(followersListNotifierProvider)
                                    .asData
                                    ?.value ??
                                [];

                            final isFollowing = followings
                                .any((follow) => follow.userId == user.userId);
                            final isFollowed = followers
                                .any((follow) => follow.userId == user.userId);
                            final isMutualFollow = isFollowing && isFollowed;
                            final blockeds = ref
                                    .watch(blockedsListNotifierProvider)
                                    .asData
                                    ?.value ??
                                [];
                            final blocks = ref
                                    .watch(blocksListNotifierProvider)
                                    .asData
                                    ?.value ??
                                [];
                            final filters = blocks + blockeds;
                            if (filters.contains(user.userId)) {
                              showMessage("エラーが起きました。");
                              return;
                            }
                            if (isMutualFollow) {
                              final vc = await ref
                                  .read(voipUsecaseProvider)
                                  .callUser(user);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VoiceChatScreen(id: vc.id),
                                ),
                              );
                            } else {
                              showMessage("相互フォローでないと通話はできません。");
                            }
                          },
                          child: const Icon(
                            Icons.phone,
                          ),
                        ),
                        Gap(themeSize.horizontalPadding)
                      ],
                    ),
                  ),
                  const Gap(4),
                  Divider(
                    height: 0,
                    color: Colors.white.withOpacity(0.2),
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

    final scrollController = ref.watch(scrollConrtollerProvider);
    final notifier = ref.read(messageListNotifierProvider(userId).notifier);

    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          notifier.loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return messageList.when(
      data: (data) {
        // bool isShort = data.length < 20;
        bool showLoadMore =
            ref.watch(messageListNotifierProvider(userId).notifier).hasMore;

        return ListView.builder(
          reverse: true,
          itemCount: data.length + 1,
          controller: scrollController,
          padding: EdgeInsets.only(
            top: topPadding + themeSize.appbarHeight + 12,
            bottom: 12,
          ),
          itemBuilder: (context, index) {
            // 最後のアイテム（リストの一番上）がローディングインジケーター
            if (index == data.length) {
              if (showLoadMore) {
                return const SizedBox();
              } else {
                List<String> messages = [
                  "お待たせしました！${user.name}さんとのチャットの舞台が開幕です。さぁ、メッセージの交換を始めましょう！",
                  "おっす！ここからが${user.name}さんとのチャットのスタート地点。面白い会話をガンガン繰り広げよう！",
                  "${user.name}さんとのチャットの魔法が始まるよ！この先にはどんな会話が待っているのか、楽しみだね。",
                  "${user.name}さんとのチャットの時間がやってきました。さあ、楽しいおしゃべりを始めましょう！",
                  "新しい物語の始まりだ！ここからチャットの冒険がスタートします。さぁ、話を続けよう！",
                  "${user.name}さんとのチャットの世界へようこそ！ここからが本格的な会話の始まりだ。楽しんでね！"
                ];
                final randInt = Random().nextInt(messages.length);

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: 12, left: 12, right: 12),
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
            }

            // 最初のメッセージの場合（リストの一番下）

            // 通常のメッセージ
            final message = data[index];
            if (message.senderId != ref.watch(authProvider).currentUser!.uid) {
              if (message is CurrentStatusMessage) {
                return const SizedBox();
              }
              return LeftMessage(message: message, user: user);
            } else {
              if (message.senderId ==
                  ref.watch(authProvider).currentUser!.uid) {
                if (message is CurrentStatusMessage) {
                  return const SizedBox();
                }
                return RightMessage(message: message, user: user);
              } else {
                return CenterMessage(message: message);
              }
            }
          },
        );
      },
      error: (e, s) => Center(child: Text("error : $e, $s")),
      loading: () => const Center(child: CircularProgressIndicator()),
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 24;

    // フォロー関連の状態取得
    final followings =
        ref.watch(followingListNotifierProvider).asData?.value ?? [];
    final followers =
        ref.watch(followersListNotifierProvider).asData?.value ?? [];
    final isFollowing =
        followings.any((follow) => follow.userId == user.userId);
    final isFollowed = followers.any((follow) => follow.userId == user.userId);
    final isMutualFollow = isFollowing && isFollowed;

    // ブロック関連の状態取得
    final blocks = ref.watch(blocksListNotifierProvider).asData?.value ?? [];
    final blockeds =
        ref.watch(blockedsListNotifierProvider).asData?.value ?? [];
    final isBlocking = blocks.any((userId) => userId == user.userId);
    final isBlocked = blockeds.any((userId) => userId == user.userId);

    // アカウント削除状態の確認
    if (user.accountStatus == AccountStatus.deleted) {
      return _buildMessageContainer(
        context: context,
        title: "メッセージができません。",
        message: "このユーザーはアカウントを削除したため、現在このユーザーとチャットをすることはできません。",
        ref: ref,
        user: user,
      );
    }

    // ブロック状態の確認
    if (isBlocking || isBlocked) {
      final message = isBlocking
          ? "このユーザーをブロックしているため、メッセージを送信することができません。"
          : "このユーザーからブロックされているため、メッセージを送信することができません。";
      return _buildMessageContainer(
        context: context,
        title: "メッセージができません。",
        message: message,
        ref: ref,
        user: user,
      );
    }

    // 相互フォロー状態に基づくメッセージ入力フィールドの表示
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: isMutualFollow ? null : ThemeColor.highlight.withOpacity(0.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMutualFollow) ...[
            const Gap(12),
            Text(
              "${user.name}さんにメッセージを送る",
              style: textStyle.w600(
                fontSize: 16,
                color: ThemeColor.text,
              ),
            ),
            const Gap(12),
            Text(
              "${user.name}さんと相互フォローではないので、メッセージは相手のリクエスト一覧に届きます。思いやりを持ったメッセージを心がけましょう。",
              style: textStyle.w400(
                color: ThemeColor.text.withOpacity(0.7),
                height: 1.8,
              ),
            ),
            const Gap(16),
          ],
          TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 6,
            maxLength: 400,
            style: textStyle.w600(fontSize: 13),
            onChanged: (value) {
              ref.read(inputTextProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: "${user.name}へメッセージを入力",
              counterText: "",
              filled: true,
              fillColor: ThemeColor.stroke,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
              hintStyle: textStyle.w400(
                fontSize: 13,
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
                        if (isMutualFollow || true) {
                          ref
                              .read(pushNotificationNotifierProvider)
                              .sendDm(user, text);
                        }

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
        ],
      ),
    );
  }

  Widget _buildMessageContainer({
    required BuildContext context,
    required String title,
    required String message,
    required WidgetRef ref,
    required UserAccount user,
  }) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: const BoxDecoration(
        color: ThemeColor.accent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ThemeColor.text,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Gap(12),
          Text(
            message,
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
}
