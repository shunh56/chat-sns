import 'package:app/domain/usecases/follow/get_followers_usecase.dart';
import 'package:app/domain/usecases/follow/get_following_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userFollowersProvider = FutureProvider.family((ref, String userId) async {
  return await ref.read(getFollowersUsecaseProvider).call(userId);
});

final userFollowingsProvider =
    FutureProvider.family((ref, String userId) async {
  return await ref.read(getFollowingUsecaseProvider).call(userId);
});
