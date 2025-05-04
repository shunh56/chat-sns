// Package imports:
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/mute_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:

final mutesListNotifierProvider =
    StateNotifierProvider<MutesListNotifier, AsyncValue<List<String>>>((ref) {
  return MutesListNotifier(
    ref,
    ref.watch(muteUsecaseProvider),
  )..initialize();
});

/// State
class MutesListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  MutesListNotifier(this.ref, this.usecase)
      : super(const AsyncValue<List<String>>.loading());

  final Ref ref;
  final MuteUsecase usecase;

  Future<void> initialize() async {
    state = AsyncValue.data(await usecase.getMutes());
  }

  muteUser(UserAccount user) async {
    usecase.muteUser(user);
    final listToUpdate = state.value;
    listToUpdate!.add(user.userId);
    state = AsyncValue.data(listToUpdate);
  }

  unMuteUser(UserAccount user) async {
    usecase.unMuteUser(user);
    final listToUpdate = state.value;
    listToUpdate!.removeWhere((e) => e == user.userId);
    state = AsyncValue.data(listToUpdate);
  }
}
