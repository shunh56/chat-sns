import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';

import 'widgets/app_bar_widget.dart';
import 'widgets/bottom_text_field.dart';
import 'widgets/message_list.dart';

/// チャット画面のメインクラス
class ChattingScreen extends ConsumerWidget {
  const ChattingScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final topPadding = MediaQuery.of(context).viewPadding.top;
    final user = ref.read(allUsersNotifierProvider).asData!.value[userId]!;
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! > 0) {
          // 右へのスワイプ処理（現状は無効化）
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // メッセージリストとテキスト入力フィールド
            Column(
              children: [
                Expanded(
                  child: MessageListWidget(userId: userId),
                ),
                BottomTextField(user: user),
              ],
            ),

            // 上部ブラー効果
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

            // アプリバー
            Positioned(
              top: 0,
              width: themeSize.screenWidth,
              child: ChatAppBar(user: user),
            ),
          ],
        ),
      ),
    );
  }
}
