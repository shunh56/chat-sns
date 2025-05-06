import 'package:app/domain/entity/thread.dart';
import 'package:app/presentation/providers/threads/following_threads_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_threads_notifier.g.dart';

// 友達リクエストしたユーザーなどを含む、関係するユーザーの全てのUserModelのリスト
@Riverpod(keepAlive: true)
class AllThreadsNotifier extends _$AllThreadsNotifier {
  @override
  AsyncValue<Map<String, Thread>> build() {
    Map<String, Thread> allThreads = {};
    ref.read(followingThreadsNotifierProvider);
    return AsyncValue.data(allThreads);
  }

  void addThreads(List<Thread> threads) {
    Map<String, Thread> cache = state.asData != null ? state.asData!.value : {};
    for (var thread in threads) {
      cache[thread.id] = thread;
    }
    state = AsyncValue.data(cache);
  }
}
