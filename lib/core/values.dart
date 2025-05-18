// ignore_for_file: non_constant_identifier_names

import 'dart:io';

String appName = "BLANK";
String platformOS = Platform.isAndroid ? "Android" : "iOS";

int QUERY_LIMIT = 30;
bool postPrivacyMode = false;

class AppConstants {
  static const int HIVE_SCHEMA_VERSION = 4;
}
