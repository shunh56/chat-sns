/// デバイスの詳細情報
/// Firestore の devices サブコレクション内の deviceInfo フィールドとして保存される
class DeviceDetails {
  final String device; // "iPhone 15 Pro", "Pixel 8" など
  final String osVersion; // "17.1.1", "14.0" など
  final String appVersion; // "1.2.3"
  final String appBuildNumber; // "123"

  DeviceDetails({
    required this.device,
    required this.osVersion,
    required this.appVersion,
    required this.appBuildNumber,
  });

  factory DeviceDetails.fromJson(Map<String, dynamic> json) {
    return DeviceDetails(
      device: json['device'] ?? '',
      osVersion: json['osVersion'] ?? '',
      appVersion: json['appVersion'] ?? '',
      appBuildNumber: json['appBuildNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
    };
  }

  DeviceDetails copyWith({
    String? device,
    String? osVersion,
    String? appVersion,
    String? appBuildNumber,
  }) {
    return DeviceDetails(
      device: device ?? this.device,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      appBuildNumber: appBuildNumber ?? this.appBuildNumber,
    );
  }
}
