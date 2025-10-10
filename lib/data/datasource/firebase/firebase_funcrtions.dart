import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final functionsProvider = Provider(
  (ref) => FirebaseFunctions.instanceFor(region: "asia-northeast1"),
);

final httpsCallableProvider = Provider(
  (ref) => HttpsCallables(
    ref.watch(functionsProvider),
  ),
);

class HttpsCallables {
  final FirebaseFunctions _functions;
  HttpsCallables(this._functions);

  HttpsCallable agoraTokenGenerator() {
    return _functions.httpsCallable('agora-generateAgoraToken');
  }

  HttpsCallable get pushNotification =>
      _functions.httpsCallable('pushNotification-sendPushNotificationV2');

  HttpsCallable pushNotificationMulticast() {
    return _functions.httpsCallable('pushNotification-sendMulticast');
  }

  HttpsCallable callNotification() {
    return _functions.httpsCallable('pushNotification-sendCallNotification');
  }

  HttpsCallable voip() {
    return _functions.httpsCallable('voip-send');
  }

  /// デバイスクリーンアップ関数
  /// [functionName] には 'cleanupMyDevices' または 'manualCleanupDevices' を指定
  HttpsCallable deviceCleanup(String functionName) {
    return _functions.httpsCallable('deviceCleanup-$functionName');
  }
}
