import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/pages/chat/sub_pages/chatting_screen/widgets/left_message.dart';
import 'package:app/presentation/pages/chat/sub_pages/chatting_screen/widgets/right_message.dart';
import 'package:app/presentation/pages/chat/sub_pages/chatting_screen/widgets/server_message.dart';
import 'package:app/presentation/pages/chat/sub_pages/chatting_screen/widgets/welcome_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/provider/chats/message_list.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';

import '../providers/chat_providers.dart';
import '../providers/latest_message_tracker.dart';

/// メッセージリスト表示用ウィジェット
class MessageListWidget extends HookConsumerWidget {
  final String userId;

  const MessageListWidget({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final topPadding = MediaQuery.of(context).viewPadding.top;
    final messageList = ref.watch(messageListNotifierProvider(userId));
    final user = ref.read(allUsersNotifierProvider).asData!.value[userId]!;
    final scrollController = ref.watch(scrollControllerProvider);
    final notifier = ref.read(messageListNotifierProvider(userId).notifier);

    // 前回のメッセージリストの長さを記録する
    final previousMessageCount = useRef<int>(0);

    // 最新メッセージIDを一時的に保持するための変数
    final latestMessageId = useRef<String?>(null);
    
    // 初回ロード済みかどうかを記録するフラグ
    final isInitialLoadCompleted = useRef<bool>(false);

    // メッセージリストの変更を監視して最新メッセージを検出
    useEffect(() {
      messageList.whenData((messages) {
        // 初回ロード時は何もしない（アニメーションしない）
        if (!isInitialLoadCompleted.value) {
          DebugPrint("初回ロード - アニメーションなし");
          isInitialLoadCompleted.value = true;
          previousMessageCount.value = messages.length;
          return;
        }
        
        // メッセージが増えた場合（新しいメッセージが追加された）
        if (messages.isNotEmpty && messages.length > previousMessageCount.value) {
          // リストが逆順なので、インデックス0が最新のメッセージ
          final newLatestMessageId = messages[0].id;

          // ローカル変数に最新メッセージIDを保存
          latestMessageId.value = newLatestMessageId;

          // プロバイダーを更新（Future.microtaskは不要）
          ref.read(latestMessageIdProvider.notifier).setLatestMessageId(newLatestMessageId);

          // 1秒後に最新メッセージIDをクリア（アニメーション終了後）
          Future.delayed(const Duration(seconds: 1), () {
            if (ref.read(latestMessageIdProvider) == newLatestMessageId) {
              ref.read(latestMessageIdProvider.notifier).clear();
              latestMessageId.value = null;
              DebugPrint("最新メッセージIDをクリア: $newLatestMessageId");
            }
          });

          DebugPrint("新しいメッセージを検出: $newLatestMessageId");
        }

        // 現在のメッセージ数を保存
        previousMessageCount.value = messages.length;
      });

      return null;
    }, [messageList]);

    // スクロール監視のためのフック
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          notifier.loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return messageList.when(
      data: (data) {
        bool showLoadMore = ref.watch(messageListNotifierProvider(userId).notifier).hasMore;

        return ListView.builder(
          reverse: true,
          itemCount: data.length + 1,
          controller: scrollController,
          padding: EdgeInsets.only(
            top: topPadding + themeSize.appbarHeight + 12,
            bottom: 12,
          ),
          itemBuilder: (context, index) {
            // 最後のアイテム（リストの一番上）の処理
            if (index == data.length) {
              if (showLoadMore) {
                return const SizedBox();
              } else {
                return WelcomeMessageWidget(user: user);
              }
            }

            // 通常のメッセージ表示
            final message = data[index];
            final currentUserId = ref.watch(authProvider).currentUser!.uid;

            // メッセージが最新かどうかを判定（ローカル変数を使用）
            // 初回ロード時は常にfalseを返す
            final isLatest = isInitialLoadCompleted.value && message.id == latestMessageId.value;
            
            if (isLatest) {
              DebugPrint("アニメーション表示するメッセージ: ${message.id} (最新ID: ${latestMessageId.value}) ${message.text}");
            }

            if (message.senderId != currentUserId) {
              return LeftMessage(
                key: isLatest ? Key('left_${message.id}_anim') : Key('left_${message.id}'),
                message: message,
                user: user,
                isLatest: isLatest,
              );
            } else if (message.senderId == currentUserId) {
              return RightMessage(
                key: isLatest ? Key('right_${message.id}_anim') : Key('right_${message.id}'),
                message: message,
                user: user,
                isLatest: isLatest,
              );
            } else {
              return CenterMessage(message: message);
            }
          },
        );
      },
      error: (e, s) => Center(child: Text("error : $e, $s")),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}