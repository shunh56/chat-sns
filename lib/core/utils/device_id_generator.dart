import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceIdGeneratorProvider = Provider(
  (ref) => DeviceIdGenerator(),
);

/// デバイスIDを生成するユーティリティ
/// デバイス固有の情報を組み合わせて一意なIDを生成する
class DeviceIdGenerator {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  /// デバイスIDを生成
  /// iOS: identifierForVendor を使用
  /// Android: androidId を使用
  Future<String> generateDeviceId() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        // identifierForVendor は同じベンダーのアプリ間で共通
        // アプリ削除→再インストールで変更される可能性がある
        return iosInfo.identifierForVendor ?? _generateFallbackId();
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        // androidId は端末固有のID
        return androidInfo.id;
      } else {
        return _generateFallbackId();
      }
    } catch (e) {
      return _generateFallbackId();
    }
  }

  /// フォールバックID生成 (デバイス情報取得に失敗した場合)
  String _generateFallbackId() {
    // タイムスタンプとランダム値を組み合わせた一意のID
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 100000;
    return 'fallback_${timestamp}_$random';
  }

  /// プラットフォーム名を取得
  String getPlatformName() {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    } else {
      return 'unknown';
    }
  }
}
