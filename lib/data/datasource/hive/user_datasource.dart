import 'package:app/data/datasource/hive/hive_boxes.dart';
import 'package:app/domain/entity/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveUserDatasourceProvider = Provider(
  (ref) => HiveUserDataSource(HiveBoxes.userBox()),
);

class HiveUserDataSource {
  final Box<UserAccountHive> _box;

  HiveUserDataSource(this._box);

  Future<UserAccountHive?> getUserById(String userId) async {
    final hiveUser = _box.get(userId);
    return hiveUser;
  }

  storeUser(UserAccount user) {
    _box.put(
      user.userId,
      UserAccountHive(
        updatedAt: Timestamp.now(),
        //type: ConnectionType.others,
        user: user,
      ),
    );
  }
}
