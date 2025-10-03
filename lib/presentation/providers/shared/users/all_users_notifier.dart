import 'package:app/core/utils/debug_print.dart';
import 'package:app/data/datasource/hive/hive_boxes.dart';
import 'package:app/domain/entity/tag_stat.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/tag/tagId/get_active_users.dart';
import 'package:app/domain/usecases/user_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_users_notifier.g.dart';

// 友達リクエストしたユーザーなどを含む、関係するユーザーの全てのUserModelのリスト
@Riverpod(keepAlive: true)
class AllUsersNotifier extends _$AllUsersNotifier {
  final Box<UserAccountHive> box = HiveBoxes.userBox();

  Map<String, UserAccount> _getCache() =>
      Map<String, UserAccount>.from(state.asData?.value ?? {});

  @override
  AsyncValue<Map<String, UserAccount>> build() {
    return const AsyncValue.data({});
  }

  Future<UserAccount> getUserByUserId(String userId) async {
    Map<String, UserAccount> cache = _getCache();
    final user = await ref.read(userUsecaseProvider).getUserByUid(userId);
    cache[user!.userId] = user;
    state = AsyncValue.data(cache);
    return user;
  }

  Future<List<UserAccount>> getUserAccounts(List<String> userIds) async {
    // 現在のキャッシュを取得
    Map<String, UserAccount> cache = _getCache();

    // まずキャッシュにあるユーザーを集める
    final List<UserAccount> cachedUsers = [];
    final List<String> missingUserIds = [];

    for (final id in userIds) {
      if (cache.containsKey(id)) {
        cachedUsers.add(cache[id]!);
      } else {
        missingUserIds.add(id);
      }
    }

    // キャッシュにないユーザーをリポジトリから取得
    final List<UserAccount> fetchedUsers =
        await ref.read(userUsecaseProvider).getUsersByUserIds(missingUserIds);

    // キャッシュを更新
    final updatedCache = Map<String, UserAccount>.from(cache);
    for (final user in fetchedUsers) {
      updatedCache[user.userId] = user;
    }

    // state を更新
    state = AsyncValue.data(updatedCache);

    // キャッシュ済み＋新規取得のリストを返す（順番を userIds に揃える）
    final allUsers = <UserAccount>[];
    for (final id in userIds) {
      final user = updatedCache[id];
      if (user != null) {
        allUsers.add(user);
      }
    }
    return allUsers;
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
        //type: ConnectionType.others,
        user: user,
      ),
    );
    cache[user.userId] = user;
    DebugPrint("強制アップデート ${user.name}");
    state = AsyncValue.data(cache);
    return user;
  }

  void addUserAccounts(List<UserAccount> users) {
    Map<String, UserAccount> cache = _getCache();
    for (var user in users) {
      cache[user.userId] = user;
      box.put(
        user.userId,
        UserAccountHive(
          updatedAt: Timestamp.now(),
          //type: ConnectionType.others,
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

  Future<List<UserAccount>> getUsersByHashTag(String tagId) async {
    final List<TagUser> res =
        await ref.read(getActiveUsersProvider).execute(tagId);
    final userIds = res.map((item) => item.userId).toList();
    return await getUserAccounts(userIds);
  }

  Future<List<UserAccount>> loadMoreUsersByHashTag(
      String tagId, String userId) async {
    final List<TagUser> res = await ref
        .read(getActiveUsersProvider)
        .execute(tagId, lastUserId: userId);
    final userIds = res.map((item) => item.userId).toList();
    return await getUserAccounts(userIds);
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
