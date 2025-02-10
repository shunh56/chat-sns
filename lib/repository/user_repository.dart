import 'package:app/datasource/user_datasource.dart';
import 'package:app/domain/entity/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider(
  (ref) => UserRepository(
    ref.read(userDatasourceProvider),
  ),
);

class UserRepository {
  final UserDatasource _datasource;
  UserRepository(this._datasource);

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

  Future<UserAccount?> getUserByUserId(String userId) async {
    final res = await _datasource.fetchUserByUserId(userId);
    if (res != null && res.exists) {
      return UserAccount.fromJson(res.data()!);
    } else {
      return null;
    }
  }

  Future<List<UserAccount>> searchUserByName(String name) async {
    final res = await _datasource.searchUserByName(name);
    return res.docs.map((doc) => UserAccount.fromJson(doc.data())).toList();
  }

  Future<List<UserAccount>> searchUserByUsername(String username) async {
    final res = await _datasource.searchUserByUsername(username);
    return res.docs.map((doc) => UserAccount.fromJson(doc.data())).toList();
  }

  createUser(Map<String, dynamic> json) {
    _datasource.createUser(json);
  }

  updateUser(Map<String, dynamic> json) {
    return _datasource.updateUser(json);
  }
}
