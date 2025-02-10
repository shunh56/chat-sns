import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/following_list_notifier.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final followingUsersProvider =
    FutureProvider.autoDispose<List<UserAccount>>((ref) async {
  // フォロー関係の状態を監視
  final followingsState = ref.watch(followingListNotifierProvider);

  // フォロー状態に基づいてユーザー情報を取得
  return followingsState.when(
    data: (relations) async {
      final followingIds =
          relations.map((relation) => relation.userId).toList();
      final users = await ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(followingIds);
      return users;
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});
