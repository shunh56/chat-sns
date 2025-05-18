import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';

final deviceInfoDatasourceProvider = Provider((ref) => DeviceInfoDatasource());

class DeviceInfoDatasource {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getInfo() async {
    try {
      // if (kIsWeb) {
      //   deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      // } else {
      return switch (defaultTargetPlatform) {
        TargetPlatform.android =>
          _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
        TargetPlatform.iOS =>
          _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
        TargetPlatform.fuchsia => <String, dynamic>{
            'Error:': 'Fuchsia platform isn\'t supported'
          },
        TargetPlatform.linux => <String, dynamic>{
            'Error:': 'Linux platform isn\'t supported'
          },
        TargetPlatform.macOS => <String, dynamic>{
            'Error:': 'MacOS platform isn\'t supported'
          },
        TargetPlatform.windows => <String, dynamic>{
            'Error:': 'Windows platform isn\'t supported'
          },
        /*TargetPlatform.linux =>
            _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          TargetPlatform.windows =>
            _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS =>
            _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo), */
      };
      // }
    } on PlatformException {
      return <String, dynamic>{'Error:': 'Web platform isn\'t supported'};
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo androidInfo) {
    return {
      // 共通フィールド（両プラットフォーム共通の命名）
      'platform': 'Android',
      'osVersion': androidInfo.version.release,
      'deviceModel': androidInfo.model,
      'deviceBrand': androidInfo.brand,
      'deviceManufacturer': androidInfo.manufacturer,
      'isPhysicalDevice': androidInfo.isPhysicalDevice,
      'deviceId': androidInfo.id,

      // Android固有の有用情報
      'sdkVersion': androidInfo.version.sdkInt,
      'securityPatch': androidInfo.version.securityPatch,
      'hardware': androidInfo.hardware,
      'bootloader': androidInfo.bootloader,
      'fingerprint': androidInfo.fingerprint,
      'product': androidInfo.product,
      'device': androidInfo.device,
      'board': androidInfo.board,
      'supportedAbis': androidInfo.supportedAbis,
      'isLowRamDevice': androidInfo.isLowRamDevice,
      'systemFeatures': androidInfo.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo iosInfo) {
    return {
      // 共通フィールド（両プラットフォーム共通の命名）
      'platform': 'iOS',
      'osVersion': iosInfo.systemVersion,
      'deviceModel': iosInfo.model,
      'deviceBrand': 'Apple', // iOSは常にApple
      'deviceManufacturer': 'Apple', // iOSは常にApple
      'isPhysicalDevice': iosInfo.isPhysicalDevice,
      'deviceId': iosInfo.identifierForVendor,

      // iOS固有の有用情報
      'deviceName': iosInfo.name,
      'systemName': iosInfo.systemName,
      'localizedModel': iosInfo.localizedModel,
      'utsname': {
        'sysname': iosInfo.utsname.sysname,
        'nodename': iosInfo.utsname.nodename,
        'release': iosInfo.utsname.release,
        'version': iosInfo.utsname.version,
        'machine': iosInfo.utsname.machine,
      },
    };
  }

  /* Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'modelName': data.modelName,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  } */
}
