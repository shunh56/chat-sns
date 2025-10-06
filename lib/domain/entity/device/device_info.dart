import 'package:app/domain/entity/device/active_device_summary.dart';
import 'package:app/domain/entity/device/device_details.dart';
import 'package:app/domain/entity/device/device_platform.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// デバイス情報の完全なエンティティ
/// Firestore の users/{userId}/devices/{deviceId} ドキュメントとして保存される
///
/// 注意: これは既存の lib/domain/entity/user.dart の DeviceInfo (Hive typeId: 3) とは異なります
/// こちらは新しいマルチデバイス対応版で、Hive は使用せず Firestore のみで管理されます
class DeviceInfoEntity {
  final String deviceId;
  final DevicePlatform platform;

  // トークン情報
  final String? fcmToken;
  final String? voipToken; // iOS のみ

  // デバイス詳細
  final DeviceDetails details;

  // メタデータ
  final bool isActive;
  final Timestamp lastActiveAt;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  DeviceInfoEntity({
    required this.deviceId,
    required this.platform,
    this.fcmToken,
    this.voipToken,
    required this.details,
    required this.isActive,
    required this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceInfoEntity.fromJson(
      String deviceId, Map<String, dynamic> json) {
    return DeviceInfoEntity(
      deviceId: deviceId,
      platform: DevicePlatform.fromString(json['platform'] ?? 'android'),
      fcmToken: json['fcmToken'],
      voipToken: json['voipToken'],
      details: DeviceDetails.fromJson(json['deviceInfo'] ?? {}),
      isActive: json['isActive'] ?? true,
      lastActiveAt: json['lastActiveAt'] ?? Timestamp.now(),
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform.toFirestore(),
      'fcmToken': fcmToken,
      'voipToken': voipToken,
      'deviceInfo': details.toJson(),
      'isActive': isActive,
      'lastActiveAt': lastActiveAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// ActiveDeviceSummary に変換 (users ドキュメントのキャッシュ用)
  ActiveDeviceSummary toSummary() {
    return ActiveDeviceSummary(
      deviceId: deviceId,
      platform: platform,
      fcmToken: fcmToken,
      voipToken: voipToken,
      lastActiveAt: lastActiveAt,
    );
  }

  /// 通知を受信可能かどうか
  bool get canReceiveNotification =>
      isActive && (fcmToken != null || voipToken != null);

  /// iOS デバイスかどうか
  bool get isIOS => platform.isIOS;

  /// Android デバイスかどうか
  bool get isAndroid => platform.isAndroid;

  /// VoIP 通知が利用可能かどうか (iOS のみ)
  bool get canUseVoip => isIOS && voipToken != null && isActive;

  DeviceInfoEntity copyWith({
    String? deviceId,
    DevicePlatform? platform,
    String? fcmToken,
    String? voipToken,
    DeviceDetails? details,
    bool? isActive,
    Timestamp? lastActiveAt,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return DeviceInfoEntity(
      deviceId: deviceId ?? this.deviceId,
      platform: platform ?? this.platform,
      fcmToken: fcmToken ?? this.fcmToken,
      voipToken: voipToken ?? this.voipToken,
      details: details ?? this.details,
      isActive: isActive ?? this.isActive,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// トークンを更新した新しいインスタンスを返す
  DeviceInfoEntity updateTokens({
    String? fcmToken,
    String? voipToken,
  }) {
    return copyWith(
      fcmToken: fcmToken ?? this.fcmToken,
      voipToken: voipToken ?? this.voipToken,
      updatedAt: Timestamp.now(),
    );
  }

  /// 最終アクティブ日時を更新した新しいインスタンスを返す
  DeviceInfoEntity updateLastActive() {
    return copyWith(
      lastActiveAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
  }

  /// デバイスを無効化した新しいインスタンスを返す
  DeviceInfoEntity deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: Timestamp.now(),
    );
  }
}
