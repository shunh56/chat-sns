import 'package:app/core/utils/debug_print.dart';
import 'package:app/datasource/push_notification_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationRepositoryProvider = Provider(
  (ref) => PushNotificationRepository(
    ref.watch(pushNotificationDatasourceProvider),
  ),
);

class PushNotificationRepository {
  final PushNotificationDatasource _datasource;
  PushNotificationRepository(this._datasource);
  sendDm(String fcmToken, String title, String body) {
    _datasource.sendNotification(fcmToken, title, body);
  }

  sendReaction(String fcmToken, String title, String body) {
    DebugPrint("SENDING REACTION!!");
    _datasource.sendNotification(fcmToken, title, body);
  }

  sendCurrentStatusPost() {}
  sendPost() {}
  sendVoiceChat() {}
  sendFriendReqeust() {}

  sendmulticast(List<String> fcmTokens, String title, String body) {
    _datasource.sendMultiNotification(fcmTokens, title, body);
  }
}
