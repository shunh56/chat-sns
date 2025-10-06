import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/flavor.dart';
import 'package:app/domain/entity/device/active_device_summary.dart';
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

/// ★ 改修: VoIP 通話のユースケース
/// マルチデバイス対応:
/// - iOS の VoIP トークンを持つデバイスには VoIP Push を送信
/// - Android デバイスまたは VoIP 非対応 iOS デバイスには FCM を送信
/// - ユーザーが複数デバイスでログインしている場合、全デバイスに通知を送信
class VoipUsecase {
  final Ref _ref;
  final PushNotificationUsecase _pushNotificationUsecase;

  VoipUsecase(this._ref, this._pushNotificationUsecase);

  /// ユーザーに通話をかける
  /// 返り値: 作成された VoiceChat インスタンス
  Future<dynamic> callUser(UserAccount user) async {
    final me = _ref.read(myAccountNotifierProvider).asData!.value;

    // 1. VoiceChat ルームを作成
    final vc =
        await _ref.read(voiceChatUsecaseProvider).createVoiceChat("VOICE CALL");

    // 2. ユーザーのアクティブデバイスを取得
    final activeDevices = user.activeDevices;

    if (activeDevices.isEmpty) {
      // フォールバック: 従来のフィールドを使用
      await _sendToLegacyFields(user, me.name, vc.id);
      return vc;
    }

    // 3. デバイスごとに適切な通知を送信
    await _sendNotificationsToDevices(
      activeDevices: activeDevices,
      callerName: me.name,
      callId: vc.id,
      receiverUser: user,
    );

    return vc;
  }

  /// アクティブデバイスに通知を送信
  Future<void> _sendNotificationsToDevices({
    required List<ActiveDeviceSummary> activeDevices,
    required String callerName,
    required String callId,
    required UserAccount receiverUser,
  }) async {
    // VoIP トークンを持つ iOS デバイス
    final voipDevices =
        activeDevices.where((device) => device.canUseVoip).toList();

    // FCM トークンのみを持つデバイス (Android または VoIP 非対応 iOS)
    final fcmDevices = activeDevices
        .where((device) => !device.canUseVoip && device.fcmToken != null)
        .toList();

    // VoIP 通知を送信 (iOS)
    if (voipDevices.isNotEmpty) {
      await _sendVoipNotifications(
        voipTokens: voipDevices.map((d) => d.voipToken!).toList(),
        callerName: callerName,
        callId: callId,
      );
    }

    // FCM 通知を送信 (Android または VoIP 非対応 iOS)
    if (fcmDevices.isNotEmpty) {
      await _pushNotificationUsecase.sendCallNotificationViaFCM(
        receiverUser,
        callId,
        callerName,
      );
    }
  }

  /// VoIP 通知を送信 (iOS のみ)
  Future<void> _sendVoipNotifications({
    required List<String> voipTokens,
    required String callerName,
    required String callId,
  }) async {
    if (voipTokens.isEmpty) return;

    final voipCallable = _ref.read(httpsCallableProvider).voip();

    try {
      final result = await voipCallable.call({
        'tokens': voipTokens,
        'name': callerName,
        'id': callId,
      });

      DebugPrint("VoIP notification sent: ${result.data}");
    } catch (e) {
      DebugPrint("VoIP notification error: $e");
      if (Flavor.isDevEnv) {
        showMessage("VoIP notification error: $e");
      }
    }
  }

  /// 従来のフィールドを使用して通知を送信 (後方互換性)
  Future<void> _sendToLegacyFields(
    UserAccount user,
    String callerName,
    String callId,
  ) async {
    final voipToken = user.voipToken;
    final fcmToken = user.fcmToken;

    if (voipToken != null) {
      // iOS VoIP 通知
      await _sendVoipNotifications(
        voipTokens: [voipToken],
        callerName: callerName,
        callId: callId,
      );
    } else if (fcmToken != null) {
      // FCM 通知
      await _pushNotificationUsecase.sendCallNotificationViaFCM(
        user,
        callId,
        callerName,
      );
    } else {
      DebugPrint("No tokens available for user: ${user.userId}");
      if (Flavor.isDevEnv) {
        showMessage("ユーザーのデバイストークンが見つかりません");
      }
    }
  }
}
