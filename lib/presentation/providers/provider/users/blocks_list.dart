// Package imports:
import 'dart:async';

import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/domain/usecases/block_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:

final blocksListNotifierProvider =
    StateNotifierProvider<BlocksListNotifier, AsyncValue<List<String>>>((ref) {
  return BlocksListNotifier(
    ref,
    ref.watch(blockUsecaseProvider),
  )..initialize();
});

/// State
class BlocksListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  BlocksListNotifier(this.ref, this.usecase)
      : super(const AsyncValue<List<String>>.loading());

  final Ref ref;
  final BlockUsecase usecase;

  Future<void> initialize() async {
    state = AsyncValue.data(await usecase.getBlocks());
  }

  blockUser(UserAccount user) async {
    usecase.blockUser(user);
    ref.read(myAccountNotifierProvider.notifier).removeTopFriends(user);
    final listToUpdate = state.value ?? [];
    listToUpdate.add(user.userId);
    state = AsyncValue.data(listToUpdate);
  }

  unblockUser(UserAccount user) async {
    usecase.unblockUser(user);
    final listToUpdate = state.value ?? [];
    listToUpdate.removeWhere((e) => e == user.userId);
    state = AsyncValue.data(listToUpdate);
  }
}

final blockedsListNotifierProvider =
    StateNotifierProvider<BlockedsListNotifier, AsyncValue<List<String>>>(
        (ref) {
  return BlockedsListNotifier(
    ref,
    ref.watch(blockUsecaseProvider),
  )..initialize();
});

/// State
class BlockedsListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  BlockedsListNotifier(this.ref, this.usecase)
      : super(const AsyncValue<List<String>>.loading());

  final Ref ref;
  final BlockUsecase usecase;
  StreamSubscription<List<String>>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void initialize() async {
    final stream = usecase.streamBlockeds();
    _subscription = stream.listen((userIds) async {
      if (mounted) {
        state = AsyncValue.data(userIds);
      }
    });
  }
}
