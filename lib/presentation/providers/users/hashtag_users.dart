import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hashTagUsersNotifierProvider = StateNotifierProvider.family<
    HashTagUsersNotifier, AsyncValue<List<UserAccount>>, String>((ref, tagId) {
  return HashTagUsersNotifier(ref, tagId)..initialize();
});

/// State
class HashTagUsersNotifier
    extends StateNotifier<AsyncValue<List<UserAccount>>> {
  HashTagUsersNotifier(
    this.ref,
    this.tagId,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final String tagId;

  Future<void> initialize() async {
    final res = await ref
        .read(allUsersNotifierProvider.notifier)
        .getUsersByHashTag(tagId);
    res.removeWhere((user) => user.isMe);
    state = AsyncValue.data(res);
  }

  Future<void> loadMore() async {
    final currentList = state.asData?.value ?? [];
    if (currentList.isEmpty) {
      return initialize();
    } else {
      final String lastUserId = currentList.last.userId;
      final res = await ref
          .read(allUsersNotifierProvider.notifier)
          .loadMoreUsersByHashTag(tagId, lastUserId);
      res.removeWhere((user) => user.isMe);
      final existingUserIds = currentList.map((user) => user.userId).toSet();
      final newUniqueUsers =
          res.where((user) => !existingUserIds.contains(user.userId)).toList();
      state = AsyncValue.data([...currentList, ...newUniqueUsers]);
    }
  }
}
