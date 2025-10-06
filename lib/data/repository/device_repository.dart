import 'package:app/data/datasource/device_datasource.dart';
import 'package:app/domain/entity/device/active_device_summary.dart';
import 'package:app/domain/entity/device/device_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceRepositoryProvider = Provider(
  (ref) => DeviceRepository(
    ref.watch(deviceDatasourceProvider),
  ),
);

class DeviceRepository {
  final DeviceDatasource _datasource;

  DeviceRepository(this._datasource);

  /// デバイス情報を登録または更新
  /// devices サブコレクションとユーザードキュメントの activeDevices キャッシュを両方更新
  Future<void> registerOrUpdateDevice(
    String userId,
    DeviceInfoEntity deviceInfo,
  ) async {
    // 1. devices サブコレクションにデバイス情報を保存
    await _datasource.setDevice(
      userId,
      deviceInfo.deviceId,
      deviceInfo.toJson(),
    );

    // 2. アクティブなデバイスを取得してユーザードキュメントのキャッシュを更新
    await _updateActiveDevicesCache(userId);
  }

  /// アクティブなデバイスキャッシュを更新
  /// devices サブコレクションからアクティブなデバイスを取得し、
  /// ユーザードキュメントの activeDevices フィールドを更新する
  Future<void> _updateActiveDevicesCache(String userId) async {
    final snapshot = await _datasource.getActiveDevices(userId);

    final activeSummaries = snapshot.docs
        .map((doc) => DeviceInfoEntity.fromJson(doc.id, doc.data()).toSummary())
        .toList();

    await _datasource.updateUserActiveDevices(
      userId,
      activeSummaries.map((s) => s.toJson()).toList(),
    );
  }

  /// ユーザーの全デバイスを取得
  Future<List<DeviceInfoEntity>> getUserDevices(String userId) async {
    final snapshot = await _datasource.getUserDevices(userId);

    return snapshot.docs
        .map((doc) => DeviceInfoEntity.fromJson(doc.id, doc.data()))
        .toList();
  }

  /// アクティブなデバイスのみ取得
  Future<List<DeviceInfoEntity>> getActiveDevices(String userId) async {
    final snapshot = await _datasource.getActiveDevices(userId);

    return snapshot.docs
        .map((doc) => DeviceInfoEntity.fromJson(doc.id, doc.data()))
        .toList();
  }

  /// 特定のデバイス情報を取得
  Future<DeviceInfoEntity?> getDevice(String userId, String deviceId) async {
    final doc = await _datasource.getDevice(userId, deviceId);

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return DeviceInfoEntity.fromJson(doc.id, doc.data()!);
  }

  /// デバイスのトークンを更新
  Future<void> updateDeviceTokens({
    required String userId,
    required String deviceId,
    String? fcmToken,
    String? voipToken,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fcmToken != null) {
      updates['fcmToken'] = fcmToken;
    }
    if (voipToken != null) {
      updates['voipToken'] = voipToken;
    }

    await _datasource.updateDevice(userId, deviceId, updates);

    // キャッシュを更新
    await _updateActiveDevicesCache(userId);
  }

  /// デバイスの最終アクティブ日時を更新
  /// 頻繁な更新を避けるため、呼び出し側でキャッシュチェックを行うこと推奨
  Future<void> updateDeviceLastActive(
    String userId,
    String deviceId,
  ) async {
    await _datasource.updateDevice(userId, deviceId, {
      'lastActiveAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 注意: キャッシュ更新はスキップ (頻繁な更新を避けるため)
    // 必要に応じて呼び出し側で _updateActiveDevicesCache を呼び出す
  }

  /// デバイスを無効化
  Future<void> deactivateDevice(String userId, String deviceId) async {
    await _datasource.updateDevice(userId, deviceId, {
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // キャッシュを更新 (非アクティブデバイスをキャッシュから削除)
    await _updateActiveDevicesCache(userId);
  }

  /// デバイスを削除
  Future<void> deleteDevice(String userId, String deviceId) async {
    await _datasource.deleteDevice(userId, deviceId);

    // キャッシュを更新
    await _updateActiveDevicesCache(userId);
  }

  /// 古いデバイスをクリーンアップ
  /// 指定期間以上非アクティブなデバイスを削除
  Future<int> cleanupInactiveDevices(
    String userId, {
    Duration inactiveDuration = const Duration(days: 30),
  }) async {
    // 非アクティブなデバイスIDを取得
    final inactiveDeviceIds = await _datasource.getInactiveDeviceIds(
      userId,
      inactiveDuration,
    );

    if (inactiveDeviceIds.isEmpty) {
      return 0;
    }

    // バッチ削除
    await _datasource.batchDeleteDevices(userId, inactiveDeviceIds);

    // キャッシュを更新
    await _updateActiveDevicesCache(userId);

    return inactiveDeviceIds.length;
  }

  /// アクティブデバイスのサマリーリストを取得 (キャッシュ更新用)
  /// 通常は UserAccount.activeDevices を使用するため、このメソッドは内部用
  Future<List<ActiveDeviceSummary>> getActiveDeviceSummaries(
    String userId,
  ) async {
    final snapshot = await _datasource.getActiveDevices(userId);

    return snapshot.docs
        .map((doc) => DeviceInfoEntity.fromJson(doc.id, doc.data()).toSummary())
        .toList();
  }
}
