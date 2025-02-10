import 'package:app/datasource/push_notification_datasource.dart';
import 'package:app/domain/entity/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationRepositoryProvider = Provider(
  (ref) => PushNotificationRepository(
    ref.watch(pushNotificationDatasourceProvider),
  ),
);

class PushNotificationRepository {
  final PushNotificationDatasource _datasource;
  PushNotificationRepository(this._datasource);

  sendCallNotification(
    UserAccount user,
    UserAccount me,
  ) async {
    try {
      await _datasource.sendCallNotification(
        user.fcmToken!,
        //  '${me.name}',
        //  '着信が来ました。',
        me.name,
        me.imageUrl,
      );
    } on NotificationException {
      rethrow;
    } catch (e) {
      throw NotificationException('通知の送信に失敗しました');
    }
  }

  sendPushNotification(String fcmToken, String title, String body) async {
    try {
      await _datasource.sendPushNotification(fcmToken, title, body);
    } on NotificationException {
      rethrow;
    } catch (e) {
      throw NotificationException('通知の送信に失敗しました');
    }
  }

  sendmulticast(List<String> fcmTokens, String title, String body) {
    _datasource.sendMultiNotification(fcmTokens, title, body);
  }
}
