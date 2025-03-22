import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Versionの状態を管理するプロバイダー
final versionStatusProvider = FutureProvider<VersionStatus>((ref) async {
  try {
    final remoteConfig = await ref.watch(remoteConfigProvider.future);
    final packageInfo = await PackageInfo.fromPlatform();
    DebugPrint("packageInfo : $packageInfo");

    final currentVersion = AppVersion.parse(packageInfo.version);
    final minVersion =
        AppVersion.parse(remoteConfig.getString('minimum_version'));
    final latestVersion =
        AppVersion.parse(remoteConfig.getString('latest_version'));
    DebugPrint(
        "current :$currentVersion,  min : $minVersion , latest : $latestVersion");

    if (currentVersion < minVersion) {
      return VersionStatus.requiresUpdate;
    } else if (currentVersion < latestVersion) {
      return VersionStatus.updateAvailable;
    } else {
      return VersionStatus.upToDate;
    }
  } catch (e) {
    return VersionStatus.upToDate;
  }
});

// バージョン管理用のクラス
class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;

  const AppVersion(this.major, this.minor, this.patch);

  factory AppVersion.parse(String version) {
    final parts = version.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid version format: $version');
    }

    try {
      return AppVersion(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      throw FormatException('Invalid version number format: $version');
    }
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;
  bool operator >=(AppVersion other) => compareTo(other) >= 0;

  @override
  String toString() => '$major.$minor.$patch';
}

enum VersionStatus {
  upToDate, // 最新バージョン
  updateAvailable, // アップデート可能
  requiresUpdate // アップデート必須
}
