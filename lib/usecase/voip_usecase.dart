import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/entity/voice_chat.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_funcrtions.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/voice_chat_usecase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voipUsecaseProvider =
    Provider((ref) => VoipUsecase(ref, ref.watch(functionsProvider)));

class VoipUsecase {
  final Ref _ref;
  final FirebaseFunctions _functions;
  VoipUsecase(this._ref, this._functions);
  callUser(UserAccount user) async {
    final fcmCallable = _functions.httpsCallable('pushNotification-sendCall');
    final voipCallable = _functions.httpsCallable('voip-send');
    final me = _ref.read(myAccountNotifierProvider).asData!.value;
    final voipToken = user.voipToken;
    final fcmToken = user.fcmToken;
    final vc =
        await _ref.read(voiceChatUsecaseProvider).createVoiceChat("VOICE CALL");
    if (voipToken != null) {
      try {
        DebugPrint("sending voip notification");
        final result = await voipCallable.call({
          'tokens': [voipToken],
          'name': me.name,
          'id': vc.id,
        });
        showMessage("voip response : ${result.data}");
        DebugPrint("response : ${result.data}");
      } catch (e) {
        showMessage("voip notification error : $e");
        DebugPrint("error : $e");
      }
    } else {
      if (fcmToken != null) {
        try {
          DebugPrint("sending fcm notification");
          final result = await fcmCallable.call({
            'token': fcmToken,
            'userId': me.userId,
            'name': me.name,
            'imageUrl': me.imageUrl,
            'dateTime': DateTime.now().toString(),
          });
          DebugPrint("response : ${result.data}");
        } catch (e) {
          DebugPrint("error : $e");
        }
      }
    }
    return vc;
  }
}
