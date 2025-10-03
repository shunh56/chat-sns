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

  // ユーザーアカウントからレシーバーを生成するヘルパーメソッド
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

  // フォロー通知
  Future<void> sendFollow(UserAccount user) async {
    final sender = _generateSender();
    await _sendPushNotification(
      type: PushNotificationType.follow,
      sender: sender,
      receiver: _generateReceiver(user),
      content: PushNotificationContent(
        title: sender.name,
        body: "あなたをフォローしました。",
      ),
    );
  }

  // いいね通知
  Future<void> sendPostReaction(UserAccount user) async {
    final sender = _generateSender();
    await _sendPushNotification(
      type: PushNotificationType.like,
      sender: sender,
      receiver: _generateReceiver(user),
      content: PushNotificationContent(
        title: sender.name,
        body: "あなたの投稿に反応しました。",
      ),
    );
  }

  // コメント通知
  Future<void> sendPostComment(UserAccount user) async {
    final sender = _generateSender();
    await _sendPushNotification(
      type: PushNotificationType.comment,
      sender: sender,
      receiver: _generateReceiver(user),
      content: PushNotificationContent(
        title: sender.name,
        body: "あなたの投稿にコメントしました。",
      ),
    );
  }

  // DM通知
  Future<void> sendDm(
    UserAccount user,
    String message,
  ) async {
    final sender = _generateSender();
    await _sendPushNotification(
      type: PushNotificationType.dm,
      sender: sender,
      receiver: _generateReceiver(user),
      content: PushNotificationContent(
        title: sender.name,
        body: message,
      ),
      payload: PushNotificationPayload(
        text: message,
      ),
    );
  }

  // 通話通知
  sendCallNotification(UserAccount user) async {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    if (Flavor.isDevEnv) {
      await handleError(
        process: () async {
          await _repository.sendCallNotification(user, me);
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
      await _repository.sendCallNotification(user, me);
    }
  }

  /*
  Future<void> sendCallNotification(UserAccount user) async {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    if (flavor == "dev") {
      await handleError(
        process: () async {
          final sender = _generateSender();
          await _sendPushNotification(
            type: PushNotificationType.call,
            sender: sender,
            receiver: _generateReceiver(user),
            content: PushNotificationContent(
              title: sender.name,
              body: "着信が来ました。",
            ),
            metadata: PushNotificationMetadata(
              priority: 'high',
              category: 'callCategory',
            ),
          );
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
      final sender = _generateSender();
      await _sendPushNotification(
        type: PushNotificationType.call,
        sender: sender,
        receiver: _generateReceiver(user),
        content: PushNotificationContent(
          title: sender.name,
          body: "着信が来ました。",
        ),
        metadata: PushNotificationMetadata(
          priority: 'high',
          category: 'callCategory',
        ),
      );
    }
  }

  */
  // マルチキャスト通知
  Future<void> sendMulticast(
      List<UserAccount> users, String title, String body) async {
    final recipients = users
        .where((user) => user.fcmToken != null)
        .map(_generateReceiver)
        .toList();

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
}
