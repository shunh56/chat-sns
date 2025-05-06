import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/firebase/firebase_funcrtions.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:app/domain/usecases/push_notification_usecase.dart';
import 'package:app/domain/usecases/voice_chat_usecase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voipUsecaseProvider = Provider(
  (ref) => VoipUsecase(
    ref,
    ref.watch(pushNotificationUsecaseProvider),
    ref.watch(functionsProvider),
  ),
);

class VoipUsecase {
  final Ref _ref;
  final PushNotificationUsecase _pushNotificationUsecase;
  final FirebaseFunctions _functions;

  VoipUsecase(this._ref, this._pushNotificationUsecase, this._functions);
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
