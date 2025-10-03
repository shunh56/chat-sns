import 'package:app/domain/usecases/follow/get_followers_usecase.dart';
import 'package:app/domain/usecases/follow/get_following_usecase.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userFollowersProvider = FutureProvider.family((ref, String userId) async {
  final userIds = await ref.read(getFollowersUsecaseProvider).call(userId);
  return await ref
      .read(allUsersNotifierProvider.notifier)
      .getUserAccounts(userIds);
});

final userFollowingsProvider =
    FutureProvider.family((ref, String userId) async {
  final userIds = await ref.read(getFollowingUsecaseProvider).call(userId);
  return await ref
      .read(allUsersNotifierProvider.notifier)
      .getUserAccounts(userIds);
});
