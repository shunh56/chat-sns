class Flavor {
  static bool get isDevEnv => const String.fromEnvironment('FLAVOR') == "dev";

  static bool get isProdEnv => const String.fromEnvironment('FLAVOR') != "dev";
  static bool get isAppStoreEnv =>
      const String.fromEnvironment('FLAVOR') == "appstore";

  static String get getEnv => const String.fromEnvironment('FLAVOR');
}
