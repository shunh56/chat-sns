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

  HttpsCallable pushNotification() {
    return _functions.httpsCallable('pushNotification-sendPushNotification');
  }

  HttpsCallable pushNotificationMulticast() {
    return _functions.httpsCallable('pushNotification-sendMulticast');
  }

  HttpsCallable callNotification() {
    return _functions.httpsCallable('pushNotification-sendCallNotification');
  }

  HttpsCallable voip() {
    return _functions.httpsCallable('voip-send');
  }
}
