import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/data/datasource/firebase/firebase_funcrtions.dart';
import 'package:app/presentation/providers/shared/users/my_user_account_notifier.dart';
import 'package:app/domain/usecases/push_notification_usecase.dart';
import 'package:app/domain/usecases/voice_chat_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voipUsecaseProvider = Provider(
  (ref) => VoipUsecase(
    ref,
    ref.watch(pushNotificationUsecaseProvider),
  ),
);

class VoipUsecase {
  final Ref _ref;
  final PushNotificationUsecase _pushNotificationUsecase;

  VoipUsecase(this._ref, this._pushNotificationUsecase);
  callUser(UserAccount user) async {
    final voipCallable = _ref.read(httpsCallableProvider).voip();
    final me = _ref.read(myAccountNotifierProvider).asData!.value;
    final voipToken = user.voipToken;
    final fcmToken = user.fcmToken;
    final vc =
        await _ref.read(voiceChatUsecaseProvider).createVoiceChat("VOICE CALL");
    if (voipToken != null) {
      try {
        final result = await voipCallable.call({
          'tokens': [voipToken],
          'name': me.name,
          'id': vc.id,
        });

        DebugPrint("response : ${result.data}");
      } catch (e) {
        showMessage("voip notification error : $e");
        DebugPrint("error : $e");
      }
    } else {
      if (fcmToken != null) {
        await _pushNotificationUsecase.sendCallNotification(user);
      }
    }
    return vc;
  }
}
