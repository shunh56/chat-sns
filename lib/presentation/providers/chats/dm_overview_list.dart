import 'package:app/domain/entity/message_overview.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/domain/usecases/direct_message_overview_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dmOverviewListNotifierProvider =
    StateNotifierProvider<DmOverviewListNotifier, AsyncValue<List<DMOverview>>>(
  (ref) =>
      DmOverviewListNotifier(ref, ref.watch(dmOverviewUsecaseProvider))..init(),
);

class DmOverviewListNotifier
    extends StateNotifier<AsyncValue<List<DMOverview>>> {
  DmOverviewListNotifier(
    this._ref,
    this._usecase,
  ) : super(const AsyncValue.loading());

  final Ref _ref;
  final DirectMessageOverviewUsecase _usecase;

  init() async {
    final stream = _usecase.streamDMOverviews();
    final subscription = stream.listen((event) async {
      await _ref.read(allUsersNotifierProvider.notifier).getUserAccounts(
            event.map((overview) => overview.userId).toList(),
          );
      event.sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      );
      if (mounted) {
        state = AsyncValue.data(event);
      }
    });
    _ref.onDispose(subscription.cancel);
  }

  // delete from both users
  closeChat(UserAccount user) {
    final listToUpdate = state.value ?? [];
    listToUpdate.removeWhere((item) => item.userId == user.userId);
    state = AsyncValue.data(listToUpdate);
    _usecase.closeChat(user.userId);
  }

  //delete just me
  leaveChat(UserAccount user) {
    final listToUpdate = state.value ?? [];
    listToUpdate.removeWhere((item) => item.userId == user.userId);
    state = AsyncValue.data(listToUpdate);
    _usecase.leaveChat(user.userId);
  }

  joinChat(UserAccount user) {
    _usecase.joinChat(user.userId);
  }
}
