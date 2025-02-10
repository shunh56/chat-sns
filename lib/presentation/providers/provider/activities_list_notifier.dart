// Package imports:
import 'dart:async';

import 'package:app/domain/entity/activities.dart';
import 'package:app/usecase/activities_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:

final activitiesListNotifierProvider =
    StateNotifierProvider<ActivitiesListNotifier, AsyncValue<List<Activity>>>(
        (ref) {
  return ActivitiesListNotifier(
    ref,
    ref.watch(activitiesUsecaseProvider),
  )..initialize();
});

/// State
class ActivitiesListNotifier extends StateNotifier<AsyncValue<List<Activity>>> {
  ActivitiesListNotifier(this.ref, this.usecase)
      : super(const AsyncValue<List<Activity>>.loading());

  final Ref ref;
  final ActivitiesUsecase usecase;
  StreamSubscription? _subscription;

  Future<void> initialize() async {
    final list = await usecase.getRecentActivities();
    state = AsyncValue.data(list);
    startStream();
  }

  startStream() {
    _subscription = usecase.streamActivity().listen((snapshot) {
      if (snapshot.isEmpty) return;
      final latest = snapshot.first;
      final currentActivities = state.value ?? [];
      currentActivities.removeWhere((activity) => activity.id == latest.id);
      // 重複を避けて最新メッセージを追加
      state = AsyncValue.data([latest, ...currentActivities]);
    });
  }

  refresh() {
    initialize();
  }

  void readActivity(Activity activity) {
    final cache = state.asData?.value ?? [];
    final updatedCache = cache
        .map((e) => e.id == activity.id ? e.copyWith(isSeen: true) : e)
        .toList();
    state = AsyncValue.data(updatedCache);
  }

  readActivities() async {
    usecase.readActivities();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
