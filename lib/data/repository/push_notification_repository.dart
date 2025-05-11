import 'package:app/data/datasource/push_notification_datasource.dart';
import 'package:app/domain/entity/push_notification_model.dart';
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
        me.name,
        me.imageUrl,
      );
    } on NotificationException {
      rethrow;
    } catch (e) {
      throw NotificationException('通知の送信に失敗しました');
    }
  }

  sendPushNotification(PushNotificationModel model) async {
    try {
      await _datasource.sendPushNotification(model.toMap());
    } on NotificationException {
      rethrow;
    } catch (e) {
      throw NotificationException('通知の送信に失敗しました');
    }
  }
}
