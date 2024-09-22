/*// Package imports:
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/usecase/follow_follower_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myFollowingListNotifierProvider =
    StateNotifierProvider<FollowingListNotifier, AsyncValue<List<String>>>(
        (ref) {
  return FollowingListNotifier(
    ref,
    ref.watch(ffUsecaseProvider),
  )..initialize();
});

class FollowingListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  FollowingListNotifier(this._ref, this.usecase)
      : super(const AsyncValue<List<String>>.loading());
  final Ref _ref;
  final FFUsecase usecase;

  Future<List<UserAccount>> initialize() async {
    //Hiveから最後に取得した時刻をチェックする
    final userIdList = await usecase.getFollowings();
    state = AsyncValue.data(userIdList);
    return await _ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(userIdList);
    /* DateTime now = DateTime.now();
    final DateTime? dateTime = timeBox.get("follow_updated_at")?.dateTime;
    List<UserAccount> followings;
    if (dateTime == null || now.difference(dateTime).inMinutes > 30) {
      followings = await getFollowings();
      await timeBox.put("follow_updated_at", DateTimeInfo(dateTime: now));
      _ref
          .read(allUsersNotifierProvider)
          .saveUsers(followings, ConnectionType.follow);
    } else {
      await Future.delayed(const Duration(milliseconds: 200));

      final List<UserAccountHive> users = userBox.values.toList();
      followings = users
          .where((user) => user.type == ConnectionType.follow)
          .map((e) => e.user)
          .toList();
      DebugPrint("GET FROM HIVE");
    }
    state = AsyncValue.data(followings.map((e) => e.userId).toList());
    return followings; */
  }

  followUser(UserAccount user) async {
    usecase.followUser(user.userId);
    final listToUpdate = state.value;
    listToUpdate!.add(user.userId);
    state = AsyncValue.data(listToUpdate);
  }

  unFollowUser(UserAccount user) async {
    usecase.unfollowUser(user.userId);
    final listToUpdate = state.value;
    listToUpdate!.removeWhere((element) => element == user.userId);
    state = AsyncValue.data(listToUpdate);
  }

  Future<List<UserAccount>> getFollowings({String? userId}) async {
    final userIdList = await usecase.getFollowings(userId: userId);
    return await _ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(userIdList);
  }

  Future<List<UserAccount>> getFollowers({String? userId}) async {
    final userIdList = await usecase.getFollowers(userId: userId);
    return await _ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(userIdList);
  }
}
 */