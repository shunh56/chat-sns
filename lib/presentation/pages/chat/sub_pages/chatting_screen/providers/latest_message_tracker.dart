import 'package:app/core/utils/debug_print.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 最新のメッセージIDを追跡するProvider
final latestMessageIdProvider = StateNotifierProvider<LatestMessageNotifier, String>((ref) {
  return LatestMessageNotifier();
});

/// 最新のメッセージIDを管理するNotifier
class LatestMessageNotifier extends StateNotifier<String> {
  LatestMessageNotifier() : super("");

  /// 最新のメッセージIDを設定
  void setLatestMessageId(String messageId) {
    if (messageId.isNotEmpty) {
      DebugPrint("最新メッセージIDを設定: $messageId");
      state = messageId;
    }
  }

  /// 指定されたメッセージが最新かどうかを判定
  bool isLatestMessage(String messageId) {
    final result = state == messageId;
    return result;
  }

  /// 最新メッセージIDをクリア
  void clear() {
    state = "";
  }
}