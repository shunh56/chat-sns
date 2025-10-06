import 'package:app/domain/entity/device/device_platform.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// アクティブデバイスの軽量サマリー
/// users ドキュメントの activeDevices 配列に保存され、通知送信時のキャッシュとして使用される
/// これにより devices サブコレクションを読み取る必要がなくなり、Read 課金を削減できる
class ActiveDeviceSummary {
  final String deviceId;
  final DevicePlatform platform;
  final String? fcmToken;
  final String? voipToken;
  final Timestamp lastActiveAt;

  ActiveDeviceSummary({
    required this.deviceId,
    required this.platform,
    this.fcmToken,
    this.voipToken,
    required this.lastActiveAt,
  });

  factory ActiveDeviceSummary.fromJson(Map<String, dynamic> json) {
    return ActiveDeviceSummary(
      deviceId: json['deviceId'] ?? '',
      platform: DevicePlatform.fromString(json['platform'] ?? 'android'),
      fcmToken: json['fcmToken'],
      voipToken: json['voipToken'],
      lastActiveAt: json['lastActiveAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'platform': platform.toFirestore(),
      'fcmToken': fcmToken,
      'voipToken': voipToken,
      'lastActiveAt': lastActiveAt,
    };
  }

  /// 通知を受信可能かどうか
  bool get canReceiveNotification => fcmToken != null || voipToken != null;

  /// iOS デバイスかどうか
  bool get isIOS => platform.isIOS;

  /// Android デバイスかどうか
  bool get isAndroid => platform.isAndroid;

  /// VoIP 通知が利用可能かどうか (iOS のみ)
  bool get canUseVoip => isIOS && voipToken != null;

  ActiveDeviceSummary copyWith({
    String? deviceId,
    DevicePlatform? platform,
    String? fcmToken,
    String? voipToken,
    Timestamp? lastActiveAt,
  }) {
    return ActiveDeviceSummary(
      deviceId: deviceId ?? this.deviceId,
      platform: platform ?? this.platform,
      fcmToken: fcmToken ?? this.fcmToken,
      voipToken: voipToken ?? this.voipToken,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
