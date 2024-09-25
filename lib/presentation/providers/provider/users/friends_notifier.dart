import 'dart:async';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/friends_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendInfo {
  final Timestamp createdAt;
  final String userId;
  FriendInfo(this.createdAt, this.userId);
}

final friendIdListNotifierProvider = StateNotifierProvider.autoDispose<
    FriendIdListNotifier, AsyncValue<List<FriendInfo>>>((ref) {
  return FriendIdListNotifier(
    ref,
    ref.watch(friendsUsecaseProvider),
  )..initialize();
});

class FriendIdListNotifier extends StateNotifier<AsyncValue<List<FriendInfo>>> {
  FriendIdListNotifier(this._ref, this.usecase)
      : super(const AsyncValue<List<FriendInfo>>.loading());
  final Ref _ref;
  final FriendsUsecase usecase;
  StreamSubscription<List<FriendInfo>>? _subscription;
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void initialize() async {
    Stream<List<FriendInfo>> stream = usecase.streamFriends();
    _subscription = stream.listen((friendInfos) async {
      await _ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(friendInfos.map((item) => item.userId).toList());
      state = AsyncValue.data(friendInfos);
    });
  }

  void deleteFriend(UserAccount user) async {
    _ref.read(myAccountNotifierProvider.notifier).removeTopFriends(user);
    usecase.deleteFriend(user.userId);
  }

  Future<List<UserAccount>> getFriends(String userId) async {
    final list = await usecase.getFriends(userId);
    return await _ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(list);
  }
}

final friendRequestIdListNotifierProvider = StateNotifierProvider.autoDispose<
    FriendRequestIdListNotifier, AsyncValue<List<String>>>((ref) {
  //TODO ondisposeでfirestore streamを破棄する
  //ref.onDispose(() => cancelToken.cancel());
  return FriendRequestIdListNotifier(
    ref,
    ref.watch(friendsUsecaseProvider),
  )..initialize();
});

class FriendRequestIdListNotifier
    extends StateNotifier<AsyncValue<List<String>>> {
  FriendRequestIdListNotifier(this._ref, this.usecase)
      : super(const AsyncValue<List<String>>.loading());
  final Ref _ref;
  final FriendsUsecase usecase;
  StreamSubscription<List<String>>? _subscription;

  void initialize() async {
    DebugPrint("initializing friendRequests");
    Stream<List<String>> stream = usecase.streamFriendRequests();
    _subscription = stream.listen((userIds) async {
      DebugPrint("request users : $userIds");
      await _ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(userIds);

      state = AsyncValue.data(userIds);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  sendFriendRequest(UserAccount user) async {
    try {
      await usecase.sendFriendRequest(user);
      showMessage("フレンド申請を送りました！");
    } catch (e) {
      showErrorSnackbar(error: e);
    }
  }

  void cancelFriendRequest(String userId) async {
    return usecase.cancelRequest(userId);
  }
}

final friendRequestedIdListNotifierProvider = StateNotifierProvider.autoDispose<
    FriendRequestedIdListNotifier, AsyncValue<List<String>>>((ref) {
  return FriendRequestedIdListNotifier(
    ref,
    ref.watch(friendsUsecaseProvider),
  )..initialize();
});

class FriendRequestedIdListNotifier
    extends StateNotifier<AsyncValue<List<String>>> {
  FriendRequestedIdListNotifier(this._ref, this.usecase)
      : super(const AsyncValue<List<String>>.loading());
  final Ref _ref;
  final FriendsUsecase usecase;
  StreamSubscription<List<String>>? _subscription;
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void initialize() async {
    Stream<List<String>> stream = usecase.streamFriendRequesteds();
    _subscription = stream.listen((userIds) async {
      await _ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(userIds);
      state = AsyncValue.data(userIds);
    });
  }

  admitFriendRequested(String userId) {
    usecase.admitFriendRequested(userId);
  }

  deleteRequested(String userId) {
    usecase.deleteRequested(userId);
  }
}

final friendsFriendListNotifierProvider = StateNotifierProvider.autoDispose<
    FriendsFriendListNotifier, AsyncValue<List<UserAccount>>>((ref) {
  return FriendsFriendListNotifier(
    ref,
    ref.watch(friendIdListNotifierProvider),
    ref.watch(friendsUsecaseProvider),
  )..initialize();
});

class FriendsFriendListNotifier
    extends StateNotifier<AsyncValue<List<UserAccount>>> {
  FriendsFriendListNotifier(
    this._ref,
    this.asyncValue,
    this.usecase,
  ) : super(const AsyncValue<List<UserAccount>>.loading());
  final Ref _ref;
  final AsyncValue<List<FriendInfo>> asyncValue;
  final FriendsUsecase usecase;

  bool initialized = false;

  void initialize() async {
    Map<String, UserAccount> userMap = {};
    final friendIds = asyncValue;
    friendIds.maybeWhen(
      data: (friendInfos) async {
        final friendIds = friendInfos.map((item) => item.userId).toList();
        final filterIds =
            friendIds + [_ref.read(authProvider).currentUser!.uid];
        List<Future<List<UserAccount>>> futures = [];
        for (String userId in friendIds) {
          futures.add(_ref
              .read(friendIdListNotifierProvider.notifier)
              .getFriends(userId));
        }
        await Future.wait(futures);
        final map = _ref.read(friendsFriendMapProvider);
        for (int i = 0; i < friendIds.length; i++) {
          final userId = friendIds[i];
          final list = await futures[i];
          for (var user in list) {
            userMap[user.userId] = user;
            if (map[user.userId] == null) {
              map[user.userId] = {userId};
            } else {
              map[user.userId]!.add(userId);
            }
          }
        }
        _ref.read(friendsFriendMapProvider.notifier).state = map;
        userMap.removeWhere((userId, val) => filterIds.contains(userId));
        List<UserAccount> users = userMap.entries.map((e) => e.value).toList();
        state = AsyncValue.data(users);
      },
      orElse: () {},
    );
  }

  void removeUser(UserAccount user) async {
    final list = state.asData!.value;
    list.removeWhere((e) => e.userId == user.userId);
    state = AsyncValue.data(list);
  }
}

final friendsFriendMapProvider =
    StateProvider<Map<String, Set<String>>>((ref) => {});
