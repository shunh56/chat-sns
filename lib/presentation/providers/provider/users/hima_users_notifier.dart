// Package imports:

import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/usecase/hima_usecase.dart';
import 'package:app/usecase/user_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final himaUserIdListNotifierProvider = StateNotifierProvider.autoDispose<
    HimaUserIdListNotifier, AsyncValue<List<String>>>(
  (ref) => HimaUserIdListNotifier(
    ref,
    ref.watch(himaUsersUsecaseProvider),
    ref.watch(userUsecaseProvider),
  )..initialize(),
);

class HimaUserIdListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  HimaUserIdListNotifier(this.ref, this.usecase, this.usersUsecase)
      : super(const AsyncValue<List<String>>.loading());
  final Ref ref;
  final HimaUsersUsecase usecase;
  final UserUsecase usersUsecase;

  Future<void> initialize() async {
    final List<String> himaUserIdList = await usecase.getHimaUsers();
    await ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(himaUserIdList);

    state = AsyncValue.data(himaUserIdList);
  }

  refresh() async {
    await initialize();
  }

  addMe() {
    final tempList = state.asData!.value;
    final myId = ref.watch(authProvider).currentUser!.uid;
    tempList.removeWhere((id) => id == myId);
    usecase.addMeToList();
    state = AsyncValue.data([myId, ...state.asData!.value]);
  }
}
