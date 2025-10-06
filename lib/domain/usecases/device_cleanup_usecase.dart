import 'package:app/data/datasource/firebase/firebase_funcrtions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceCleanupUsecaseProvider = Provider(
  (ref) => DeviceCleanupUsecase(
    ref.watch(httpsCallableProvider),
  ),
);

/// デバイスクリーンアップのユースケース
/// Firebase Functions の cleanup 関数を呼び出す
class DeviceCleanupUsecase {
  final HttpsCallables _callables;

  DeviceCleanupUsecase(this._callables);

  /// 自分のデバイスをクリーンアップ
  /// [daysInactive] 日数以上非アクティブなデバイスを削除
  /// デフォルト: 30日
  Future<DeviceCleanupResult> cleanupMyDevices({
    int daysInactive = 30,
  }) async {
    try {
      final callable = _callables.deviceCleanup('cleanupMyDevices');
      final result = await callable.call<Map<String, dynamic>>({
        'daysInactive': daysInactive,
      });

      final data = result.data;
      return DeviceCleanupResult(
        success: data['success'] ?? false,
        deletedDevices: data['deletedDevices'] ?? 0,
        daysInactive: data['daysInactive'] ?? daysInactive,
      );
    } catch (e) {
      throw DeviceCleanupException('デバイスのクリーンアップに失敗しました: $e');
    }
  }

  /// 手動で全ユーザーのデバイスをクリーンアップ (管理者専用)
  /// [daysInactive] 日数以上非アクティブなデバイスを削除
  /// デフォルト: 30日
  Future<AdminDeviceCleanupResult> manualCleanupAllDevices({
    int daysInactive = 30,
  }) async {
    try {
      final callable = _callables.deviceCleanup('manualCleanupDevices');
      final result = await callable.call<Map<String, dynamic>>({
        'daysInactive': daysInactive,
      });

      final data = result.data;
      return AdminDeviceCleanupResult(
        success: data['success'] ?? false,
        processedUsers: data['processedUsers'] ?? 0,
        deletedDevices: data['deletedDevices'] ?? 0,
        errors: data['errors'] ?? 0,
        daysInactive: data['daysInactive'] ?? daysInactive,
      );
    } catch (e) {
      throw DeviceCleanupException('デバイスのクリーンアップに失敗しました: $e');
    }
  }
}

/// デバイスクリーンアップの結果 (ユーザー用)
class DeviceCleanupResult {
  final bool success;
  final int deletedDevices;
  final int daysInactive;

  DeviceCleanupResult({
    required this.success,
    required this.deletedDevices,
    required this.daysInactive,
  });

  @override
  String toString() {
    return 'DeviceCleanupResult(success: $success, deletedDevices: $deletedDevices, daysInactive: $daysInactive)';
  }
}

/// デバイスクリーンアップの結果 (管理者用)
class AdminDeviceCleanupResult {
  final bool success;
  final int processedUsers;
  final int deletedDevices;
  final int errors;
  final int daysInactive;

  AdminDeviceCleanupResult({
    required this.success,
    required this.processedUsers,
    required this.deletedDevices,
    required this.errors,
    required this.daysInactive,
  });

  @override
  String toString() {
    return 'AdminDeviceCleanupResult(success: $success, processedUsers: $processedUsers, deletedDevices: $deletedDevices, errors: $errors, daysInactive: $daysInactive)';
  }
}

/// デバイスクリーンアップの例外
class DeviceCleanupException implements Exception {
  final String message;

  DeviceCleanupException(this.message);

  @override
  String toString() => 'DeviceCleanupException: $message';
}
