import 'package:app/domain/entity/user.dart';
import 'package:app/usecase/user_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_users_notifier.g.dart';

// 友達リクエストしたユーザーなどを含む、関係するユーザーの全てのUserModelのリスト
@Riverpod(keepAlive: true)
class AllUsersNotifier extends _$AllUsersNotifier {
  @override
  AsyncValue<Map<String, UserAccount>> build() {
    Map<String, UserAccount> allUsers = {};
    return AsyncValue.data(allUsers);
  }

  Future<List<UserAccount>> getUserAccounts(List<String> userIds) async {
    Map<String, UserAccount> cache =
        state.asData != null ? state.asData!.value : {};
    List<UserAccount> list = [];
    List<Future<UserAccount?>> futures = [];
    for (String userId in userIds) {
      if (cache[userId] != null) {
        futures.add(Future.value(cache[userId]));
      } else {
        futures.add(ref.read(userUsecaseProvider).getUserByUid(userId));
      }
    }
    await Future.wait(futures);
    for (var item in futures) {
      final user = (await item)!;
      cache[user.userId] = user;
      list.add(user);
    }
    state = AsyncValue.data(cache);
    return list;
  }

  void addUserAccounts(List<UserAccount> users) {
    Map<String, UserAccount> cache =
        state.asData != null ? state.asData!.value : {};
    for (var user in users) {
      cache[user.userId] = user;
    }
    state = AsyncValue.data(cache);
  }
}
