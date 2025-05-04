import 'package:app/domain/entity/footprint.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/domain/usecases/footprint_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final footprintsListNotifierProvider = StateNotifierProvider.autoDispose<
    FootprintsListNotifier, AsyncValue<List<Footprint>>>((ref) {
  return FootprintsListNotifier(
    ref,
    ref.watch(footprintUsecaseProvider),
  )..initialize();
});

class FootprintsListNotifier
    extends StateNotifier<AsyncValue<List<Footprint>>> {
  FootprintsListNotifier(this._ref, this.usecase)
      : super(const AsyncValue<List<Footprint>>.loading());
  final Ref _ref;
  final FootprintUsecase usecase;

  void initialize() async {
    List<Footprint> list = await usecase.getFootprints();
    await _ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(list.map((item) => item.userId).toList());
    if (mounted) {
      state = AsyncValue.data(list);
    }
  }

  refresh() {
    return initialize();
  }

  addFootprint(UserAccount user) {
    usecase.addFootprint(user.userId);
    List<Footprint> listToUpdate = state.asData?.value ?? [];
    if (listToUpdate.map((item) => item.userId).contains(user.userId)) {
      final item =
          listToUpdate.where((item) => item.userId == user.userId).first;
      item.count++;
      item.updatedAt = Timestamp.now();
    } else {
      listToUpdate = [
        Footprint(
          userId: user.userId,
          count: 1,
          updatedAt: Timestamp.now(),
        ),
        ...listToUpdate
      ];
    }
    listToUpdate.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    state = AsyncValue.data(listToUpdate);
  }

  deleteFootprint(UserAccount user) {
    usecase.deleteFootprint(user.userId);
    final listToUpdate = state.asData?.value ?? [];
    listToUpdate.removeWhere((item) => item.userId == user.userId);
    state = AsyncValue.data(listToUpdate);
  }
}

final footprintedsListNotifierProvider = StateNotifierProvider.autoDispose<
    FootprintedsListNotifier, AsyncValue<List<Footprint>>>((ref) {
  return FootprintedsListNotifier(
    ref,
    ref.watch(footprintUsecaseProvider),
  )..initialize();
});

class FootprintedsListNotifier
    extends StateNotifier<AsyncValue<List<Footprint>>> {
  FootprintedsListNotifier(this._ref, this.usecase)
      : super(const AsyncValue<List<Footprint>>.loading());
  final Ref _ref;
  final FootprintUsecase usecase;

  void initialize() async {
    List<Footprint> list = await usecase.getFootprinteds();
    await _ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(list.map((item) => item.userId).toList());
    state = AsyncValue.data(list);
  }

  refresh() {
    return initialize();
  }
}
