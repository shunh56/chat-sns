import 'package:app/data/datasource/hive/user_datasource.dart';
import 'package:app/data/datasource/user_datasource.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider(
  (ref) => UserRepository(
    ref.read(userDatasourceProvider),
    ref.watch(hiveUserDatasourceProvider),
  ),
);

class UserRepository {
  final UserDatasource _datasource;
  final HiveUserDataSource _hiveDatasource;
  final _cacheExpiration = 60 * 60 * 24; //seconds
  UserRepository(
    this._datasource,
    this._hiveDatasource,
  );

  Future<List<UserAccount>> getOnlineUsers() async {
    final res = await _datasource.getOnlineUsers();
    return res.docs.map((doc) => UserAccount.fromJson(doc.data())).toList();
  }

  Future<List<UserAccount>> getRecentUsers() async {
    final res = await _datasource.getRecentUsers();
    return res.docs.map((doc) => UserAccount.fromJson(doc.data())).toList();
  }

  Future<List<UserAccount>> getNewUsers({Timestamp? createdAt}) async {
    final res = await _datasource.getNewUsers(createdAt: createdAt);
    return res.docs.map((doc) => UserAccount.fromJson(doc.data())).toList();
  }

  Future<UserAccount?> getUserByUsername(String username) async {
    final res = await _datasource.fetchUserByUsername(username);
    if (res != null && res.exists) {
      return UserAccount.fromJson(res.data()!);
    } else {
      return null;
    }
  }

  Future<List<UserAccount>> getUsersByUserIds(List<String> userIds) async {
    final futures = userIds.map((userId) => getUserByUserId(userId)).toList();
    final results = await Future.wait(futures);
    return results.whereType<UserAccount>().toList();
  }

  Future<UserAccount?> getUserByUserId(String userId,
      {bool force = false}) async {
    final cachedUser = await _hiveDatasource.getUserById(userId);
    if (!force && cachedUser != null && _isCacheValid(cachedUser.updatedAt)) {
      return cachedUser.toUserAccount();
    }

    final res = await _datasource.fetchUserByUserId(userId);
    if (res != null && res.exists) {
      return UserAccount.fromJson(res.data()!);
    } else {
      return null;
    }
  }

  bool _isCacheValid(Timestamp lastUpdated) {
    return flavor != "dev" &&
        ((Timestamp.now().seconds - lastUpdated.seconds) < _cacheExpiration);
  }

  Future<List<UserAccount>> searchUserByName(String name) async {
    final res = await _datasource.searchUserByName(name);
    return res.docs.map((doc) => UserAccount.fromJson(doc.data())).toList();
  }

  Future<List<UserAccount>> searchUserByUsername(
    String username,
  ) async {
    final res = await _datasource.searchUserByUsername(username);
    return res.docs.map((doc) => UserAccount.fromJson(doc.data())).toList();
  }

  Future<List<UserAccount>> searchUserByTag(String tagId, bool oneOnly) async {
    final res = await _datasource.searchUserByTag(tagId, oneOnly);
    return res.docs.map((doc) => UserAccount.fromJson(doc.data())).toList();
  }

  createUser(Map<String, dynamic> json) {
    _datasource.createUser(json);
  }

  updateUser(Map<String, dynamic> json) {
    return _datasource.updateUser(json);
  }
}
