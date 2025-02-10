import 'package:app/datasource/relation_datasouce.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/relations_notifier.dart';
import 'package:app/usecase/friends_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendIdsStreamNotifier = StreamProvider.autoDispose((ref) {
  return ref
      .read(friendsUsecaseProvider)
      .streamFriends(); //.map((list) => list);
});

final friendIdsProvider = Provider.autoDispose<List<String>>(
  (ref) => ref.watch(friendIdsStreamNotifier).maybeWhen(
        data: (data) => data,
        orElse: () => [],
      ),
);

final friendsGraphProvider = FutureProvider.autoDispose((ref) async {
  Map<String, List<String>> graph = {};
  final v = ref.watch(friendIdsProvider);
  graph.addAll({ref.read(authProvider).currentUser!.uid: v});
  for (String vi in v) {
    List<String> vj = await ref.read(friendsUsecaseProvider).getFriendIds(vi);
    graph.addAll({vi: vj});
  }
  return graph;
});

final maybeFriends = FutureProvider.autoDispose((ref) async {
  final graph = ref.watch(friendsGraphProvider).asData?.value ?? {};
  return graph.entries.expand((e) => e.value).toSet().toList();
});

final deletesIdListNotifierProvider = StateNotifierProvider.autoDispose<
    DeletesIdListNotifier, AsyncValue<List<String>>>((ref) {
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

final relationStreamProvider = StreamProvider.autoDispose<RelationInfo>((ref) {
  return ref
      .read(relationDatasourceProvider)
      .streamRelation()
      .map((doc) => RelationInfo.fromJson(doc.data()!));
});

final requestIdsProvider = Provider.autoDispose<List<String>>((ref) {
  return ref.watch(relationStreamProvider.select((val) {
    return val.maybeWhen(
      data: (relation) => relation.requests,
      orElse: () => [],
    );
  }));
});

final requestedIdsProvider = Provider.autoDispose<List<String>>((ref) {
  return ref.watch(relationStreamProvider.select((val) {
    return val.maybeWhen(
      data: (relation) => relation.requesteds,
      orElse: () => [],
    );
  }));
});

/*final friendRequestIdListNotifierProvider = StateNotifierProvider.autoDispose<
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
    final list = _ref.read(friendIdListNotifierProvider).asData?.value ?? [];
    if (list.length >= 30) {
      showMessage("フレンド数は30人までです");
      return;
    }
    try {
      await usecase.sendFriendRequest(user);
      _ref.read(pushNotificationNotifierProvider).sendFriendRequest(user);
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
    final list = _ref.read(friendIdListNotifierProvider).asData?.value ?? [];
    if (list.length >= 30) {
      showMessage("フレンド数は30人までです");
      return;
    }
    usecase.admitFriendRequested(user.userId);
  }

  deleteRequested(UserAccount user) {
    usecase.deleteRequested(user.userId);
  }
}

 */

////
///
///
