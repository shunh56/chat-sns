import 'package:app/core/utils/debug_print.dart';
import 'package:app/datasource/local/hive/friendsMap.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/usecase/user_usecase.dart';
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
    DebugPrint("FOUND ${keys.length} user data stored");
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
    if (userIds.isEmpty) return [];
    Map<String, UserAccount> cache =
        state.asData != null ? state.asData!.value : {};
    List<UserAccount> list = [];
    List<Future<UserAccount?>> futures = [];
    if (update) {
      for (String userId in userIds) {
        DebugPrint("getting from firestore!");
        futures.add(ref.read(userUsecaseProvider).getUserByUid(userId));
      }
    } else {
      for (String userId in userIds) {
        final hiveUser = box.get(userId);
        if (hiveUser != null) {
          DateTime now = DateTime.now();
          DateTime updatedAt = hiveUser.updatedAt.toDate();
          final diffInHours = now.difference(updatedAt).inHours;
          if ((diffInHours < 72)) {
            DebugPrint("getting from HIVE!");
            futures.add(Future.value(hiveUser.toUserAccount()));
          }
        } else if (cache[userId] != null) {
          DebugPrint("getting from CACHE!");
          futures.add(Future.value(cache[userId]));
        } else {
          DebugPrint("getting from firestore!");
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
    DebugPrint("強制アップデート");
    state = AsyncValue.data(cache);
    return user;
  }

  void addUserAccounts(List<UserAccount> users) {
    Map<String, UserAccount> cache =
        state.asData != null ? state.asData!.value : {};
    for (var user in users) {
      cache[user.userId] = user;
    }
    DebugPrint("addUserAccounts");
    state = AsyncValue.data(cache);
  }

  UserAccount getUser(String userId) {
    final hiveObject = box.get(userId);
    return hiveObject!.toUserAccount();
  }
}
