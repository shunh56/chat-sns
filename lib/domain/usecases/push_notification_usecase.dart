import 'package:app/core/utils/flavor.dart';
import 'package:app/data/datasource/push_notification_datasource.dart';
import 'package:app/domain/entity/push_notification_model.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/toast.dart';
import 'package:app/presentation/providers/shared/users/my_user_account_notifier.dart';
import 'package:app/data/repository/push_notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationUsecaseProvider = Provider(
  (ref) => PushNotificationUsecase(
    ref,
    ref.watch(pushNotificationRepositoryProvider),
  ),
);

class PushNotificationUsecase {
  final Ref ref;
  final PushNotificationRepository _repository;

  PushNotificationUsecase(this.ref, this._repository);

  // 共通の通知送信メソッド
  Future<void> _sendPushNotification({
    required PushNotificationType type,
    PushNotificationSender? sender,
    PushNotificationReceiver? receiver,
    List<PushNotificationReceiver>? recipients,
    required PushNotificationContent content,
    PushNotificationPayload? payload,
    PushNotificationMetadata? metadata,
  }) async {
    final model = PushNotificationModel(
      type: type,
      sender: sender ?? _generateSender(),
      receiver: receiver,
      recipients: recipients,
      content: content,
      payload: payload,
      metadata: metadata ?? PushNotificationMetadata(),
    );

    if (Flavor.isDevEnv) {
      await handleError(
        process: () async {
          await _repository.sendPushNotification(model);
        },
        successMessage: '通知を送信しました',
        errorHandler: (e) {
          if (e is NotificationException) {
            return e.message;
          }
          return 'エラーが発生しました';
        },
      );
    } else {
      await _repository.sendPushNotification(model);
    }
  }

  // ★ 改修: ユーザーアカウントからレシーバーリストを生成するヘルパーメソッド
  // マルチデバイス対応: activeDevices から FCM トークンを持つデバイスを全て取得
  List<PushNotificationReceiver> _generateReceivers(UserAccount user) {
    // 新しいデバイス管理システムを優先
    if (user.activeDevices.isNotEmpty) {
      return user.activeDevices
          .where((device) =>
              device.fcmToken != null && device.canReceiveNotification)
          .map((device) => PushNotificationReceiver(
                userId: user.userId,
                fcmToken: device.fcmToken,
              ))
          .toList();
    }

    // フォールバック: 従来のフィールドを使用 (後方互換性)
    if (user.fcmToken != null) {
      return [
        PushNotificationReceiver(
          userId: user.userId,
          fcmToken: user.fcmToken,
        )
      ];
    }

    return [];
  }

  // 後方互換性のため残す (非推奨)
  @Deprecated('Use _generateReceivers() instead for multi-device support')
  PushNotificationReceiver _generateReceiver(UserAccount user) {
    return PushNotificationReceiver(
      userId: user.userId,
      fcmToken: user.fcmToken,
    );
  }

  // 現在のユーザーからセンダーを生成するヘルパーメソッド
  PushNotificationSender _generateSender() {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    return PushNotificationSender(
      userId: me.userId,
      name: me.name,
      imageUrl: me.imageUrl,
    );
  }

  // ★ 改修: フォロー通知 (マルチデバイス対応)
  Future<void> sendFollow(UserAccount user) async {
    final sender = _generateSender();
    final receivers = _generateReceivers(user);

    if (receivers.isEmpty) return;

    await _sendPushNotification(
      type: PushNotificationType.follow,
      sender: sender,
      recipients: receivers,
      content: PushNotificationContent(
        title: sender.name,
        body: "あなたをフォローしました。",
      ),
    );
  }

  // ★ 改修: いいね通知 (マルチデバイス対応)
  Future<void> sendPostReaction(UserAccount user) async {
    final sender = _generateSender();
    final receivers = _generateReceivers(user);

    if (receivers.isEmpty) return;

    await _sendPushNotification(
      type: PushNotificationType.like,
      sender: sender,
      recipients: receivers,
      content: PushNotificationContent(
        title: sender.name,
        body: "あなたの投稿に反応しました。",
      ),
    );
  }

