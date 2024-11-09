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

  Future<List<UserAccount>> getOnlineUsers({Timestamp? lastOpenedAt}) async {
    return await _repository.getOnlineUsers(lastOpenedAt: lastOpenedAt);
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

  createUser(
    UserAccount user,
  ) {
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
