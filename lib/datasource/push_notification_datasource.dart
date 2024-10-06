import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_funcrtions.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationDatasourceProvider = Provider(
  (ref) => PushNotificationDatasource(
    ref.watch(functionsProvider),
  ),
);

class PushNotificationDatasource {
  final FirebaseFunctions _functions;

  PushNotificationDatasource(this._functions);
  /*sendDm() {}

  sendCurrentStatusPost() {}
  sendPost() {}
  sendVoiceChat() {}
  sendFriendReqeust() {} */

  Future<void> sendNotification(
      String fcmToken, String title, String body) async {
    try {
      DebugPrint("fcmToken : $fcmToken");
      final HttpsCallable callable =
          _functions.httpsCallable('pushNotification-sendNotification');
      final results = await callable.call<Map<String, dynamic>>({
        'fcmToken': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
      });
      print('Notification sent successfully: ${results.data}');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> sendMultiNotification(
      List<String> fcmTokens, String title, String body) async {
    fcmTokens = fcmTokens.toSet().toList();
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('pushNotification-sendMulticast');
      final results = await callable.call({
        'fcmTokens': fcmTokens,
        'notification': {
          'title': title,
          'body': body,
        },
      });
      print('Notification sent successfully: ${results.data}');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
