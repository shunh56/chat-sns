import 'package:app/domain/entity/thread.dart';
import 'package:app/data/repository/threads_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final threadsUsecaseProvider = Provider(
  (ref) => ThreadsUsecase(
    ref.watch(threadsRepositoryProvider),
  ),
);

class ThreadsUsecase {
  final ThreadsRepository _repository;
  ThreadsUsecase(this._repository);

  followThread(String id) {
    return _repository.followThread(id);
  }

  Future<List<Thread>> getAllThreads() async {
    return await _repository.getAllThreads();
  }

  Future<List<Thread>> getFollowingThreads() async {
    return await _repository.getFollowingThreads();
  }

  unfollowThread(String id) {
    return _repository.unfollowThread(id);
  }
}
