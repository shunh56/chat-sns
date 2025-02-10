import 'package:app/domain/entity/relation.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/usecase/follow_follower_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userFollowersProvider = FutureProvider.family((ref, String userId) async {
  return await ref.read(ffUsecaseProvider).getFollowers(userId: userId);
});

final userFollowingsProvider =
    FutureProvider.family((ref, String userId) async {
  return await ref.read(ffUsecaseProvider).getFollowings(userId: userId);
});



final followersListNotifierProvider = StateNotifierProvider.autoDispose<
    FollowersListNotifier, AsyncValue<List<Relation>>>(
  (ref) =>
      FollowersListNotifier(ref, ref.watch(ffUsecaseProvider))..initialize(),
);

class FollowersListNotifier extends StateNotifier<AsyncValue<List<Relation>>> {
  FollowersListNotifier(this.ref, this.usecase)
      : super(const AsyncValue<List<Relation>>.loading());

  final Ref ref;
  final FFUsecase usecase;

  Future<void> initialize() async {
    try {
      state = const AsyncValue.loading();
      final relations = await usecase.getFollowers();

      state = AsyncValue.data(relations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // フォロワーが追加された時の処理
  void addFollower(UserAccount user) {
    final currentState = state;
    if (!currentState.hasValue) return;

    final listToUpdate = List<Relation>.from(currentState.value!);
    final newRelation = Relation.create(user.userId);

    if (!listToUpdate.any((relation) => relation.userId == user.userId)) {
      listToUpdate.add(newRelation);
      state = AsyncValue.data(listToUpdate);
    }
  }

  // フォロワーが削除された時の処理
  void removeFollower(UserAccount user) {
    final currentState = state;
    if (!currentState.hasValue) return;

    final listToUpdate = List<Relation>.from(currentState.value!);
    listToUpdate.removeWhere((item) => item.userId == user.userId);
    state = AsyncValue.data(listToUpdate);
  }

  // ユーザーがフォロワーかどうかをチェック
  bool isFollower(String userId) {
    final currentState = state;
    if (!currentState.hasValue) return false;

    return currentState.value!.any((relation) => relation.userId == userId);
  }

  // プロバイダーが破棄される時のクリーンアップ
  @override
  void dispose() {
    // 必要に応じてクリーンアップロジックを追加
    super.dispose();
  }
}
