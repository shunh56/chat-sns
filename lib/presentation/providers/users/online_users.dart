import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final newUsersNotifierProvider =
    StateNotifierProvider<NewUsersNotifier, AsyncValue<List<UserAccount>>>(
        (ref) {
  return NewUsersNotifier(
    ref,
  )..initialize();
});

/// State
class NewUsersNotifier extends StateNotifier<AsyncValue<List<UserAccount>>> {
  NewUsersNotifier(
    this.ref,
  ) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> initialize() async {
    final res = await ref.read(allUsersNotifierProvider.notifier).getNewUsers();
    state = AsyncValue.data(res);
  }

  Future<void> loadMore(Timestamp timestamp) async {
    final list = state.asData?.value ?? [];
    final res = await ref
        .read(allUsersNotifierProvider.notifier)
        .getNewUsers(createdAt: timestamp);
    state = AsyncValue.data([...list, ...res]);
  }

  refresh() async {
    final res = await ref.read(allUsersNotifierProvider.notifier).getNewUsers();
    state = AsyncValue.data(res);
  }
}

final recentUsersNotifierProvider =
    StateNotifierProvider<RecentUsersNotifier, AsyncValue<List<UserAccount>>>(
        (ref) {
  return RecentUsersNotifier(
    ref,
  )..initialize();
});

/// State
class RecentUsersNotifier extends StateNotifier<AsyncValue<List<UserAccount>>> {
  RecentUsersNotifier(
    this.ref,
  ) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> initialize() async {
    final res =
        await ref.read(allUsersNotifierProvider.notifier).getRecentUsers();
    state = AsyncValue.data(res);
  }

  Future<void> loadMore(Timestamp timestamp) async {
    final list = state.asData?.value ?? [];
    final res = await ref
        .read(allUsersNotifierProvider.notifier)
        .getOnlineUsers(lastOpenedAt: timestamp);
    state = AsyncValue.data([...list, ...res]);
  }

  refresh() async {
    final res =
        await ref.read(allUsersNotifierProvider.notifier).getRecentUsers();
    state = AsyncValue.data(res);
  }
}
