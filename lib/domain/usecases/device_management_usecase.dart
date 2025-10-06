import 'dart:io';
import 'package:app/core/utils/device_id_generator.dart';
import 'package:app/data/datasource/local/device_update_cache.dart';
import 'package:app/data/repository/device_repository.dart';
import 'package:app/domain/entity/device/device_details.dart';
import 'package:app/domain/entity/device/device_info.dart';
import 'package:app/domain/entity/device/device_platform.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final deviceManagementUsecaseProvider = Provider(
  (ref) => DeviceManagementUsecase(
    ref.watch(deviceRepositoryProvider),
    ref.watch(deviceIdGeneratorProvider),
    ref.watch(deviceUpdateCacheProvider),
  ),
);

/// デバイス管理のユースケース
/// Presentation層とData層の間の橋渡しを行う
class DeviceManagementUsecase {
  final DeviceRepository _deviceRepository;
  final DeviceIdGenerator _deviceIdGenerator;
  final DeviceUpdateCache _cache;

  DeviceManagementUsecase(
    this._deviceRepository,
    this._deviceIdGenerator,
    this._cache,
  );

  /// デバイス登録 (初回またはトークン変更時のみ)
  /// トークンが変更されていない場合は lastActiveAt のみ更新
  ///
  /// 戻り値: (デバイスが更新されたか, 新しいFCMトークン, 新しいVoIPトークン)
  Future<DeviceRegistrationResult> registerDeviceIfNeeded(
    String userId,
  ) async {
    try {
      // 1. デバイスIDを取得
      final deviceId = await _deviceIdGenerator.generateDeviceId();

      // 2. 既存デバイスをチェック
      final existingDevice = await _deviceRepository.getDevice(userId, deviceId);

      // 3. トークンを取得
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final voipToken = Platform.isIOS
          ? await FlutterCallkitIncoming.getDevicePushTokenVoIP()
          : null;

      // 4. トークンが変更されたかチェック
      final tokensChanged = existingDevice == null ||
          existingDevice.fcmToken != fcmToken ||
          existingDevice.voipToken != voipToken;

      if (tokensChanged) {
        // トークンが変更された場合のみ完全な更新
        await _registerOrUpdateDevice(userId, deviceId, fcmToken, voipToken);

        return DeviceRegistrationResult(
          deviceUpdated: true,
          fcmToken: fcmToken,
          voipToken: voipToken,
        );
      } else {
        // トークンが同じ場合は lastActiveAt のみ更新 (キャッシュチェック付き)
        final shouldUpdate = await _cache.shouldUpdate(
          deviceId,
          interval: const Duration(hours: 1),
        );

        if (shouldUpdate) {
          await _deviceRepository.updateDeviceLastActive(userId, deviceId);
          await _cache.saveLastUpdateTime(deviceId, DateTime.now());
        }

        return DeviceRegistrationResult(
          deviceUpdated: false,
          fcmToken: fcmToken,
          voipToken: voipToken,
        );
      }
    } catch (e) {
      throw DeviceManagementException('デバイス登録に失敗しました: $e');
    }
  }

  /// デバイス情報を登録または更新
  Future<void> _registerOrUpdateDevice(
    String userId,
    String deviceId,
    String? fcmToken,
    String? voipToken,
  ) async {
    // 1. キャッシュをチェック (頻繁な更新を避ける)
    final shouldUpdate = await _cache.shouldUpdate(
      deviceId,
      interval: const Duration(hours: 1),
    );

    if (!shouldUpdate) {
      // 1時間以内に更新済みの場合はスキップ
      return;
    }

    // 2. デバイス詳細情報を取得
    final packageInfo = await PackageInfo.fromPlatform();
    final details = DeviceDetails(
      device: await _getDeviceName(),
      osVersion: await _getOSVersion(),
      appVersion: packageInfo.version,
      appBuildNumber: packageInfo.buildNumber,
    );

    // 3. DeviceInfoEntity を作成
    final deviceInfo = DeviceInfoEntity(
      deviceId: deviceId,
      platform: Platform.isIOS ? DevicePlatform.ios : DevicePlatform.android,
      fcmToken: fcmToken,
      voipToken: voipToken,
      details: details,
      isActive: true,
      lastActiveAt: Timestamp.now(),
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    // 4. Firestore に保存
    await _deviceRepository.registerOrUpdateDevice(userId, deviceInfo);

    // 5. キャッシュを更新
    await _cache.saveLastUpdateTime(deviceId, DateTime.now());
    await _cache.saveCurrentDeviceId(deviceId);
  }

  /// デバイストークンを更新 (TokenRefreshService から呼ばれる)
  Future<void> updateDeviceTokens({
    required String userId,
    required String? fcmToken,
    required String? voipToken,
  }) async {
    final deviceId = await _deviceIdGenerator.generateDeviceId();

    await _deviceRepository.updateDeviceTokens(
      userId: userId,
      deviceId: deviceId,
      fcmToken: fcmToken,
      voipToken: voipToken,
    );
  }

  /// デバイス名を取得
  Future<String> _getDeviceName() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceIdGenerator.deviceInfoPlugin.iosInfo;
        return '${iosInfo.name} (${iosInfo.model})';
      } else if (Platform.isAndroid) {
        final androidInfo =
            await _deviceIdGenerator.deviceInfoPlugin.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// OS バージョンを取得
  Future<String> _getOSVersion() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceIdGenerator.deviceInfoPlugin.iosInfo;
        return iosInfo.systemVersion;
      } else if (Platform.isAndroid) {
        final androidInfo =
            await _deviceIdGenerator.deviceInfoPlugin.androidInfo;
        return 'Android ${androidInfo.version.release}';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
}

/// デバイス登録の結果
class DeviceRegistrationResult {
  final bool deviceUpdated;
  final String? fcmToken;
  final String? voipToken;

  DeviceRegistrationResult({
    required this.deviceUpdated,
    required this.fcmToken,
    required this.voipToken,
  });
}

/// デバイス管理の例外
class DeviceManagementException implements Exception {
  final String message;

  DeviceManagementException(this.message);

  @override
  String toString() => 'DeviceManagementException: $message';
}