  // ★ 改修: コメント通知 (マルチデバイス対応)
  Future<void> sendPostComment(UserAccount user) async {
    final sender = _generateSender();
    final receivers = _generateReceivers(user);

    if (receivers.isEmpty) return;

    await _sendPushNotification(
      type: PushNotificationType.comment,
      sender: sender,
      recipients: receivers,
      content: PushNotificationContent(
        title: sender.name,
        body: "あなたの投稿にコメントしました。",
      ),
    );
  }

  // ★ 改修: DM通知 (マルチデバイス対応)
  Future<void> sendDm(
    UserAccount user,
    String message,
  ) async {
    final sender = _generateSender();
    final receivers = _generateReceivers(user);

    if (receivers.isEmpty) return;

    await _sendPushNotification(
      type: PushNotificationType.dm,
      sender: sender,
      recipients: receivers,
      content: PushNotificationContent(
        title: sender.name,
        body: message,
      ),
      payload: PushNotificationPayload(
        text: message,
      ),
    );
  }

  // ★ 改修: 通話通知 (FCM 経由 - Android および VoIP 非対応 iOS 用)
  // VoipUsecase から呼び出される
  Future<void> sendCallNotificationViaFCM(
    UserAccount user,
    String callId,
    String callerName,
  ) async {
    final sender = _generateSender();
    final receivers = _generateReceivers(user);

    if (receivers.isEmpty) return;

    if (Flavor.isDevEnv) {
      await handleError(
        process: () async {
          await _sendPushNotification(
            type: PushNotificationType.call,
            sender: sender,
            recipients: receivers,
            content: PushNotificationContent(
              title: callerName,
              body: "着信が来ました。",
            ),
            payload: PushNotificationPayload(
              callId: callId,
              callType: 'voice',
            ),
            metadata: PushNotificationMetadata(
              priority: 'high',
              category: 'callCategory',
            ),
          );
        },
        successMessage: '通話通知を送信しました',
        errorHandler: (e) {
          if (e is NotificationException) {
            return e.message;
          }
          return 'エラーが発生しました';
        },
      );
    } else {
      await _sendPushNotification(
        type: PushNotificationType.call,
        sender: sender,
        recipients: receivers,
        content: PushNotificationContent(
          title: callerName,
          body: "着信が来ました。",
        ),
        payload: PushNotificationPayload(
          callId: callId,
          callType: 'voice',
        ),
        metadata: PushNotificationMetadata(
          priority: 'high',
          category: 'callCategory',
        ),
      );
    }
  }

  // ★ 改修: マルチキャスト通知 (マルチデバイス対応)
  Future<void> sendMulticast(
      List<UserAccount> users, String title, String body) async {
    final recipients =
        users.expand((user) => _generateReceivers(user)).toList();

    if (recipients.isEmpty) return;

    await _sendPushNotification(
      type: PushNotificationType.defaultType,
      sender: _generateSender(),
      recipients: recipients,
      content: PushNotificationContent(
        title: title,
        body: body,
      ),
    );
  }

  // ★ チャットリクエスト送信通知 (マルチデバイス対応)
  // 送信者名を隠すことで、受信者の好奇心を刺激する戦略
  Future<void> sendChatRequest(UserAccount user, String? message) async {
    final sender = _generateSender();
    final receivers = _generateReceivers(user);

    if (receivers.isEmpty) return;

    // メッセージの有無で通知内容を変える
    final hasMessage = message?.isNotEmpty == true;

    await _sendPushNotification(
      type: PushNotificationType.chatRequest,
      sender: sender,
      recipients: receivers,
      content: PushNotificationContent(
        title: hasMessage ? "チャットリクエストが来ました。" : "BLANK", // アプリ名
        body: hasMessage ? message! : "チャットリクエストが来ました。確認しましょう。",
      ),
      payload: PushNotificationPayload(
        text: message,
      ),
    );
  }

  // ★ チャットリクエスト承認通知 (マルチデバイス対応)
  Future<void> sendChatRequestAccepted(UserAccount user) async {
    final sender = _generateSender();
    final receivers = _generateReceivers(user);

    if (receivers.isEmpty) return;

    await _sendPushNotification(
      type: PushNotificationType.chatRequestAccepted,
      sender: sender,
      recipients: receivers,
      content: PushNotificationContent(
        title: sender.name,
        body: "チャットリクエストが承認されました。",
      ),
    );
  }
}
