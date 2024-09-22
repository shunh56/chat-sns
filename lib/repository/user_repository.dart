import 'package:app/datasource/user_datasource.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/value/user/gender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider(
  (ref) => UserRepository(
    ref.read(userDatasourceProvider),
  ),
);

class UserRepository {
  final UserDatasource _datasource;
  UserRepository(this._datasource);

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

  createUser({
    required String name,
    String? imageUrl,
    required Gender gender,
  }) {
    _datasource.createUser(
      name: name,
      imageUrl: imageUrl,
      gender: GenderConverter.convertToString(gender),
    );
  }

  updateUser(Map<String, dynamic> json) {
    return _datasource.updateUser(json);
  }
}
