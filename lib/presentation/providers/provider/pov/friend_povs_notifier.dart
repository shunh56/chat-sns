// Flutter imports:

// Package imports:

import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/pov.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/usecase/pov_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsPovsNotifierProvider = StateNotifierProvider.autoDispose<
    FriendsPovsNotifier, AsyncValue<List<Pov>>>((ref) {
  return FriendsPovsNotifier(
    ref,
    ref.watch(povUsecaseProvider),
  )..initialize();
});

/// State
class FriendsPovsNotifier extends StateNotifier<AsyncValue<List<Pov>>> {
  FriendsPovsNotifier(
    this.ref,
    this.usecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final PovUsecase usecase;

  bool initialized = false;

  Future<void> initialize() async {
    List<Pov> povs = [];
    while (!initialized) {
      final friendIds = ref.read(friendIdListNotifierProvider);
      if (friendIds.hasValue) {
        List<Future<List<Pov>>> futures = [];
        futures.add(getMyPovs());
        for (String userId in friendIds.asData!.value.map((item)=> item.userId)) {
          futures.add(usecase.getPovsFromUserId(userId));
        }
        await Future.wait(futures);
        for (var item in futures) {
          final list = await item;
          povs.addAll(list);
        }
        povs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (mounted) {
          state = AsyncValue.data(povs);
        }
        initialized = true;
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Future<void> refresh() async {
    List<Pov> povs = [];
    final friendIds =
        ref.read(friendIdListNotifierProvider).asData?.value ?? [];
    List<Future<List<Pov>>> futures = [];
    futures.add(getMyPovs());

    for (String userId in friendIds.map((item)=> item.userId)) {
      futures.add(usecase.getPovsFromUserId(userId));
    }
    await Future.wait(futures);
    for (var item in futures) {
      final list = await item;
      povs.addAll(list);
    }
    povs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    DebugPrint("povs length : ${povs.length}");

    state = AsyncValue.data(povs);
  }

  Future<List<Pov>> getMyPovs() async {
    final myId = ref.read(authProvider).currentUser!.uid;
    return usecase.getPovsFromUserId(myId);
  }
}
