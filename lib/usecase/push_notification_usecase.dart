import 'package:app/core/values.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/repository/push_notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationUsecaseProvider = Provider(
  (ref) => PushNotificationUsecase(
    ref.watch(pushNotificationRepositoryProvider),
  ),
);

class PushNotificationUsecase {
  final PushNotificationRepository _repository;

  PushNotificationUsecase(this._repository);

  sendDm(
    UserAccount user,
    String? title,
    String body,
  ) {
    final titleText = title ?? appName;
    if (user.fcmToken != null) {
      _repository.sendDm(user.fcmToken!, titleText, body);
    }
  }

  sendCurrentStatusPost(List<UserAccount> users, String body) {
    return _repository.sendmulticast(
      users
          .where((user) => (user.fcmToken != null &&
              user.notificationData.currentStatusPost))
          .map((user) => user.fcmToken!)
          .toList(),
      appName,
      body,
    );
  }

  sendPost(List<UserAccount> users, String body) {
    return _repository.sendmulticast(
      users
          .where(
              (user) => (user.fcmToken != null && user.notificationData.post))
          .map((user) => user.fcmToken!)
          .toList(),
      appName,
      body,
    );
  }

  sendReaction(UserAccount user, String title, String body) {
    if (user.fcmToken != null) {
      _repository.sendReaction(user.fcmToken!, title, body);
    }
  }

  //sendVoiceChat() {}
  //sendFriendReqeust() {}

  /*sendmulticast(List<UserAccount> users, String? title, String body) {
    final titleText = title ?? appName;
    return _repository.sendmulticast(
      users
          .where((user) => user.fcmToken != null)
          .map((user) => user.fcmToken!)
          .toList(),
      titleText,
      body,
    );
  } */
}
