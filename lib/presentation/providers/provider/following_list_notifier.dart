import 'package:app/domain/entity/relation.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/usecase/follow_follower_usecase.dart';
import 'package:app/usecase/push_notification_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followingListNotifierProvider = StateNotifierProvider.autoDispose<
    FollowingListNotifier, AsyncValue<List<Relation>>>(
  (ref) =>
      FollowingListNotifier(ref, ref.watch(ffUsecaseProvider))..initialize(),
);

class FollowingListNotifier extends StateNotifier<AsyncValue<List<Relation>>> {
  FollowingListNotifier(this.ref, this.usecase)
      : super(const AsyncValue<List<Relation>>.loading());

  final Ref ref;
  final FFUsecase usecase;

  Future<void> initialize() async {
    try {
      state = const AsyncValue.loading();
      final relations = await usecase.getFollowings();

      state = AsyncValue.data(relations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> followUser(UserAccount user) async {
    try {
      final currentState = state;
      if (!currentState.hasValue) return;

      final listToUpdate = List<Relation>.from(currentState.value!);
      final newRelation = Relation.create(user.userId);

      // Optimistic update
      listToUpdate.add(newRelation);
      state = AsyncValue.data(listToUpdate);

      // Actual API call
      await usecase.followUser(user.userId);
      ref.read(pushNotificationUsecaseProvider).sendFollow(user);
    } catch (e, stack) {
      // Revert to previous state on error
      state = AsyncValue.error(e, stack);
      // Re-initialize to ensure consistency

      await initialize();
    }
  }

  Future<void> unfollowUser(UserAccount user) async {
    try {
      final currentState = state;
      if (!currentState.hasValue) return;

      final listToUpdate = List<Relation>.from(currentState.value!);

      // Optimistic update
      listToUpdate.removeWhere((item) => item.userId == user.userId);
      state = AsyncValue.data(listToUpdate);

      // Actual API call
      await usecase.unfollowUser(user.userId);
    } catch (e, stack) {
      // Revert to previous state on error
      state = AsyncValue.error(e, stack);
      // Re-initialize to ensure consistency
      await initialize();
    }
  }

  // Helper method to check if user is being followed
  bool isFollowing(String userId) {
    final currentState = state;
    if (!currentState.hasValue) return false;

    return currentState.value!.any((relation) => relation.userId == userId);
  }

  // Clean up resources when the provider is disposed
  @override
  void dispose() {
    // Add any cleanup logic here
    super.dispose();
  }
}
