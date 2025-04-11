import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/providers/new/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/new/providers/follow/followers_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/notifier/push_notification_notifier.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:app/usecase/direct_message_usecase.dart';

import '../providers/chat_providers.dart';

/// チャット入力フィールドウィジェット（アニメーション削除版）
class BottomTextField extends HookConsumerWidget {
  final UserAccount user;

  const BottomTextField({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final controller = ref.watch(controllerProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 24;

    // フォロー関連の状態取得

    final followingNotifier = ref.watch(followingListNotifierProvider.notifier);
    final followerNotifier = ref.watch(followersListNotifierProvider.notifier);
    final isFollowing = followingNotifier.isFollowing(user.userId);
    final isFollowed = followerNotifier.isFollower(user.userId);
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
          // 相互フォローではない場合の説明文
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

          // メッセージ入力フィールド
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
                      onTap: () {
                        // メッセージ送信
                        _sendMessage(ref, controller);
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

  /// メッセージ送信処理
  void _sendMessage(WidgetRef ref, TextEditingController controller) async {
    final text = ref.read(inputTextProvider);
    if (text.isEmpty) return;

    try {
      // メッセージ送信
      await ref.read(dmUsecaseProvider).sendMessage(text, user);

      // メッセージリストの更新を促す
      // この後、MessageListWidgetが新しいメッセージを検出してアニメーションを適用する

      // 通知送信
      ref.read(pushNotificationNotifierProvider).sendDm(user, text);

      // テキスト入力をクリア
      controller.clear();
      ref.read(inputTextProvider.notifier).state = "";
    } catch (e) {
      DebugPrint("メッセージ送信エラー: $e");
    }
  }

  /// メッセージ送信不可の際に表示するコンテナ
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
