import 'package:app/domain/entity/user.dart';
import 'package:hive/hive.dart';

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
    Hive.registerAdapter(ConnectionTypeAdapter());
    Hive.registerAdapter(TimestampAdapter());
    Hive.registerAdapter(ColorAdapter());
  }

  static openBoxes() async {
    await Hive.openBox<List<String>>('friendIds');
    await Hive.openBox<UserAccountHive>('userAccount');
  }

  static Box<List<String>> box() {
    return Hive.box<List<String>>('friendIds');
  }

  static Box<UserAccountHive> userBox() {
    return Hive.box<UserAccountHive>('userAccount');
  }
}
