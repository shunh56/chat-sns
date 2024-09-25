import 'package:app/core/extenstions/string_extenstion.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/value/user/gender.dart';
import 'package:app/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userUsecaseProvider = Provider(
  (ref) => UserUsecase(
    ref.read(userRepositoryProvider),
  ),
);

class UserUsecase {
  final UserRepository _repository;
  UserUsecase(this._repository);

  Future<String> checkUsername(String username) async {
    if (username.length < 5) {
      return "ユーザー名が短すぎます";
    }
    if (!username.isUsername) {
      return "ユーザー名に使用できない文字が含まれています。";
    }
    final user = await _repository.getUserByUsername(username);
    if (user != null) {
      return "そのユーザー名は使用できません";
    } else {
      return "success";
    }
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
