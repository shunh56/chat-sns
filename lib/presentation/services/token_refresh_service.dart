import 'dart:io';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/domain/usecases/device_management_usecase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenRefreshServiceProvider = Provider((ref) => TokenRefreshService(ref));

/// FCM トークンリフレッシュを監視し、デバイス情報を自動更新するサービス
class TokenRefreshService {
  final Ref _ref;

  TokenRefreshService(this._ref);

  /// トークンリフレッシュリスナーを初期化
  void initialize() {
    // FCM トークンリフレッシュを監視
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
    if (kDebugMode) {
      print('[TokenRefresh] Listener initialized');
    }
  }

  /// トークンがリフレッシュされた時の処理
  Future<void> _onTokenRefresh(String newToken) async {
    if (kDebugMode) {
      print('[TokenRefresh] FCM token refreshed: $newToken');
    }

    try {
      // VoIP トークンも取得 (iOS のみ)
      String? voipToken;
      if (Platform.isIOS) {
        voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
        if (kDebugMode) {
          print('[TokenRefresh] VoIP token: $voipToken');
        }
      }

      // デバイス情報を更新
      await _updateDeviceTokens(
        fcmToken: newToken,
        voipToken: voipToken,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[TokenRefresh] Error in onTokenRefresh: $e');
      }
    }
  }

  /// デバイストークンを更新
  Future<void> _updateDeviceTokens({
    required String? fcmToken,
    required String? voipToken,
  }) async {
    try {
      // 認証状態を確認
      final currentUser = _ref.read(authProvider).currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print('[TokenRefresh] No authenticated user, skipping token update');
        }
        return;
      }

      final userId = currentUser.uid;

      // ★ DeviceManagementUsecase 経由で更新 (クリーンアーキテクチャ準拠)
      final deviceManagementUsecase = _ref.read(deviceManagementUsecaseProvider);
      await deviceManagementUsecase.updateDeviceTokens(
        userId: userId,
        fcmToken: fcmToken,
        voipToken: voipToken,
      );

      if (kDebugMode) {
        print('[TokenRefresh] Device tokens updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TokenRefresh] Failed to update device tokens: $e');
      }
    }
  }
}
