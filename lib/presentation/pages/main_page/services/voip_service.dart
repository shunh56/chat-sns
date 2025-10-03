import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/variables.dart';
import '../../../components/core/snackbar.dart';

/// VoIP処理サービス
final voipServiceProvider = Provider<VoIPService>((ref) {
  return VoIPService();
});

/// VoIP通話管理サービス
class VoIPService {
  static const _platform = MethodChannel('com.blank.sns/voip');

  /// VoIPサービスの初期化
  void initialize() {
    _setupVoIPListener();
    _configureCallKitIncoming();
  }

  /// VoIPリスナーの設定
  void _setupVoIPListener() {
    _platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == "onVoIPReceived") {
        // VoIP通話受信時の処理
        await _handleVoIPReceived(call.arguments);
      }
    });
  }

  /// VoIP通話受信処理
  Future<void> _handleVoIPReceived(dynamic arguments) async {
    // 現在は実装されていないため、将来の拡張用に残す
    // final Map<String, dynamic> args = Map<String, dynamic>.from(arguments);
    // final id = args['extra']['id'] ?? "";
    // final uuid = args['uuid'];

    // TODO: VoIP通話画面への遷移処理を実装
  }

  /// CallKit Incomingの設定
  void _configureCallKitIncoming() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;

      switch (event.event) {
        case Event.actionCallIncoming:
          await _handleCallIncoming(event);
          break;
        case Event.actionCallStart:
          await _handleCallStart(event);
          break;
        case Event.actionCallAccept:
          await _handleCallAccept(event);
          break;
        case Event.actionCallDecline:
          await _handleCallDecline(event);
          break;
        case Event.actionCallEnded:
          await _handleCallEnded(event);
          break;
        case Event.actionCallTimeout:
          await _handleCallTimeout(event);
          break;
        case Event.actionCallCallback:
          await _handleCallCallback(event);
          break;
        default:
          // その他のイベントは無視
          break;
      }
    });
  }

  /// 着信処理
  Future<void> _handleCallIncoming(CallEvent event) async {
    // TODO: 着信時の処理を実装
  }

  /// 発信開始処理
  Future<void> _handleCallStart(CallEvent event) async {
    // TODO: 発信開始時の処理を実装
  }

  /// 通話受諾処理
  Future<void> _handleCallAccept(CallEvent event) async {
    final callId = event.body['id'] as String?;
    final extraCallId = event.body['extra']?['id'] as String?;

    if (callId != null) {
      showMessage("通話ID: $callId\\n通話が受諾されました: $extraCallId");
      await FlutterCallkitIncoming.endCall(callId);

      // 少し待ってから通話画面に遷移
      await Future.delayed(const Duration(milliseconds: 30));

      if (extraCallId != null && navigatorKey.currentState != null) {
        // TODO: 通話画面への遷移を実装
        // navigatorKey.currentState!.push(
        //   MaterialPageRoute(
        //     builder: (_) => VoiceChatScreen(
        //       id: extraCallId,
        //       uuid: callId,
        //     ),
        //   ),
        // );
      }
    }
  }

  /// 通話拒否処理
  Future<void> _handleCallDecline(CallEvent event) async {
    final callId = event.body['id'] as String?;
    if (callId != null) {
      await FlutterCallkitIncoming.endCall(callId);
    }
  }

  /// 通話終了処理
  Future<void> _handleCallEnded(CallEvent event) async {
    final callId = event.body['id'] as String?;
    if (callId != null) {
      await FlutterCallkitIncoming.endCall(callId);
    }
  }

  /// 通話タイムアウト処理
  Future<void> _handleCallTimeout(CallEvent event) async {
    final callId = event.body['id'] as String?;
    if (callId != null) {
      await FlutterCallkitIncoming.endCall(callId);
    }
  }

  /// コールバック処理（Android専用）
  Future<void> _handleCallCallback(CallEvent event) async {
    // TODO: コールバック時の処理を実装
  }
}