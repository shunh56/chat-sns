/*// Package imports:
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/usecase/follow_follower_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myFollowerListNotifierProvider =
    StateNotifierProvider<FollowerListNotifier, AsyncValue<List<String>>>(
        (ref) {
  return FollowerListNotifier(
    ref,
    ref.watch(ffUsecaseProvider),
  )..initialize();
});

class FollowerListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  FollowerListNotifier(this._ref, this.usecase)
      : super(const AsyncValue<List<String>>.loading());
  final Ref _ref;
  final FFUsecase usecase;

  Future<void> initialize() async {
    Stream<List<String>> stream = usecase.streamFollowers();
    stream.listen((event) {
      state = AsyncValue.data(event);
      for (var userId in event) {
        _ref.read(allUsersNotifierProvider.notifier).getUserAccounts([userId]);
      }
    });
  }
}
 */