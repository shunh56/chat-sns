import 'package:app/data/repository/chat_request_repository.dart';
import 'package:app/domain/entity/chat_request.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/direct_message_overview_usecase.dart';
import 'package:app/domain/usecases/push_notification_usecase.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRequestUsecaseProvider = Provider(
  (ref) => ChatRequestUsecase(
    ref,
    ref.watch(chatRequestRepositoryProvider),
    ref.watch(dmOverviewUsecaseProvider),
    ref.watch(pushNotificationUsecaseProvider),
  ),
);

class ChatRequestUsecase {
  final Ref _ref;
  final ChatRequestRepository _repository;
  final DirectMessageOverviewUsecase _dmOverviewUsecase;
  final PushNotificationUsecase _pushNotificationUsecase;

  ChatRequestUsecase(
    this._ref,
    this._repository,
    this._dmOverviewUsecase,
    this._pushNotificationUsecase,
  );

  /// 受信したチャットリクエスト一覧をストリーム
  Stream<List<ChatRequest>> streamReceivedRequests() {
    return _repository.streamReceivedRequests();
  }

  /// 送信したチャットリクエスト一覧をストリーム
  Stream<List<ChatRequest>> streamSentRequests() {
    return _repository.streamSentRequests();
  }

  /// 特定のユーザーとの間に既存のpendingリクエストがあるかチェック
  Future<ChatRequest?> checkExistingRequest(String otherUserId) {
    return _repository.checkExistingRequest(otherUserId);
  }

  /// チャットリクエストを送信
  Future<void> sendRequest({
    required String toUserId,
    String? message,
  }) async {
    // 既存のリクエストをチェック
    final existingRequest = await checkExistingRequest(toUserId);
    if (existingRequest != null) {
      throw Exception('既にリクエストが存在します');
    }

    // リクエストを送信
    await _repository.sendRequest(
      toUserId: toUserId,
      message: message,
    );

    // 相手のUserAccountを取得して通知を送信
    try {
      final toUser = await _getUserAccount(toUserId);
      if (toUser != null) {
        await _pushNotificationUsecase.sendChatRequest(toUser, message);
      }
    } catch (e) {
      // 通知送信のエラーは握りつぶす（リクエスト送信自体は成功とする）
      print('チャットリクエスト通知の送信に失敗: $e');
    }
  }

  /// チャットリクエストを承認してチャットルームを作成
  Future<void> acceptRequest(String requestId) async {
    final request = await _repository.getRequest(requestId);
    if (request == null) {
      throw Exception('リクエストが見つかりません');
    }

    // リクエストを承認
    await _repository.acceptRequest(requestId);

    // チャットルームに参加（DMOverviewを作成）
    await _dmOverviewUsecase.joinChat(request.fromUserId);

    // 送信者のUserAccountを取得して通知を送信
    try {
      final fromUser = await _getUserAccount(request.fromUserId);
      if (fromUser != null) {
        await _pushNotificationUsecase.sendChatRequestAccepted(fromUser);
      }
    } catch (e) {
      // 通知送信のエラーは握りつぶす（承認処理自体は成功とする）
      print('チャットリクエスト承認通知の送信に失敗: $e');
    }
  }

  /// チャットリクエストを却下
  Future<void> rejectRequest(String requestId) {
    return _repository.rejectRequest(requestId);
  }

  /// リクエストをキャンセル（自分が送ったリクエストを削除）
  Future<void> cancelRequest(String requestId) {
    return _repository.cancelRequest(requestId);
  }

  /// UserIdからUserAccountを取得するヘルパーメソッド
  Future<UserAccount?> _getUserAccount(String userId) async {
    try {
      // AllUsersNotifierProviderからユーザー情報を取得
      final allUsers = _ref.read(allUsersNotifierProvider);
      final user = allUsers.asData?.value[userId];

      if (user != null) {
        return user;
      }

      // キャッシュにない場合は取得を試みる
      await _ref.read(allUsersNotifierProvider.notifier).updateUserAccount(userId);
      final updatedUsers = _ref.read(allUsersNotifierProvider);
      return updatedUsers.asData?.value[userId];
    } catch (e) {
      print('UserAccount取得エラー: $e');
      return null;
    }
  }
}
