import 'package:app/core/utils/debug_print.dart';
import 'package:app/data/datasource/local/hive/friends_map.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/user_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_users_notifier.g.dart';

// 友達リクエストしたユーザーなどを含む、関係するユーザーの全てのUserModelのリスト
@Riverpod(keepAlive: true)
class AllUsersNotifier extends _$AllUsersNotifier {
  final Box<UserAccountHive> box = HiveBoxes.userBox();
  @override
  AsyncValue<Map<String, UserAccount>> build() {
    Map<String, UserAccount> allUsers = {};
    final keys = box.keys;
    for (String userId in keys) {
      final hiveObject = box.get(userId);
      if (hiveObject != null) {
        allUsers[userId] = hiveObject.toUserAccount();
      }
    }

    return AsyncValue.data(allUsers);
  }

  Future<List<UserAccount>> getUserAccounts(List<String> userIds,
      {bool update = false}) async {
    DebugPrint("get");
    Map<String, UserAccount> cache =
        state.asData != null ? state.asData!.value : {};
    List<UserAccount> list = [];
    List<Future<UserAccount?>> futures = [];
    if (update) {
      for (String userId in userIds) {
        futures.add(ref.read(userUsecaseProvider).getUserByUid(userId));
      }
    } else {
      for (String userId in userIds) {
        final cachUser = cache[userId];
        final hiveUser = box.get(userId);

        if (cachUser != null) {
          futures.add(Future.value(cachUser));
        } else if (hiveUser != null) {
          DateTime now = DateTime.now();
          DateTime updatedAt = hiveUser.updatedAt.toDate();
          final diffInHours = now.difference(updatedAt).inHours;
          if ((diffInHours < 72)) {
            futures.add(Future.value(hiveUser.toUserAccount()));
          } else {
            futures.add(ref.read(userUsecaseProvider).getUserByUid(userId));
          }
        } else {
          futures.add(ref.read(userUsecaseProvider).getUserByUid(userId));
        }
      }
    }
    await Future.wait(futures);

    for (var item in futures) {
      final user = (await item)!;

      cache[user.userId] = user;
      list.add(user);
      //アカウント切り替えのため、ConnectionTypeは使用しない
      box.put(
        user.userId,
        UserAccountHive(
          updatedAt: Timestamp.now(),
          type: ConnectionType.others,
          user: user,
        ),
      );
    }
    state = AsyncValue.data(cache);
    return list;
  }

  Future<UserAccount?> updateUserAccount(String userId) async {
    Map<String, UserAccount> cache =
        state.asData != null ? state.asData!.value : {};
    final user = await ref.read(userUsecaseProvider).getUserByUid(userId);
    if (user == null) return null;
    DebugPrint("GOT UPDATED USER : ${user.name}");
    box.put(
      user.userId,
      UserAccountHive(
        updatedAt: Timestamp.now(),
        type: ConnectionType.others,
        user: user,
      ),
    );
    cache[user.userId] = user;
    DebugPrint("強制アップデート ${user.name}");
    state = AsyncValue.data(cache);
    return user;
  }

  void addUserAccounts(List<UserAccount> users) {
    Map<String, UserAccount> cache =
        state.asData != null ? state.asData!.value : {};
    for (var user in users) {
      cache[user.userId] = user;
      box.put(
        user.userId,
        UserAccountHive(
          updatedAt: Timestamp.now(),
          type: ConnectionType.others,
          user: user,
        ),
      );
    }

    state = AsyncValue.data(cache);
  }

  UserAccount getUser(String userId) {
    final hiveObject = box.get(userId);
    return hiveObject!.toUserAccount();
  }

  //
  Future<List<UserAccount>> getOnlineUsers({Timestamp? lastOpenedAt}) async {
    final users = await ref.read(userUsecaseProvider).getOnlineUsers();
    addUserAccounts(users);

    final res = filterUsers(users);
    return res;
  }

  Future<List<UserAccount>> getRecentUsers() async {
    final users = await ref.read(userUsecaseProvider).getRecentUsers();
    addUserAccounts(users);
    final res = filterUsers(users);
    return res;
  }

  Future<List<UserAccount>> getUsersByHashTag(String tagId,
      {bool oneOnly = false}) async {
    final users =
        await ref.read(userUsecaseProvider).searchUserByTag(tagId, oneOnly);
    addUserAccounts(users);
    final res = filterUsers(users);
    return res;
  }

  Future<List<UserAccount>> getNewUsers({Timestamp? createdAt}) async {
    final users =
        await ref.read(userUsecaseProvider).getNewUsers(createdAt: createdAt);
    addUserAccounts(users);
    final res = filterUsers(users);
    return res;
  }

  Future<List<UserAccount>> filterUsers(List<UserAccount> users) async {
    final filteredUsers =
        users.where((user) => user.username != "null").toList();
    return filteredUsers;
  }
}
