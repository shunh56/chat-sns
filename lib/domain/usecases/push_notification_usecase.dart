import 'package:app/core/values.dart';
import 'package:app/data/datasource/push_notification_datasource.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/main.dart';
import 'package:app/presentation/components/core/toast.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
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

  sendFollow(UserAccount user) {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    _sendPushNotification(user, me.name, "あなたをフォローしました。");
  }

  sendPostLike(UserAccount user) {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    _sendPushNotification(user, me.name, "あなたの投稿にいいねしました。");
  }

  sendPostComment(UserAccount user) {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    _sendPushNotification(user, me.name, "あなたの投稿にコメントしました。");
  }

  sendDm(
    UserAccount user,
    String? title,
    String body,
  ) async {
    final titleText = title ?? appName;
    _sendPushNotification(user, titleText, body);
  }

  sendCallNotification(UserAccount user) async {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    if (flavor == "dev") {
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

  _sendPushNotification(UserAccount user, String title, String body) async {
    if (flavor == "dev") {
      await handleError(
        process: () async {
          if (title.isEmpty || body.isEmpty) {
            throw NotificationException('タイトルまたは本文が空です');
          }
          await _repository.sendPushNotification(user.fcmToken!, title, body);
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
      await _repository.sendPushNotification(user.fcmToken!, title, body);
    }
  }

  sendmulticast(List<String> fcmTokens, String title, String body) {
    _repository.sendmulticast(fcmTokens, title, body);
  }
}
