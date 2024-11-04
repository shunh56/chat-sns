import 'dart:async';
import 'dart:collection';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/datasource/local/hive/friends_map.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/friends_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class FriendInfo {
  final Timestamp createdAt;
  final String userId;
  final int engagementCount;
  FriendInfo({
    required this.createdAt,
    required this.userId,
    required this.engagementCount,
  });
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
    _subscription = stream.listen((infos) async {
      final friendIds = infos.map((info) => info.userId).toList();
      updateFriendFriends(_ref.read(authProvider).currentUser!.uid, friendIds);
      await _ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(friendIds, update: true);
      _ref.read(myAccountNotifierProvider.notifier).checkTopFriends(friendIds);
      if (mounted) {
        state = AsyncValue.data(infos);
      }
    });
  }

  addFriend(String userId) {
    usecase.addFriend(userId);
  }

  void addEngagement(UserAccount user) {
    usecase.addEngagement(user.userId);
  }

  void deleteFriend(UserAccount user) async {
    _ref.read(myAccountNotifierProvider.notifier).removeTopFriends(user);
    usecase.deleteFriend(user.userId);
  }

  Future<List<UserAccount>> getFriends(String userId) async {
    final userIds = await usecase.getFriends(userId);
    updateFriendFriends(userId, userIds);
    return await _ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(userIds);
  }

  updateFriendFriends(String userId, List<String> userIds) {
    HiveBoxes.box().put(userId, userIds);
    _ref
        .read(friendFriendsMapNotifierProvider.notifier)
        .addFriendFriends(userId, userIds);
  }
}

final deletesIdListNotifierProvider =
    StateNotifierProvider<DeletesIdListNotifier, AsyncValue<List<String>>>(
        (ref) {
  return DeletesIdListNotifier(
    ref.watch(friendsUsecaseProvider),
  )..initialize();
});

class DeletesIdListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  DeletesIdListNotifier(this.usecase)
      : super(const AsyncValue<List<String>>.loading());

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
      //showMessage("フレンド申請を送りました！");
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

final friendFriendsMapNotifierProvider = StateNotifierProvider.autoDispose<
    FriendFriendsMapNotifier, Map<String, Set<String>>>((ref) {
  return FriendFriendsMapNotifier()..initialize();
});

class FriendFriendsMapNotifier extends StateNotifier<Map<String, Set<String>>> {
  FriendFriendsMapNotifier() : super(const {});

  final Box<List<String>> box = HiveBoxes.box();

  void initialize() async {
    final map = Map<String, Set<String>>.from(state);
    final keys = box.keys;
    for (var userId in keys) {
      final userIds = box.get(userId) ?? [];
      map[userId] = userIds.toSet();
      state = map;
    }
  }

  addFriendFriends(String userId, List<String> userIds) {
    final map = Map<String, Set<String>>.from(state);
    map[userId] = userIds.toSet();
    state = map;
  }
}

final relationNotifier = Provider(
  (ref) => RelationNotifier(ref),
);

class RelationNotifier {
  final Ref ref;
  RelationNotifier(this.ref);

  Map<String, Set<String>> _getMap() {
    final map = Map<String, Set<String>>.from(
        ref.read(friendFriendsMapNotifierProvider));
    return map;
  }

  Map<String, int> getDistanceMap({String? userId}) {
    final map = _getMap();
    Map<String, int> dist = {};
    final q = Queue<String>();
    final start = userId ?? ref.read(authProvider).currentUser!.uid;
    dist[start] = 0;
    q.add(start);
    while (q.isNotEmpty) {
      String v = q.removeFirst();
      for (String nv in map[v] ?? {}) {
        if (dist[nv] == null) {
          dist[nv] = dist[v]! + 1;
          q.add(nv);
        }
      }
    }
    return dist;
  }

  List<String> getMaybeFriends() {
    final dist = getDistanceMap();
    final list = dist.entries
        .where((item) => item.value == 2)
        .map((item) => item.key)
        .toList();
    list.removeWhere((userId) => getMutualIds(userId).isEmpty);
    final map = _getMap();
    list.sort((a, b) => (map[a] ?? {}).length.compareTo((map[b] ?? {}).length));
    return list;
  }

  List<String> getMutualIds(String userId) {
    final dist01 = getDistanceMap();
    final dist02 = getDistanceMap(userId: userId);
    return dist01.entries
        .where((item) => item.value == 1 && dist02[item.key] == 1)
        .map((item) => item.key)
        .toList();
  }
}
