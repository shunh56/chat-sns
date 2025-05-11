import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_funcrtions.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationDatasourceProvider = Provider(
  (ref) => PushNotificationDatasource(
    ref.watch(authProvider),
    ref.watch(httpsCallableProvider),
  ),
);

class NotificationException implements Exception {
  final String message;
  final String? code;

  NotificationException(this.message, {this.code});

  @override
  String toString() =>
      'NotificationException: $message${code != null ? ' (Code: $code)' : ''}';
}

class PushNotificationDatasource {
  final FirebaseAuth _auth;
  final HttpsCallables _callables;

  PushNotificationDatasource(this._auth, this._callables);

  Future<void> sendPushNotification(
      Map<String, dynamic> notificationData) async {
    try {
      final HttpsCallable callable = _callables.pushNotification;
      final results = await callable.call<Map<String, dynamic>>(
          {'notification': notificationData}
          /*{
        'fcmToken': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
      }
      */
          );

      if (results.data['error'] != null) {
        throw NotificationException(
          results.data['error']['message'] ?? '通知の送信に失敗しました',
          code: results.data['error']['code'],
        );
      }
    } on FirebaseFunctionsException catch (e) {
      _handleFunctionException(e);
    } catch (e) {
      throw NotificationException('予期せぬエラーが発生しました: ${e.toString()}');
    }
  }

  void _handleFunctionException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'not-found':
        throw NotificationException('Cloud Function関数が見つかりません', code: e.code);
      case 'permission-denied':
        throw NotificationException('通知の送信権限がありません', code: e.code);
      case 'invalid-argument':
        throw NotificationException('無効なパラメータです', code: e.code);
      default:
        throw NotificationException('通知の送信に失敗しました: ${e.message}', code: e.code);
    }
  }

  Future<void> sendCallNotification(
    String? fcmToken,
    // String title,
    //String body,
    String myName,
    String? imageUrl,
  ) async {
    try {
      final HttpsCallable callable = _callables.callNotification();

      if (fcmToken == null) {
        throw NotificationException('FCMトークンが無効です');
      }

      final results = await callable.call<Map<String, dynamic>>({
        'fcmToken': fcmToken,
        'data': {
          'userId': _auth.currentUser!.uid,
          'name': myName,
          'imageUrl': imageUrl,
          'dateTime': DateTime.now().toIso8601String(),
          'type': 'call',
        },
      });

      if (results.data['error'] != null) {
        throw NotificationException(
          results.data['error']['message'] ?? '通知の送信に失敗しました',
          code: results.data['error']['code'],
        );
      }
    } on FirebaseFunctionsException catch (e) {
      switch (e.code) {
        case 'not-found':
          throw NotificationException('FCMトークンが見つかりません', code: e.code);
        case 'permission-denied':
          throw NotificationException('通知の送信権限がありません', code: e.code);
        case 'invalid-argument':
          throw NotificationException('無効なパラメータです', code: e.code);
        default:
          throw NotificationException('通知の送信に失敗しました: ${e.message}',
              code: e.code);
      }
    } catch (e) {
      throw NotificationException('予期せぬエラーが発生しました: ${e.toString()}');
    }
  }

/*  Future<void> sendMultiNotification(
      List<String> fcmTokens, String title, String body) async {
    fcmTokens = fcmTokens.toSet().toList();
    try {
      final HttpsCallable callable = _callables.pushNotificationMulticast();

      final results = await callable.call({
        'fcmTokens': fcmTokens,
        'notification': {
          'title': title,
          'body': body,
        },
      });
      DebugPrint('Notification sent successfully: ${results.data}');
    } catch (e) {
      DebugPrint('Error sending notification: $e');
    }
  } */
}
