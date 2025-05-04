import 'package:app/domain/entity/user.dart';
import 'package:app/repository/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userUsecaseProvider = Provider(
  (ref) => UserUsecase(
    ref.read(userRepositoryProvider),
  ),
);

class UserUsecase {
  final UserRepository _repository;
  UserUsecase(this._repository);

  Future<List<UserAccount>> getOnlineUsers() async {
    return await _repository.getOnlineUsers();
  }

  Future<List<UserAccount>> getRecentUsers() async {
    return await _repository.getRecentUsers();
  }

  Future<List<UserAccount>> getNewUsers({Timestamp? createdAt}) async {
    return await _repository.getNewUsers(createdAt: createdAt);
  }

  Future<bool> checkUsername(String username) async {
    final user = await _repository.getUserByUsername(username);
    return user != null;
  }

  Future<UserAccount?> getUserByUid(String userId) async {
    return _repository.getUserByUserId(userId);
  }

  Future<List<UserAccount>> searchUserByName(String name) async {
    return _repository.searchUserByName(name);
  }

  Future<List<UserAccount>> searchUserByUsername(
    String username,
  ) async {
    return _repository.searchUserByUsername(
      username,
    );
  }

  Future<List<UserAccount>> searchUserByTag(String tagId, bool oneOnly) async {
    return _repository.searchUserByTag(tagId, oneOnly);
  }

  createUser(UserAccount user) {
    _repository.createUser(user.toJson());
  }

  updateUser(UserAccount user) {
    return _repository.updateUser(user.toJson());
  }

  /* Future<UserAccount> getUserByUsername(String username){
    return;
  } */

  /* Future<UserAccount> createUserAccount(String name,String username){
    return 
  } */
}
