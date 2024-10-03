import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationNotifierProvider = Provider(
  (ref) => PushNotificationNotifier(ref),
);

class PushNotificationNotifier {
  final Ref ref;
  PushNotificationNotifier(this.ref);


  sendDm(){}
  sendCurrentStatusPost(){}
  sendPost(){}
  sendVoiceChat(){}
  sendFriendReqeust(){}
}
