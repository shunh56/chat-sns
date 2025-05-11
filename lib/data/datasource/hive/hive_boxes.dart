import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/values.dart';
import 'package:app/domain/entity/user.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiveBoxes {
  static registerAdapters() {
    Hive.registerAdapter(UserAccountHiveAdapter());
    Hive.registerAdapter(UserAccountAdapter());
    Hive.registerAdapter(DeviceInfoAdapter());
    Hive.registerAdapter(LinksAdapter());
    Hive.registerAdapter(LinkAdapter());
    Hive.registerAdapter(BioAdapter());
    Hive.registerAdapter(CurrentStatusAdapter());
    Hive.registerAdapter(CanvasThemeAdapter());
    Hive.registerAdapter(NotificationDataAdapter());
    Hive.registerAdapter(PrivacyAdapter());
    Hive.registerAdapter(AccountStatusAdapter());
    Hive.registerAdapter(SubscriptionStatusAdapter());
    Hive.registerAdapter(PublicityRangeAdapter());
    Hive.registerAdapter(TimestampAdapter());
    Hive.registerAdapter(ColorAdapter());
  }

  static openBoxes() async {
    await _handleSchemaVersion();
    await Hive.openBox<UserAccountHive>('userAccount');
  }

  static Box<UserAccountHive> userBox() {
    return Hive.box<UserAccountHive>('userAccount');
  }

  static Future<void> _handleSchemaVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final int? storedVersion = prefs.getInt('hiveSchemaVersion');
    DebugPrint(
        "hiveSchemaVersion : $storedVersion HIVE_SCHEMA_VERSION : ${AppConstants.HIVE_SCHEMA_VERSION}");

    if (storedVersion == null ||
        storedVersion < AppConstants.HIVE_SCHEMA_VERSION) {
      await clearAllBoxes();
      await prefs.setInt('hiveSchemaVersion', AppConstants.HIVE_SCHEMA_VERSION);
    }
  }

  static Future<void> clearAllBoxes() async {
    try {
      await Hive.deleteBoxFromDisk('userAccount');
      print('Successfully cleared all Hive data');
    } catch (e) {
      print('Error clearing Hive data: $e');
    }
  }
}
