import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/thread.dart';
import 'package:app/presentation/providers/provider/threads/all_threads_notifier.dart';
import 'package:app/domain/usecases/threads_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followingThreadsNotifierProvider = StateNotifierProvider<
    FollowingThreadsListNotifier, AsyncValue<List<Thread>>>((ref) {
  return FollowingThreadsListNotifier(
    ref,
    ref.watch(threadsUsecaseProvider),
  )..initialize();
});

class FollowingThreadsListNotifier
    extends StateNotifier<AsyncValue<List<Thread>>> {
  FollowingThreadsListNotifier(this._ref, this._usecase)
      : super(const AsyncValue<List<Thread>>.loading());
  final Ref _ref;
  final ThreadsUsecase _usecase;

  void initialize() async {
    List<Thread> followingThreads = await _usecase.getFollowingThreads();
    List<Thread> allThreads = await _usecase.getAllThreads();
    DebugPrint("threads : $followingThreads");
    _ref.read(allThreadsNotifierProvider.notifier).addThreads(followingThreads);
    _ref.read(allThreadsNotifierProvider.notifier).addThreads(allThreads);
    state = AsyncValue.data(followingThreads);
  }

  followThread(Thread thread) {
    final listToUpdate = state.asData?.value ?? [];
    listToUpdate.add(thread);
    state = AsyncValue.data(listToUpdate);
    _usecase.followThread(thread.id);
  }

  unfollowThread(Thread thread) {
    final listToUpdate = state.asData?.value ?? [];
    listToUpdate.removeWhere((item) => item.id == thread.id);
    state = AsyncValue.data(listToUpdate);
    _usecase.unfollowThread(thread.id);
  }
}
