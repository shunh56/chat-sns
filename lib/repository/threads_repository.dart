import 'package:app/datasource/threads_datasource.dart';
import 'package:app/domain/entity/thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final threadsRepositoryProvider = Provider(
  (ref) => ThreadsRepository(
    ref.watch(threadsDatasourceProvider),
  ),
);

class ThreadsRepository {
  final ThreadsDatasource _datasource;
  ThreadsRepository(this._datasource);

  followThread(String id) {
    return _datasource.followThread(id);
  }

  Future<List<Thread>> getAllThreads() async {
    final res = await _datasource.fetchAllThreads();
    return res.docs.map((doc) => Thread.fromJson(doc.data())).toList();
  }

  Future<List<Thread>> getFollowingThreads() async {
    final res = await _datasource.fetchFollowingThreads();
    return res.map((doc) => Thread.fromJson(doc.data()!)).toList();
  }

  unfollowThread(String id) {
    return _datasource.unfollowThread(id);
  }
}
