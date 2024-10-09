import 'dart:async';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
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
      _ref
          .read(myAccountNotifierProvider.notifier)
          .checkTopFriends(friendInfos.map((item) => item.userId).toList());
      if (mounted) {
        state = AsyncValue.data(friendInfos);
      }
    });
  }

  addFriend(String userId) {
    usecase.addFriend(userId);
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

final deletesIdListNotifierProvider =
    StateNotifierProvider<DeletesIdListNotifier, AsyncValue<List<String>>>(
        (ref) {
  return DeletesIdListNotifier(
    ref,
    ref.watch(friendsUsecaseProvider),
  )..initialize();
});

class DeletesIdListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  DeletesIdListNotifier(this._ref, this.usecase)
      : super(const AsyncValue<List<String>>.loading());
  final Ref _ref;
  final FriendsUsecase usecase;
  void initialize() async {
    final deleteIds = await usecase.getDeletes();
    if (mounted) {
      state = AsyncValue.data(deleteIds);
    }
  }

  deleteUser(UserAccount user) {
    final list = state.asData?.value ?? [];
    list.add(user.userId);

    if (mounted) {
      state = AsyncValue.data(list);
    }
    usecase.deleteUser(user);
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
      await _ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(userIds);

      if (mounted) {
        state = AsyncValue.data(userIds);
      }
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
      if (mounted) {
        state = AsyncValue.data(userIds);
      }
    });
  }

  admitFriendRequested(UserAccount user) {
    usecase.admitFriendRequested(user.userId);
  }

  deleteRequested(UserAccount user) {
    usecase.deleteRequested(user.userId);
  }
}

final friendsFriendListNotifierProvider = StateNotifierProvider.autoDispose<
    FriendsFriendListNotifier, AsyncValue<List<UserAccount>>>((ref) {
  return FriendsFriendListNotifier(
    ref,
    ref.watch(friendIdListNotifierProvider),
    ref.watch(blocksListNotifierProvider),
    ref.watch(friendsUsecaseProvider),
  )..initialize();
});

class FriendsFriendListNotifier
    extends StateNotifier<AsyncValue<List<UserAccount>>> {
  FriendsFriendListNotifier(
    this._ref,
    this.asyncValue,
    this.asyncBlocks,
    this.usecase,
  ) : super(const AsyncValue<List<UserAccount>>.loading());
  final Ref _ref;
  final AsyncValue<List<FriendInfo>> asyncValue;
  final AsyncValue<List<String>> asyncBlocks;
  final FriendsUsecase usecase;

  //TODO グリッチが起きてしまう
  void initialize() async {
    Set<String> userIds = {};
    final friendIds = asyncValue;
    friendIds.maybeWhen(
      data: (friendInfos) async {
        userIds = {};
        final map =
            Map<String, Set<String>>.from(_ref.read(friendsFriendMapProvider));
        final friendIds = friendInfos.map((item) => item.userId).toList();
        final filterIds =
            friendIds + [_ref.read(authProvider).currentUser!.uid];
        //futures
        List<Future<List<UserAccount>>> futures = [];
        for (String userId in friendIds) {
          final user =
              _ref.read(allUsersNotifierProvider).asData?.value[userId];
          if (user != null) {
            futures.add(
              _ref
                  .read(allUsersNotifierProvider.notifier)
                  .getUserAccounts(user.topFriends),
            );
          }
        }
        await Future.wait(futures);

        //
        for (int i = 0; i < friendIds.length; i++) {
          final userId = friendIds[i];
          final list = await futures[i];
          for (var user in list) {
            if (!user.privacy.privateMode) {
              userIds.add(user.userId);
              if (map[user.userId] == null) {
                map[user.userId] = {userId};
              } else {
                map[user.userId]!.add(userId);
              }
            }
          }
        }
        _ref.read(friendsFriendMapProvider.notifier).state = map;

        userIds.removeWhere((userId) => filterIds.contains(userId));

        final users = _ref
            .read(allUsersNotifierProvider)
            .asData
            ?.value
            .entries
            .where((item) => userIds.contains(item.value.userId))
            .map((item) => item.value)
            .toSet();

        asyncBlocks.maybeWhen(
          data: (blocks) {
            users?.removeWhere((user) => blocks.contains(user.userId));
            state = AsyncValue.data(users!.toList());
          },
          orElse: () {},
        );
      },
      orElse: () {},
    );
  }
}

final friendsFriendMapProvider =
    StateProvider<Map<String, Set<String>>>((ref) => {});
