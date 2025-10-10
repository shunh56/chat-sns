enum DevicePlatform {
  ios,
  android;

  static DevicePlatform fromString(String str) {
    return str.toLowerCase() == 'ios'
        ? DevicePlatform.ios
        : DevicePlatform.android;
  }

  String toFirestore() => this == DevicePlatform.ios ? 'ios' : 'android';

  bool get isIOS => this == DevicePlatform.ios;
  bool get isAndroid => this == DevicePlatform.android;
}
