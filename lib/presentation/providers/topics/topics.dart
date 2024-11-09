import 'package:app/presentation/pages/community_screen/model/topic.dart';

import 'package:app/usecase/topics_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recentTopicsNotifier =
    StateNotifierProvider<RecentTopicsNotifier, AsyncValue<List<Topic>>>((ref) {
  return RecentTopicsNotifier(
    ref,
    ref.watch(topicsUsecaseProvider),
  )..initialize();
});

/// State
class RecentTopicsNotifier extends StateNotifier<AsyncValue<List<Topic>>> {
  RecentTopicsNotifier(
    this.ref,
    this.usecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;

  final TopicsUsecase usecase;

  Future<void> initialize() async {
    final res = await usecase.getPopularTopics();
    //final communityIds = res.map((topic) => topic.communityId).toList();
    state = AsyncValue.data(res);
  }
}

final communityTopicsNotifier = StateNotifierProvider.family<
    CommunityTopicsNotifier,
    AsyncValue<List<Topic>>,
    String>((ref, communityId) {
  return CommunityTopicsNotifier(
    ref,
    communityId,
    ref.watch(topicsUsecaseProvider),
  )..initialize();
});

/// State
class CommunityTopicsNotifier extends StateNotifier<AsyncValue<List<Topic>>> {
  CommunityTopicsNotifier(
    this.ref,
    this.communityId,
    this.usecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final String communityId;
  final TopicsUsecase usecase;

  Future<void> initialize() async {
    final res = await usecase.getTopicsFromCommunity(communityId);
    state = AsyncValue.data(res);
  }
}
