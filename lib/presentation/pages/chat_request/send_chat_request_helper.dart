import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/usecases/chat_request_usecase.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/chat/sub_pages/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/providers/chats/dm_overview_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// チャットリクエスト送信のヘルパークラス
class SendChatRequestHelper {
  /// チャットまたはリクエストを開始
  ///
  /// 既にチャットがある場合はチャット画面へ遷移
  /// pendingリクエストがある場合はエラー表示
  /// なければリクエスト送信ダイアログを表示
  static Future<void> startChatOrRequest({
    required BuildContext context,
    required WidgetRef ref,
    required String targetUserId,
  }) async {
    final themeSize = ref.read(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    // 既存のチャットルームをチェック
    final dmOverviews = ref.read(dmOverviewListNotifierProvider).value ?? [];
    final existingChat = dmOverviews.where((dm) => dm.userId == targetUserId);

    if (existingChat.isNotEmpty && context.mounted) {
      // 既にチャットルームがある場合は直接チャット画面へ
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChattingScreen(userId: targetUserId),
        ),
      );
      return;
    }

    // 既存のリクエストをチェック
    final chatRequestUsecase = ref.read(chatRequestUsecaseProvider);
    final existingRequest =
        await chatRequestUsecase.checkExistingRequest(targetUserId);

    if (existingRequest != null && context.mounted) {
      // 既にリクエストがある場合
      showMessage(
        existingRequest.fromUserId == targetUserId
            ? 'このユーザーから既にリクエストが届いています'
            : '既にリクエストを送信しています',
      );
      return;
    }

    // リクエスト送信ダイアログを表示
    if (context.mounted) {
      final message = await showDialog<String?>(
        context: context,
        builder: (context) => _SendRequestDialog(
          textStyle: textStyle,
        ),
      );

      if (message != null && context.mounted) {
        try {
          await chatRequestUsecase.sendRequest(
            toUserId: targetUserId,
            message: message.isEmpty ? null : message,
          );

          if (context.mounted) {
            showMessage('リクエストを送信しました');
          }
        } catch (e) {
          if (context.mounted) {
            showMessage('エラーが発生しました: $e');
          }
        }
      }
    }
  }
}

/// リクエスト送信ダイアログ
class _SendRequestDialog extends StatefulWidget {
  const _SendRequestDialog({
    required this.textStyle,
  });

  final ThemeTextStyle textStyle;

  @override
  State<_SendRequestDialog> createState() => _SendRequestDialogState();
}

class _SendRequestDialogState extends State<_SendRequestDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColor.accent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          ThemeColor.highlight,
                          Colors.cyan,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'チャットリクエスト',
                      style: widget.textStyle.w600(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'メッセージを添えてリクエストを送信できます',
                style: widget.textStyle.w400(
                  fontSize: 14,
                  color: ThemeColor.subText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: ThemeColor.background.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeColor.stroke.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: '例: はじめまして！お話ししたいです',
                    hintStyle: widget.textStyle.w400(
                      fontSize: 14,
                      color: ThemeColor.subText.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                    counterStyle: widget.textStyle.w400(
                      fontSize: 12,
                      color: ThemeColor.subText,
                    ),
                  ),
                  style: widget.textStyle.w400(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeColor.text,
                        side: BorderSide(
                          color: ThemeColor.stroke.withOpacity(0.5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'キャンセル',
                        style: widget.textStyle.w600(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ThemeColor.highlight,
                            Colors.cyan,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeColor.highlight.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, _controller.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '送信',
                              style: widget.textStyle.w600(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
