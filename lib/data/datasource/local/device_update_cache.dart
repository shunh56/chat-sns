import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final deviceUpdateCacheProvider = Provider(
  (ref) => DeviceUpdateCache(),
);

/// デバイス更新のローカルキャッシュ
/// lastActiveAt の更新頻度を制限するために使用
/// Firestore への Write 回数を削減する
class DeviceUpdateCache {
  static const String _boxName = 'device_update_cache';
  static const String _lastUpdatePrefix = 'last_update_';
  static const String _deviceIdKey = 'current_device_id';

  Box? _box;

  /// Hive Box を開く
  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  /// 最終更新時刻を取得
  Future<DateTime?> getLastUpdateTime(String deviceId) async {
    try {
      final box = await _getBox();
      final timestamp = box.get('$_lastUpdatePrefix$deviceId');
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    } catch (e) {
      return null;
    }
  }

  /// 最終更新時刻を保存
  Future<void> saveLastUpdateTime(String deviceId, DateTime time) async {
    try {
      final box = await _getBox();
      await box.put(
        '$_lastUpdatePrefix$deviceId',
        time.millisecondsSinceEpoch,
      );
    } catch (e) {
      // エラーが発生しても処理を継続 (キャッシュは必須ではない)
    }
  }

  /// 更新が必要かチェック
  /// 前回の更新から指定時間以上経過している場合は true を返す
  Future<bool> shouldUpdate(
    String deviceId, {
    Duration interval = const Duration(hours: 1),
  }) async {
    final lastUpdate = await getLastUpdateTime(deviceId);
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final elapsed = now.difference(lastUpdate);

    return elapsed >= interval;
  }

  /// 現在のデバイスIDを保存
  Future<void> saveCurrentDeviceId(String deviceId) async {
    try {
      final box = await _getBox();
      await box.put(_deviceIdKey, deviceId);
    } catch (e) {
      // エラーが発生しても処理を継続
    }
  }

  /// 現在のデバイスIDを取得
  Future<String?> getCurrentDeviceId() async {
    try {
      final box = await _getBox();
      return box.get(_deviceIdKey) as String?;
    } catch (e) {
      return null;
    }
  }

  /// 特定のデバイスのキャッシュをクリア
  Future<void> clearDeviceCache(String deviceId) async {
    try {
      final box = await _getBox();
      await box.delete('$_lastUpdatePrefix$deviceId');
    } catch (e) {
      // エラーが発生しても処理を継続
    }
  }

  /// 全てのキャッシュをクリア
  Future<void> clearAll() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {
      // エラーが発生しても処理を継続
    }
  }

  /// Box を閉じる
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}
