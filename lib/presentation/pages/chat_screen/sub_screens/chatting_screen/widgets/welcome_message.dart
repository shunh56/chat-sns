import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';

// ユーザーIDごとにメッセージを固定するためのプロバイダー
final welcomeMessageProvider = 
    StateProvider.family<String, String>((ref, userId) {
  // ランダムなウェルカムメッセージリスト（静的に定義）
  final messages = [
    "お待たせしました！{name}さんとのチャットの舞台が開幕です。さぁ、メッセージの交換を始めましょう！",
    "おっす！ここからが{name}さんとのチャットのスタート地点。面白い会話をガンガン繰り広げよう！",
    "{name}さんとのチャットの魔法が始まるよ！この先にはどんな会話が待っているのか、楽しみだね。",
    "{name}さんとのチャットの時間がやってきました。さあ、楽しいおしゃべりを始めましょう！",
    "新しい物語の始まりだ！ここからチャットの冒険がスタートします。さぁ、話を続けよう！",
    "{name}さんとのチャットの世界へようこそ！ここからが本格的な会話の始まりだ。楽しんでね！"
  ];
  
  // 固定のランダムメッセージを選択
  final randInt = Random().nextInt(messages.length);
  return messages[randInt];
});

/// チャット初期時のウェルカムメッセージウィジェット（固定メッセージ版）
class WelcomeMessageWidget extends ConsumerWidget {
  final UserAccount user;

  const WelcomeMessageWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ユーザーIDに基づいて固定メッセージを取得
    final messageTemplate = ref.watch(welcomeMessageProvider(user.userId));
    // ユーザー名を挿入
    final message = messageTemplate.replaceAll('{name}', user.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              ref.read(navigationRouterProvider(context)).goToProfile(user);
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
            message,
            style: const TextStyle(
              color: ThemeColor.icon,
            ),
          )
        ],
      ),
    );
  }
}